/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Travis Fischer
// License: MIT
//
// Adapted from a Codrops article by Robin Delaporte
// https://tympanus.net/Development/DistortionHoverEffect

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void DisplacementTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                   texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                   texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                   texture2d<float, access::sample> displacementMap [[ texture(3)]],
                                   constant float & ratio [[ buffer(0) ]],
                                   constant float & progress [[ buffer(1) ]],
                                   constant float & strength [[ buffer(2) ]],
                                   uint2 gid [[ thread_position_in_grid ]],
                                   uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
  float displacement = displacementMap.sample(s, uv).r * strength;
  float2 uvFrom = float2(uv.x + progress * displacement, uv.y);
  float2 uvTo = float2(uv.x - (1.0 - progress) * displacement, uv.y);
  float4 outColor = mix(getColor(uvFrom, fromTexture, ratio),
                        getColor(uvTo, toTexture, ratio),
                        progress);
  outputTexture.write(outColor, gid);
}
