/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float4 blend(float4 a, float4 b) {
    return a * b;
}

kernel void MultiplyBlendTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float4 blended = blend(fromColor, toColor);
  if (progress < 0.5) {
    outputTexture.write(mix(fromColor, blended, 2.0 * progress), gid);
  } else {
    outputTexture.write(mix(blended, toColor, 2.0 * progress - 1.0), gid);
  }
}
