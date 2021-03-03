/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Gunnar Roth
// Based on work from natewave
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void GlitchMemoriesTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float2 block = floor(uv.xy / float2(16));
  float2 uv_noise = block / float2(64);
  uv_noise += floor(float2(progress) * float2(1200.0, 3500.0)) / float2(64);
  float2 dist = progress > 0.0 ? (fract(uv_noise) - 0.5) * 0.3 * (1.0 - progress) : float2(0.0);
  float2 red = uv + dist * 0.2;
  float2 green = uv + dist * 0.3;
  float2 blue = uv + dist * 0.5;
  float r = mix(getColor(red, fromTexture, ratio),
                getColor(red, toTexture, ratio),
                progress).r;
  float g = mix(getColor(green, fromTexture, ratio),
                getColor(green, toTexture, ratio),
                progress).g;
  float b = mix(getColor(blue, fromTexture, ratio),
                getColor(blue, toTexture, ratio),
                progress).b;
  float4 outColor = float4(r, g, b, 1.0);
  outputTexture.write(outColor, gid);
}
