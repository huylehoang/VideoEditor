/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: pschroen
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void DirectionalWarpTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  const float smoothness = 0.5;
  const float2 center = float2(0.5, 0.5);
  float2 v = normalize(direction);
  v /= abs(v.x) + abs(v.y);
  float d = v.x * center.x + v.y * center.y;
  float m = 1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + progress * (1.0 + smoothness)));
  float4 outColor = mix(getColor((uv - 0.5) * (1.0 - m) + 0.5, fromTexture, ratio),
                        getColor((uv - 0.5) * m + 0.5, toTexture, ratio),
                        m);
  outputTexture.write(outColor, gid);
}
