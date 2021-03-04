/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void RippleTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float2 dir = uv - float2(.5);
  float dist = length(dir);
  float2 offset = dir * (sin(progress * dist * amplitude - progress * speed) + .5) / 30.;
  float4 outColor = mix(getColor(uv + offset, fromTexture, ratio),
                        getColor(uv, toTexture, ratio),
                        smoothstep(0.2, 1.0, progress));
  outputTexture.write(outColor, gid);
}
