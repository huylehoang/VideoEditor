/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float perlin_random(float2 co, float seed) {
  float a = seed;
  float b = 78.233;
  float c = 43758.5453;
  float dt= dot(co.xy ,float2(a,b));
  float sn= mod(dt,3.14);
  return fract(sin(sn) * c);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float perlin_noise(float2 st, float seed) {
  float2 i = floor(st);
  float2 f = fract(st);

  // Four corners in 2D of a tile
  float a = perlin_random(i, seed);
  float b = perlin_random(i + float2(1.0, 0.0), seed);
  float c = perlin_random(i + float2(0.0, 1.0), seed);
  float d = perlin_random(i + float2(1.0, 1.0), seed);

  // Smooth Interpolation

  // Cubic Hermine Curve.  Same as SmoothStep()
  float2 u = f*f*(3.0-2.0*f);
  // u = smoothstep(0.,1.,f);

  // Mix 4 coorners porcentages
  return mix(a, b, u.x) +
  (c - a)* u.y * (1.0 - u.x) +
  (d - b) * u.x * u.y;
}

kernel void PerlinTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                             texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                             texture2d<float, access::sample> toTexture [[ texture(2) ]],
                             constant float & ratio [[ buffer(0) ]],
                             constant float & progress [[ buffer(1) ]],
                             constant float & scale [[ buffer(2) ]],
                             constant float & seed [[ buffer(3) ]],
                             constant float & smoothness [[ buffer(4) ]],
                             uint2 gid [[ thread_position_in_grid ]],
                             uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toTolor = getColor(uv, toTexture, ratio);
  float n = perlin_noise(uv * scale, seed);

  float p = mix(-smoothness, 1.0 + smoothness, progress);
  float lower = p - smoothness;
  float higher = p + smoothness;

  float q = smoothstep(lower, higher, n);

  float4 outColor = mix(fromColor, toTolor, 1.0 - q);
  outputTexture.write(outColor, gid);
}
