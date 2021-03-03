/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// license: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void LinearBlurTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  const int passes = 6;
  float4 c1 = float4(0.0);
  float4 c2 = float4(0.0);
  float disp = intensity * (0.5 - abs(0.5 - progress));
  for (int xi = 0; xi < passes; xi++) {
      float x = float(xi) / float(passes) - 0.5;
      for (int yi = 0; yi < passes; yi++)
      {
          float y = float(yi) / float(passes) - 0.5;
          float2 v = float2(x, y);
          float d = disp;
          c1 += getColor(uv + d * v, fromTexture, ratio);
          c2 += getColor(uv + d * v, toTexture, ratio);
      }
  }
  c1 /= float(passes * passes);
  c2 /= float(passes * passes);
  float4 outColor = mix(c1, c2, progress);
  outputTexture.write(outColor, gid);
}
