/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: Sergey Kosarevsky
// ( http://www.linderdaum.com )
// ported by gre from https://gist.github.com/corporateshark/cacfedb8cca0f5ce3f7c

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void SwirlTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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

  float radius = 1.0;
  float t = progress;
  uv -= float2( 0.5, 0.5 );
  float dist = length(uv);

  if (dist < radius) {
      float percent = (radius - dist) / radius;
      float a = (t <= 0.5 ) ? mix( 0.0, 1.0, t/0.5) : mix( 1.0, 0.0, (t-0.5)/0.5 );
      float theta = percent * percent * a * 8.0 * 3.14159;
      float s = sin(theta);
      float c = cos(theta);
      uv = float2(dot(uv, float2(c, -s)), dot(uv, float2(s, c)) );
  }
  uv += float2( 0.5, 0.5 );

  float4 c0 = getColor(uv, fromTexture, ratio);
  float4 c1 = getColor(uv, toTexture, ratio);

  float4 outColor = mix(c0, c1, t);
  outputTexture.write(outColor, gid);
}
