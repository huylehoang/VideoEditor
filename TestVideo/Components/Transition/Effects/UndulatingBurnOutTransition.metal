/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// author: Brandon Anzaldi
// license: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float quadraticInOut(float t) {
  float p = 2.0 * t * t;
  return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

float getGradient(float r, float dist, float smoothness) {
  float d = r - dist;
  return mix(smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)),
             -1.0 - step(0.005, d),
             step(-0.005, d) * step(d, 0.01)
             );
}

float getWave(float2 p, float2 center, float progress){
  float2 _p = p - center; // offset from center
  float rads = atan2(_p.y, _p.x);
  float degs = 180.0 * rads / M_PI_F + 180.0;
  //    float2 range = float2(0.0, M_PI * 30.0);
  //    float2 domain = float2(0.0, 360.0);
  float ratio = (M_PI * 30.0) / 360.0;
  degs = degs * ratio;
  float x = progress;
  float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
  float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
  float ease_degs = quadraticInOut(sin(degs));
  float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
  return x + deg_wave_pos;
}

kernel void UndulatingBurnOutTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                        texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                        texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                        constant float & ratio [[ buffer(0) ]],
                                        constant float & progress [[ buffer(1) ]],
                                        constant float3 & color [[ buffer(2) ]],
                                        constant float & smoothness [[ buffer(3) ]],
                                        constant float2 & center [[ buffer(4) ]],
                                        uint2 gid [[ thread_position_in_grid ]],
                                        uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float dist = distance(center, uv);
  float m = getGradient(getWave(uv, center, progress), dist, smoothness);
  float4 cfrom = getColor(uv, fromTexture, ratio);
  float4 cto = getColor(uv, toTexture, ratio);
  float4 outColor = mix(mix(cfrom, cto, m), mix(cfrom, float4(color, 1.0), 0.75), step(m, -2.0));
  outputTexture.write(outColor, gid);
}
