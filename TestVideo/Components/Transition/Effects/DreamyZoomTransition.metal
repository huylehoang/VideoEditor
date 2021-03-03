/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Zeh Fernando
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

// Definitions --------
#define DEG2RAD 0.03926990816987241548078304229099 // 1/180*PI

kernel void DreamyZoomTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & rotation [[ buffer(2) ]],
                                 constant float & scale [[ buffer(3) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  // Massage parameters
  float phase = progress < 0.5 ? progress * 2.0 : (progress - 0.5) * 2.0;
  float angleOffset = progress < 0.5 ? mix(0.0, rotation * DEG2RAD, phase) : mix(-rotation * DEG2RAD, 0.0, phase);
  float newScale = progress < 0.5 ? mix(1.0, scale, phase) : mix(scale, 1.0, phase);

  float2 center = float2(0, 0);

  // Calculate the source point
  // float2 assumedCenter = float2(0.5, 0.5);
  float2 p = (uv.xy - float2(0.5, 0.5)) / newScale * float2(ratio, 1.0);

  // This can probably be optimized (with distance())
  float angle = atan2(p.y, p.x) + angleOffset;
  float dist = distance(center, p);
  p.x = cos(angle) * dist / ratio + 0.5;
  p.y = sin(angle) * dist + 0.5;
  float4 c = progress < 0.5 ? getColor(p, fromTexture, ratio) : getColor(p, toTexture, ratio);

  // Finally, apply the color
  float4 outColor = c + (progress < 0.5 ? mix(0.0, 1.0, phase) : mix(1.0, 0.0, phase));
  outputTexture.write(outColor, gid);
}
