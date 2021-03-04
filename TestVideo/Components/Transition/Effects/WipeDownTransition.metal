/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Jake Nelson
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void WipeDownTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float2 p = uv.xy/float2(1.0).xy;
  float4 a = getColor(uv, fromTexture, ratio);
  float4 b = getColor(uv, toTexture, ratio);
  float4 outColor = mix(a, b, step(1.0 - p.y, progress));
  outputTexture.write(outColor, gid);
}
