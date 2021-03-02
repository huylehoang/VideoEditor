/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CircleOpenTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & smoothness [[ buffer(2) ]],
                                 constant bool & opening [[ buffer(3) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  const float2 center = float2(0.5, 0.5);
  const float SQRT_2 = 1.414213562373;
  float x = opening ? progress : 1.-progress;
  float m = smoothstep(-smoothness, 0.0, SQRT_2*distance(center, uv) - x*(1.+smoothness));
  float4 outColor = mix(fromColor, toColor, opening ? 1.-m : m);
  outputTexture.write(outColor, gid);
}


