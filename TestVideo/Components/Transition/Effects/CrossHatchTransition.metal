/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: pthrasher
// adapted by gre from https://gist.github.com/pthrasher/04fd9a7de4012cbb03f6

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CrossHatchTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & threshold [[ buffer(2) ]],
                                 constant float2 & center [[ buffer(3) ]],
                                 constant float & fadeEdge [[ buffer(4) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float dist = distance(center, uv) / threshold;
  float r = progress - min(rand(float2(uv.y, 0.0)), rand(float2(0.0, uv.x)));
  float4 outColor = mix(fromColor,
                        toColor,
                        mix(0.0,
                            mix(step(dist, r),1.0, smoothstep(1.0 - fadeEdge, 1.0, progress)),
                            smoothstep(0.0, fadeEdge, progress)));
  outputTexture.write(outColor, gid);
}
