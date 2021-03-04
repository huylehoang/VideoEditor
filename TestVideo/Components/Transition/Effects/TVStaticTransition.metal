/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: pthrasher
// adapted by gre from https://gist.github.com/pthrasher/8e6226b215548ba12734

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

// Pseudo-random noise function
// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float noise(float2 co, float progress)
{
  float a = 12.9898;
  float b = 78.233;
  float c = 43758.5453;
  float dt= dot(co.xy * progress, float2(a, b));
  float sn= mod(dt,3.14);
  return fract(sin(sn) * c);
}

kernel void TVStaticTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                               texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                               texture2d<float, access::sample> toTexture [[ texture(2) ]],
                               constant float & ratio [[ buffer(0) ]],
                               constant float & progress [[ buffer(1) ]],
                               constant float & offset [[ buffer(2) ]],
                               uint2 gid [[ thread_position_in_grid ]],
                               uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;

  float4 outColor;
  if (progress < offset) {
    outColor = getColor(uv, fromTexture, ratio);
  } else if (progress > (1.0 - offset)) {
    outColor = getColor(uv, toTexture, ratio);
  } else {
    outColor = float4(float3(noise(uv, progress)), 1.0);
  }
  outputTexture.write(outColor, gid);
}
