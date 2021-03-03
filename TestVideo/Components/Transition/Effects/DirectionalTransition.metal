/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Gaëtan Renaudeau
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void DirectionalTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                  texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                  texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                  constant float & ratio [[ buffer(0) ]],
                                  constant float & progress [[ buffer(1) ]],
                                  constant float2 & direction [[ buffer(2) ]],
                                  uint2 gid [[ thread_position_in_grid ]],
                                  uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv + progress * sign(direction);
  float2 f = fract(p);
  float4 outColor = mix(getColor(f, toTexture, ratio),
                        getColor(f, fromTexture, ratio),
                        step(0.0, p.y) * step(p.y, 1.0) * step(0.0, p.x) * step(p.x, 1.0));
  outputTexture.write(outColor, gid);
}
