/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: bobylito
// license: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void PolkaDotsCurtainTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                       texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                       texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                       constant float & ratio [[ buffer(0) ]],
                                       constant float & progress [[ buffer(1) ]],
                                       constant float & dots [[ buffer(2) ]],
                                       constant float2 & center [[ buffer(3) ]],
                                       uint2 gid [[ thread_position_in_grid ]],
                                       uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  //const float SQRT_2 = 1.414213562373;
  bool nextImage = distance(fract(uv * dots), float2(0.5, 0.5)) < ( progress / distance(uv, center));
  float4 outColor = nextImage ? getColor(uv, toTexture, ratio) : getColor(uv, fromTexture, ratio);
  outputTexture.write(outColor, gid);
}
