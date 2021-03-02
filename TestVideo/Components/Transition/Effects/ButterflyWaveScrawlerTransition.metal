/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: mandubian
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float compute(float2 p, float progress, float2 center, float amplitude, float waves) {
  float2 o = p * sin(progress * amplitude) - center;
  // horizontal vector
  float2 h = float2(1.0, 0.0);
  // butterfly polar function (don't ask me why this one :))
  float theta = acos(dot(o, h)) * waves;
  return (exp(cos(theta)) - 2.0 * cos(4.0 * theta) + pow(sin((2.0 * theta - PI) / 24.), 5.0)) / 10.0;
}

kernel void ButterflyWaveScrawlerTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                            texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                            texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                            constant float & ratio [[ buffer(0) ]],
                                            constant float & progress [[ buffer(1) ]],
                                            constant float & colorSeparation [[ buffer(2) ]],
                                            constant float & amplitude [[ buffer(3) ]],
                                            constant float & waves [[ buffer(4) ]],
                                            uint2 gid [[ thread_position_in_grid ]],
                                            uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv.xy / float2(1.0).xy;
  float inv = 1.0 - progress;
  float disp = compute(p, progress, float2(0.5, 0.5), amplitude, waves);
  float4 texTo = getColor(p + inv*disp, toTexture, ratio);
  float4 texFrom = float4(getColor(p + progress*disp*(1.0 - colorSeparation), fromTexture, ratio).r,
                          getColor(p + progress*disp, fromTexture, ratio).g,
                          getColor(p + progress*disp*(1.0 + colorSeparation), fromTexture, ratio).b,
                          1.0);
  float4 outColor = texTo * progress + texFrom * inv;
  outputTexture.write(outColor, gid);
}
