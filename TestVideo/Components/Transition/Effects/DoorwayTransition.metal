/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: gre

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

bool doorway_inBounds (float2 p) {
    const float2 boundMin = float2(0.0, 0.0);
    const float2 boundMax = float2(1.0, 1.0);
    return all(boundMin < p) && all(p < boundMax);
}

float2 doorway_project (float2 p) {
    return p * float2(1.0, -1.2) + float2(0.0, -0.02);
}

float4 doorway_bgColor(float2 p,
                       float2 pto,
                       float reflection,
                       texture2d<float, access::sample> toTexture,
                       float ratio) {
    const float4 black = float4(0.0, 0.0, 0.0, 1.0);
    float4 c = black;
    pto = doorway_project(pto);
    if (doorway_inBounds(pto)) {
        c += mix(black, getColor(pto, toTexture, ratio), reflection * mix(1.0, 0.0, pto.y));
    }
    return c;
}

kernel void DoorwayTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                              texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                              texture2d<float, access::sample> toTexture [[ texture(2) ]],
                              constant float & ratio [[ buffer(0) ]],
                              constant float & progress [[ buffer(1) ]],
                              constant float & depth [[ buffer(2) ]],
                              constant float & reflection [[ buffer(3) ]],
                              constant float & perspective [[ buffer(4) ]],
                              uint2 gid [[ thread_position_in_grid ]],
                              uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 pfr = float2(-1.), pto = float2(-1.);
  float middleSlit = 2.0 * abs(uv.x-0.5) - progress;
  if (middleSlit > 0.0) {
      pfr = uv + (uv.x > 0.5 ? -1.0 : 1.0) * float2(0.5 * progress, 0.0);
      float d = 1.0/(1.0 + perspective * progress*(1.0 - middleSlit));
      pfr.y -= d/2.0;
      pfr.y *= d;
      pfr.y += d/2.0;
  }
  float size = mix(1.0, depth, 1.0 - progress);
  pto = (uv + float2(-0.5, -0.5)) * float2(size, size) + float2(0.5, 0.5);
  if (doorway_inBounds(pfr)) {
    outputTexture.write(getColor(pfr, fromTexture, ratio), gid);
  } else if (doorway_inBounds(pto)) {
    outputTexture.write(getColor(pto, toTexture, ratio), gid);
  } else {
    outputTexture.write(doorway_bgColor(uv, pto, reflection, toTexture, ratio), gid);
  }
}
