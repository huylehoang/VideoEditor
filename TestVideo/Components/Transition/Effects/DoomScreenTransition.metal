/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Zeh Fernando
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float doomscreen_rand(int num) {
  return fract(mod(float(num) * 67123.313, 12.0) * sin(float(num) * 10.3) * cos(float(num)));
}

float doomscreen_wave(int num, int bars, float frequency) {
  float fn = float(num) * frequency * 0.1 * float(bars);
  return cos(fn * 0.5) * cos(fn * 0.13) * sin((fn+10.0) * 0.3) / 2.0 + 0.5;
}

float doomscreen_drip(int num, int bars, float dripScale) {
  return sin(float(num) / float(bars - 1) * 3.141592) * dripScale;
}

float doomscreen_pos(int num, int bars, float frequency, float dripScale, float noise) {
  return (noise == 0.0 ? doomscreen_wave(num, bars, frequency) : mix(doomscreen_wave(num, bars, frequency), doomscreen_rand(num), noise)) + (dripScale == 0.0 ? 0.0 : doomscreen_drip(num, bars, dripScale));
}

kernel void DoomScreenTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                 texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                 texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                 constant float & ratio [[ buffer(0) ]],
                                 constant float & progress [[ buffer(1) ]],
                                 constant float & dripScale [[ buffer(2) ]],
                                 constant int & bars [[ buffer(3) ]],
                                 constant float & noise [[ buffer(4) ]],
                                 constant float & frequency [[ buffer(5) ]],
                                 constant float & amplitude [[ buffer(6) ]],
                                 uint2 gid [[ thread_position_in_grid ]],
                                 uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  int bar = int(uv.x * (float(bars)));
  float scale = 1.0 + doomscreen_pos(bar, bars, frequency, dripScale, noise) * amplitude;
  float phase = progress * scale;
  float posY = uv.y / float2(1.0).y;
  float2 p;
  float4 c;
  if (phase + posY < 1.0) {
      p = float2(uv.x, uv.y + mix(0.0, float2(1.0).y, phase)) / float2(1.0).xy;
      c = getColor(p, fromTexture, ratio);
  } else {
      p = uv.xy / float2(1.0).xy;
      c = getColor(p, toTexture, ratio);
  }
  // Finally, apply the color
  outputTexture.write(c, gid);
}
