/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: nwoeanhinnogaehr
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void KaleidoScopeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                   texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                   texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                   constant float & ratio [[ buffer(0) ]],
                                   constant float & progress [[ buffer(1) ]],
                                   constant float & angle [[ buffer(2) ]],
                                   constant float & speed [[ buffer(3) ]],
                                   constant float & power [[ buffer(4) ]],
                                   uint2 gid [[ thread_position_in_grid ]],
                                   uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 p = uv.xy / float2(1.0).xy;
  float2 q = p;
  float t = pow(progress, power)*speed;
  p = p -0.5;
  for (int i = 0; i < 7; i++) {
    p = float2(sin(t)*p.x + cos(t)*p.y, sin(t)*p.y - cos(t)*p.x);
    t += angle;
    p = abs(fmod(p, 2.0) - 1.0);
  }
  abs(fmod(p, 1.0));
  float4 outColor = mix(mix(getColor(q, fromTexture, ratio),
                            getColor(q, toTexture, ratio), progress),
                        mix(getColor(p, fromTexture, ratio),
                            getColor(p, toTexture, ratio), progress),
                        1.0 - 2.0*abs(progress - 0.5));
  outputTexture.write(outColor, gid);
}
