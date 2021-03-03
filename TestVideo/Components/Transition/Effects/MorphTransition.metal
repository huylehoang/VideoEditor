/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: paniq
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void MorphTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                            texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                            texture2d<float, access::sample> toTexture [[ texture(2) ]],
                            constant float & ratio [[ buffer(0) ]],
                            constant float & progress [[ buffer(1) ]],
                            constant float & strength [[ buffer(2) ]],
                            uint2 gid [[ thread_position_in_grid ]],
                            uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 ca = getColor(uv, fromTexture, ratio);
  float4 cb = getColor(uv, toTexture, ratio);
  float2 oa = (((ca.rg + ca.b) * 0.5) * 2.0 - 1.0);
  float2 ob = (((cb.rg + cb.b) * 0.5) * 2.0 - 1.0);
  float2 oc = mix(oa, ob, 0.5) * strength;

  float w0 = progress;
  float w1 = 1.0 - w0;
  float4 outColor = mix(getColor(uv + oc * w0, fromTexture, ratio),
                        getColor(uv - oc * w1, toTexture, ratio),
                        progress);
  outputTexture.write(outColor, gid);
}
