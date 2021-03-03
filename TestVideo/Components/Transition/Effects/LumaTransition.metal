/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void LumaTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                           texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                           texture2d<float, access::sample> toTexture [[ texture(2) ]],
                           texture2d<float, access::sample> luma [[ texture(3) ]],
                           constant float & ratio [[ buffer(0) ]],
                           constant float & progress [[ buffer(1) ]],
                           uint2 gid [[ thread_position_in_grid ]],
                           uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
  float r = luma.sample(s, uv).r;
  float4 outColor = mix(getColor(uv, toTexture, ratio),
                        getColor(uv, fromTexture, ratio),
                        step(progress, r));
  outputTexture.write(outColor, gid);
}
