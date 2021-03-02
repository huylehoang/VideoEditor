/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Eke Péter <peterekepeter@gmail.com>
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CrossWarpTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float x = progress;
  x = smoothstep(.0,1.0,(x * 2.0 + uv.x - 1.0));
  float4 outColor = mix(getColor((uv - 0.5) * (1.0 - x) + 0.5, fromTexture, ratio),
                        getColor((uv - 0.5) * x + 0.5, toTexture, ratio),
                        x);
  outputTexture.write(outColor, gid);
}
