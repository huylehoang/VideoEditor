/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: 0gust1
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float2 simple_zoom(float2 uv, float amount) {
  return 0.5 + ((uv - 0.5) * (1.0-amount));
}

kernel void SimpleZoomTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & zoomQuickness [[ buffer(2) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float nQuick = clamp(zoomQuickness, 0.2, 1.0);
  float4 fromColor = getColor(simple_zoom(uv, smoothstep(0.0, nQuick, progress)), fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float4 outColor = mix(fromColor, toColor, smoothstep(nQuick-0.2, 1.0, progress));
  outputTexture.write(outColor, gid);
}
