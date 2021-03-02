/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: @Flexi23
// License: MIT
// inspired by http://www.wolframalpha.com/input/?i=cannabis+curve

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void CannabisleafTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  if(progress == 0.0){
    outputTexture.write(fromColor, gid);
    return;
  }
  float2 leaf_uv = (uv - float2(0.5))/10./pow(progress,3.5);
  leaf_uv.y += 0.35;
  float r = 0.18;
  float o = atan2(leaf_uv.y, leaf_uv.x);
  float4 c = 1.0 - step(1.0 - length(leaf_uv) + r * (1.0 + sin(o)) * (1.0 + 0.9 * cos(8.0 * o)) * (1.0 + 0.1 * cos(24.0 * o)) * (0.9+0.05*cos(200.0 * o)), 1.0);
  float4 outColor = mix(fromColor, toColor, c);
  outputTexture.write(outColor, gid);
}
