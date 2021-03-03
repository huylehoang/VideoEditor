/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float inHeart(float2 p, float2 center, float size) {
  if (size == 0.0) {
    return 0.0;
  }
  float2 o = (p - center) / (1.6 * size);
  float a = o.x * o.x + o.y * o.y - 0.3;
  return step(a * a * a, o.x * o.x * o.y * o.y * o.y);
}

kernel void HeartTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                            texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                            texture2d<float, access::sample> toTexture [[ texture(2) ]],
                            constant float & ratio [[ buffer(0) ]],
                            constant float & progress [[ buffer(1) ]],
                            uint2 gid [[ thread_position_in_grid ]],
                            uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 outColor = mix(getColor(uv, fromTexture, ratio),
                        getColor(uv, toTexture, ratio),
                        inHeart(uv, float2(0.5, 0.4), progress));
  outputTexture.write(outColor, gid);
}
