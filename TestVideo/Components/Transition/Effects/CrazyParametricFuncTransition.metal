/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: mandubian
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CrazyParametricFunTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                         texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                         texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                         constant float & ratio [[ buffer(0) ]],
                                         constant float & progress [[ buffer(1) ]],
                                         constant float & a [[ buffer(2) ]],
                                         constant float & b [[ buffer(3) ]],
                                         constant float & smoothness [[ buffer(4) ]],
                                         constant float & amplitude [[ buffer(5) ]],
                                         uint2 gid [[ thread_position_in_grid ]],
                                         uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv.xy / float2(1.0).xy;
  float2 dir = p - float2(.5);
  float dist = length(dir);
  float x = (a - b) * cos(progress) + b * cos(progress * ((a / b) - 1.0));
  float y = (a - b) * sin(progress) - b * sin(progress * ((a / b) - 1.0));
  float2 offset = dir * float2(sin(progress  * dist * amplitude * x), sin(progress * dist * amplitude * y)) / smoothness;
  float4 outColor = mix(getColor(p + offset, fromTexture, ratio),
                        getColor(p, toTexture, ratio),
                        smoothstep(0.2, 1.0, progress));
  outputTexture.write(outColor, gid);
}

