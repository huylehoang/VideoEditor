/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: mikolalysenko
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float2 offset(float progress, float x, float theta) {
    //float phase = progress * progress + progress + theta;
    float shifty = 0.03 * progress * cos(10.0*(progress + x));
    return float2(0, shifty);
}

kernel void DreamyTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                              texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                              texture2d<float, access::sample> toTexture [[ texture(2) ]],
                              constant float & ratio [[ buffer(0) ]],
                              constant float & progress [[ buffer(1) ]],
                              uint2 gid [[ thread_position_in_grid ]],
                              uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 outColor = mix(getColor(uv + offset(progress, uv.x, 0.0), fromTexture, ratio),
                        getColor(uv + offset(1.0 - progress, uv.x, 3.14), toTexture, ratio),
                        progress);
  outputTexture.write(outColor, gid);
}
