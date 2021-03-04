/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void RandomSquaresTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                   texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                   texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                   constant float & ratio [[ buffer(0) ]],
                                   constant float & progress [[ buffer(1) ]],
                                   constant float & smoothness [[ buffer(2) ]],
                                   constant float2 & size [[ buffer(3) ]],
                                   uint2 gid [[ thread_position_in_grid ]],
                                   uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float r = rand(floor(float2(size) * uv));
  float m = smoothstep(0.0, -smoothness, r - (progress * (1.0 + smoothness)));
  float4 outColor = mix(getColor(uv, fromTexture, ratio),
                        getColor(uv, toTexture, ratio),
                        m);
  outputTexture.write(outColor, gid);
}
