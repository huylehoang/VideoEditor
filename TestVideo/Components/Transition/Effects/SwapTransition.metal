/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

bool swap_inBounds (float2 p) {
  const float2 boundMin = float2(0.0, 0.0);
  const float2 boundMax = float2(1.0, 1.0);
  return all(boundMin < p) && all(p < boundMax);
}

float2 swap_project (float2 p) {
  return p * float2(1.0, -1.2) + float2(0.0, -0.02);
}

kernel void SwapTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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

  float2 pfr, pto = float2(-1.);

  float size = mix(1.0, depth, progress);
  float persp = perspective * progress;
  pfr = (uv + float2(-0.0, -0.5)) * float2(size/(1.0 - perspective*progress), size/(1.0 - size * persp * uv.x)) + float2(0.0, 0.5);

  size = mix(1.0, depth, 1.-progress);
  persp = perspective * (1.-progress);
  pto = (uv + float2(-1.0, -0.5)) * float2(size/(1.0-perspective*(1.0-progress)), size/(1.0-size*persp*(0.5-uv.x))) + float2(1.0, 0.5);

  if (progress < 0.5) {
    if (swap_inBounds(pfr)) {
      float4 outColor = getColor(pfr, fromTexture, ratio);
      outputTexture.write(outColor, gid);
      return;
    }
    if (swap_inBounds(pto)) {
      float4 outColor = getColor(pto, toTexture, ratio);
      outputTexture.write(outColor, gid);
      return;
    }
  }
  if (swap_inBounds(pto)) {
    float4 outColor = getColor(pto, toTexture, ratio);
    outputTexture.write(outColor, gid);
    return;
  }
  if (swap_inBounds(pfr)) {
    float4 outColor = getColor(pfr, fromTexture, ratio);
    outputTexture.write(outColor, gid);
    return;
  }

  const float4 black = float4(0.0, 0.0, 0.0, 1.0);
  float4 c = black;
  pfr = swap_project(pfr);
  if (swap_inBounds(pfr)) {
    c += mix(black, getColor(pfr, fromTexture, ratio), reflection * mix(1.0, 0.0, pfr.y));
  }
  pto = swap_project(pto);
  if (swap_inBounds(pto)) {
    c += mix(black, getColor(pto, toTexture, ratio), reflection * mix(1.0, 0.0, pto.y));
  }
  outputTexture.write(c, gid);
}
