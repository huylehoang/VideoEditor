/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Fernando Kuteken
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void RotateScaleFadeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                      texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                      texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                      constant float & ratio [[ buffer(0) ]],
                                      constant float & progress [[ buffer(1) ]],
                                      constant float & scale [[ buffer(2) ]],
                                      constant float & rotations [[ buffer(3) ]],
                                      constant float2 & center [[ buffer(4) ]],
                                      constant float4 & backColor [[ buffer(5) ]],
                                      uint2 gid [[ thread_position_in_grid ]],
                                      uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;

  float2 difference = uv - center;
  float2 dir = normalize(difference);
  float dist = length(difference);

  float angle = 2.0 * PI * rotations * progress;

  float c = cos(angle);
  float s = sin(angle);

  float currentScale = mix(scale, 1.0, 2.0 * abs(progress - 0.5));

  float2 rotatedDir = float2(dir.x  * c - dir.y * s, dir.x * s + dir.y * c);
  float2 rotatedUv = center + rotatedDir * dist / currentScale;

  float4 outColor;
  if (rotatedUv.x < 0.0 || rotatedUv.x > 1.0 ||
      rotatedUv.y < 0.0 || rotatedUv.y > 1.0)
  {
    outColor = backColor;
  } else {
    outColor = mix(getColor(rotatedUv, fromTexture, ratio),
                   getColor(rotatedUv, toTexture, ratio),
                   progress);
  }
  outputTexture.write(outColor, gid);
}
