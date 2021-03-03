/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void FadeColorTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                constant float & ratio [[ buffer(0) ]],
                                constant float & progress [[ buffer(1) ]],
                                constant float3 & color [[ buffer(2) ]],
                                constant float & colorPhase [[ buffer(3) ]],
                                uint2 gid [[ thread_position_in_grid ]],
                                uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 outColor = mix(mix(float4(color, 1.0),
                            getColor(uv, fromTexture, ratio),
                            smoothstep(1.0 - colorPhase, 0.0, progress)),
                        mix(float4(color, 1.0),
                            getColor(uv, toTexture, ratio),
                            smoothstep(colorPhase, 1.0, progress)),
                        progress);
  outputTexture.write(outColor, gid);
}
