/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Matt DesLauriers
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float glitch_random(float2 co) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,float2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float glitch_voronoi(float2 x ) {
    float2 p = floor(x);
    float2 f = fract(x);
    float res = 8.0;
    for(float j = -1.0; j <= 1.0; j++ )
        for(float i = -1.0; i <= 1.0; i++ ) {
            float2  b = float2( i, j );
            float2  r = b - f + glitch_random(p + b);
            float d = dot(r, r);
            res = min( res, d );
        }
    return sqrt( res );
}

float2 displace(float4 tex, float2 texCoord, float dotDepth, float textureDepth, float strength) {
    //    float b = glitch_voronoi(.003 * texCoord + 2.0);
    //    float g = glitch_voronoi(0.2 * texCoord);
    //    float r = glitch_voronoi(texCoord - 1.0);
    float4 dt = tex * 1.0;
    float4 dis = dt * dotDepth + 1.0 - tex * textureDepth;

    dis.x = dis.x - 1.0 + textureDepth*dotDepth;
    dis.y = dis.y - 1.0 + textureDepth*dotDepth;
    dis.x *= strength;
    dis.y *= strength;
    float2 res_uv = texCoord ;
    res_uv.x = res_uv.x + dis.x - 0.0;
    res_uv.y = res_uv.y + dis.y;
    return res_uv;
}

float glitch_ease1(float t) {
    return t == 0.0 || t == 1.0
    ? t
    : t < 0.5
    ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
    : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}
float glitch_ease2(float t) {
    return t == 1.0 ? t : 1.0 - pow(2.0, -10.0 * t);
}

kernel void GlitchDisplaceTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                     texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                     texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                     constant float & ratio [[ buffer(0) ]],
                                     constant float & progress [[ buffer(1) ]],
                                     uint2 gid [[ thread_position_in_grid ]],
                                     uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv.xy / float2(1.0).xy;
  float4 color1 = getColor(p, fromTexture, ratio);
  float4 color2 = getColor(p, toTexture, ratio);
  float2 disp = displace(color1, p, 0.33, 0.7, 1.0 - glitch_ease1(progress));
  float2 disp2 = displace(color2, p, 0.33, 0.5, glitch_ease2(progress));
  float4 dColor1 = getColor(disp, toTexture, ratio);
  float4 dColor2 = getColor(disp2, fromTexture, ratio);
  float val = glitch_ease1(progress);
  float3 gray = float3(dot(min(dColor2, dColor1).rgb, float3(0.299, 0.587, 0.114)));
  dColor2 = float4(gray, 1.0);
  dColor2 *= 2.0;
  color1 = mix(color1, dColor2, smoothstep(0.0, 0.5, progress));
  color2 = mix(color2, dColor1, smoothstep(1.0, 0.5, progress));
  float4 outColor = mix(color1, color2, val);
  outputTexture.write(outColor, gid);
}
