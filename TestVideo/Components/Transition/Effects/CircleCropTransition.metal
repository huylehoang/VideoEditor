/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: fkuteken
// ported by gre from https://gist.github.com/fkuteken/f63e3009c1143950dee9063c3b83fb88

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CircleCropTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & bgcolor [[ buffer(2) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float2 ratio2 = float2(1.0, 1.0 / ratio);
  float s = pow(2.0 * abs(progress - 0.5), 3.0);
  float dist = length((float2(uv) - 0.5) * ratio2);
  float4 outColor = mix(progress < 0.5 ? fromColor : toColor, // branching is ok here as we statically depend on progress uniform (branching won't change over pixels)
                        bgcolor,
                        step(s, dist));
  outputTexture.write(outColor, gid);
}
