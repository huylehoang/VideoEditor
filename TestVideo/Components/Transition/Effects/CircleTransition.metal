/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Fernando Kuteken
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CircleTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant float2 & center [[ buffer(2) ]],
                             constant float3 & backColor [[ buffer(3) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float distance = length(uv - center);
  float radius = sqrt(8.0) * abs(progress - 0.5);
  if (distance > radius) {
    outputTexture.write(float4(backColor, 1.0), gid);
  } else {
    if (progress < 0.5) {
      outputTexture.write(fromColor, gid);
    } else {
      outputTexture.write(toColor, gid);
    }
  }
}
