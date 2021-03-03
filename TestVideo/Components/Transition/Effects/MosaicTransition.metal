/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// License: MIT
// Author: Xaychru
// ported by gre from https://gist.github.com/Xaychru/130bb7b7affedbda9df5

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

#define POW2(X) X*X
#define POW3(X) X*X*X

float2 mosaicRotate(float2 v, float a) {
  float2x2 rm = float2x2(float2(cos(a), -sin(a)),
                         float2(sin(a), cos(a)));
  return rm*v;
}

float cosInterpolation(float x) {
  return -cos(x * M_PI_F) / 2.0 + 0.5;
}

kernel void MosaicTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant int & endy [[ buffer(2) ]],
                             constant int & endx [[ buffer(3) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv.xy / float2(1.0).xy - 0.5;
  float2 rp = p;
  float rpr = (progress * 2.0 - 1.0);
  float z = -(rpr * rpr * 2.0) + 3.0;
  float az = abs(z);
  rp *= az;
  rp += mix(float2(0.5, 0.5), float2(float(endx) + 0.5, float(endy) + 0.5), POW2(cosInterpolation(progress)));
  float2 mrp =  rp - 1.0 * floor(rp/1.0);
  float2 crp = rp;
  bool onEnd = int(floor(crp.x)) == endx && int(floor(crp.y)) == endy;
  if(!onEnd) {
    float ang = float(int(rand(floor(crp)) * 4.0)) * 0.5 * M_PI_F;
    mrp = float2(0.5) + mosaicRotate(mrp - float2(0.5), ang);
  }
  if(onEnd || rand(floor(crp)) > 0.5) {
    outputTexture.write(getColor(mrp, toTexture, ratio), gid);
  } else {
    outputTexture.write(getColor(mrp, fromTexture, ratio), gid);
  }
}
