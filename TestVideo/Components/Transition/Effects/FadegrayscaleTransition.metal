/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float3 grayscale (float3 color) {
    return float3(0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b);
}

kernel void FadegrayscaleTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                    texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                    constant float & ratio [[ buffer(0) ]],
                                    constant float & progress [[ buffer(1) ]],
                                    constant float & intensity [[ buffer(2) ]],
                                    uint2 gid [[ thread_position_in_grid ]],
                                    uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float4 outColor = mix(mix(float4(grayscale(fromColor.rgb), 1.0), fromColor, smoothstep(1.0-intensity, 0.0, progress)),
                        mix(float4(grayscale(toColor.rgb), 1.0), toColor, smoothstep(intensity, 1.0, progress)),
                        progress);
  outputTexture.write(outColor, gid);
}
