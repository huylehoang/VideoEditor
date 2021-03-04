/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Fernando Kuteken
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void PolarFunctionTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                    texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                    constant float & ratio [[ buffer(0) ]],
                                    constant float & progress [[ buffer(1) ]],
                                    constant int & segments [[ buffer(2) ]],
                                    uint2 gid [[ thread_position_in_grid ]],
                                    uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float angle = atan2(uv.y - 0.5, uv.x - 0.5) - 0.5 * PI;
  //  float normalized = (angle + 1.5 * PI) * (2.0 * PI);

  float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
  float difference = length(uv - float2(0.5, 0.5));

  if (difference > radius * progress) {
    outputTexture.write(getColor(uv, fromTexture, ratio), gid);
  } else {
    outputTexture.write(getColor(uv, toTexture, ratio), gid);
  }
}
