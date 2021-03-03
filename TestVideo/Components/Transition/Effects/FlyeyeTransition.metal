/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void FlyeyeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant float & colorSeparation [[ buffer(2) ]],
                             constant float & zoom [[ buffer(3) ]],
                             constant float & size [[ buffer(4) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float inv = 1.0 - progress;
  float2 disp = size * float2(cos(zoom * uv.x), sin(zoom * uv.y));
  float4 texTo = getColor(uv + inv * disp, toTexture, ratio);
  float4 texFrom = float4(getColor(uv + progress * disp * (1.0 - colorSeparation), fromTexture, ratio).r,
                          getColor(uv + progress * disp, fromTexture, ratio).g,
                          getColor(uv + progress * disp * (1.0 + colorSeparation), fromTexture, ratio).b,
                          1.0);
  float4 outColor = texTo * progress + texFrom * inv;
  outputTexture.write(outColor, gid);
}
