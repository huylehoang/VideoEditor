/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Paweł Płóciennik
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void WaterDropTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                constant float & ratio [[ buffer(0) ]],
                                constant float & progress [[ buffer(1) ]],
                                constant float & speed [[ buffer(2) ]],
                                constant float & amplitude [[ buffer(3) ]],
                                uint2 gid [[ thread_position_in_grid ]],
                                uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;

  float2 dir = uv - float2(0.5);
  float dist = length(dir);

  float4 outColor;
  if (dist > progress) {
    outColor = mix(getColor(uv, fromTexture, ratio),
                   getColor(uv, fromTexture, ratio),
                   progress);
  } else {
    float2 offset = dir * sin(dist * amplitude - progress * speed);
    outColor = mix(getColor(uv + offset, fromTexture, ratio),
                   getColor(uv, toTexture, ratio),
                   progress);
  }
  outputTexture.write(outColor, gid);
}
