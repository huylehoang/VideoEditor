/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void SqueezeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                              texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                              texture2d<float, access::sample> toTexture [[ texture(2) ]],
                              constant float & ratio [[ buffer(0) ]],
                              constant float & progress [[ buffer(1) ]],
                              constant float & colorSeparation [[ buffer(2) ]],
                              uint2 gid [[ thread_position_in_grid ]],
                              uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float y = 0.5 + (uv.y-0.5) / (1.0-progress);
  float4 outColor;
  if (y < 0.0 || y > 1.0) {
    outColor = getColor(uv, toTexture, ratio);
  } else {
    float2 fp = float2(uv.x, y);
    float2 off = progress * float2(0.0, colorSeparation);
    float4 c = getColor(fp, fromTexture, ratio);
    float4 cn = getColor(fp - off, fromTexture, ratio);
    float4 cp = getColor(fp + off, fromTexture, ratio);
    outColor = float4(cn.r, c.g, cp.b, c.a);
  }
  outputTexture.write(outColor, gid);
}
