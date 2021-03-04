/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT
// forked from https://gist.github.com/benraziel/c528607361d90a072e98

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void PixelizeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                               texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                               texture2d<float, access::sample> toTexture [[ texture(2) ]],
                               constant float & ratio [[ buffer(0) ]],
                               constant float & progress [[ buffer(1) ]],
                               constant uint2 & squaresMin [[ buffer(2) ]],
                               constant int & steps [[ buffer(3) ]],
                               uint2 gid [[ thread_position_in_grid ]],
                               uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float d = min(progress, 1.0 - progress);
  float dist = steps >0 ? ceil(d * float(steps)) / float(steps) : d;
  float2 squareSize = 2.0 * dist / float2(squaresMin);
  float2 p = dist>0.0 ? (floor(uv / squareSize) + 0.5) * squareSize : uv;
  float4 outColor = mix(getColor(p, fromTexture, ratio),
                        getColor(p, toTexture, ratio),
                        progress);
  outputTexture.write(outColor, gid);
}
