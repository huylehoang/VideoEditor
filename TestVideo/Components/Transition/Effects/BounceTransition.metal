/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Adrian Purser
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

kernel void BounceTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant float & bounces [[ buffer(2) ]],
                             constant float4 & shadowColour [[ buffer(3) ]],
                             constant float & shadowHeight [[ buffer(4) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float time = progress;
  float stime = sin(time * PI/2.0);
  float phase = time * PI * bounces;
  float y = abs(cos(phase)) * (1 - stime);
  float d = uv.y - y;
  float4 shadow = ((d/shadowHeight) * shadowColour.a) + (1.0 - shadowColour.a);
  float4 smooth = step(d, shadowHeight) * (1.0 - mix(shadow, 1.0, smoothstep(0.95, 1.0, progress)));
  float4 fromColor = getColor(float2(uv.x, uv.y + (1.0 - y)), fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  float4 outColor = mix(mix(toColor, shadowColour, smooth), fromColor, step(d, 0.0));
  outputTexture.write(outColor, gid);
}
