/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: Xaychru
// ported by gre from https://gist.github.com/Xaychru/ce1d48f0ce00bb379750

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void RadialTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant float & smoothness [[ buffer(2) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 rp = uv * 2.0 - 1.0;
  float4 outColor = mix(getColor(uv, toTexture, ratio),
                        getColor(uv, fromTexture, ratio),
                        smoothstep(0.0, smoothness, atan2(rp.y,rp.x) - (progress - 0.5) * PI * 2.5));
  outputTexture.write(outColor, gid);
}
