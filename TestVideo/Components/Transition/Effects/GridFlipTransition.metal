/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: TimDonselaar
// ported by gre from https://gist.github.com/TimDonselaar/9bcd1c4b5934ba60087bdb55c2ea92e5

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float getDelta(float2 p, int2 size) {
  float2 rectanglePos = floor(float2(size) * p);
  float2 rectangleSize = float2(1.0 / float2(size).x, 1.0 / float2(size).y);
  float top = rectangleSize.y * (rectanglePos.y + 1.0);
  float bottom = rectangleSize.y * rectanglePos.y;
  float left = rectangleSize.x * rectanglePos.x;
  float right = rectangleSize.x * (rectanglePos.x + 1.0);
  float minX = min(abs(p.x - left), abs(p.x - right));
  float minY = min(abs(p.y - top), abs(p.y - bottom));
  return min(minX, minY);
}

float getDividerSize(int2 size, float dividerWidth) {
  float2 rectangleSize = float2(1.0 / float2(size).x, 1.0 / float2(size).y);
  return min(rectangleSize.x, rectangleSize.y) * dividerWidth;
}

kernel void GridFlipTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                               texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                               texture2d<float, access::sample> toTexture [[ texture(2) ]],
                               constant float & ratio [[ buffer(0) ]],
                               constant float & progress [[ buffer(1) ]],
                               constant float4 & bgColor [[ buffer(2) ]],
                               constant float & randomness [[ buffer(3) ]],
                               constant float & pause [[ buffer(4) ]],
                               constant float & dividerWidth [[ buffer(5) ]],
                               constant int2 & size [[ buffer(6) ]],
                               uint2 gid [[ thread_position_in_grid ]],
                               uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);

  if(progress < pause) {
    float currentProg = progress / pause;
    float a = 1.0;
    if(getDelta(uv, size) < getDividerSize(size, dividerWidth)) {
      a = 1.0 - currentProg;
    }
    outputTexture.write(mix(bgColor, fromColor, a), gid);
  } else if(progress < 1.0 - pause){
    if(getDelta(uv, size) < getDividerSize(size, dividerWidth)) {
      outputTexture.write(bgColor, gid);
    } else {
      float currentProg = (progress - pause) / (1.0 - pause * 2.0);
      float2 q = uv;
      float2 rectanglePos = floor(float2(size) * q);

      float r = rand(rectanglePos) - randomness;
      float cp = smoothstep(0.0, 1.0 - r, currentProg);

      float rectangleSize = 1.0 / float2(size).x;
      float delta = rectanglePos.x * rectangleSize;
      float offset = rectangleSize / 2.0 + delta;

      uv.x = (uv.x - offset)/abs(cp - 0.5)*0.5 + offset;
      float4 a = getColor(uv, fromTexture, ratio);
      float4 b = getColor(uv, toTexture, ratio);

      float s = step(abs(float2(size).x * (q.x - delta) - 0.5), abs(cp - 0.5));
      float4 outColor = mix(bgColor, mix(b, a, step(cp, 0.5)), s);
      outputTexture.write(outColor, gid);
    }
  } else {
    float currentProg = (progress - 1.0 + pause) / pause;
    float a = 1.0;
    if(getDelta(uv, size) < getDividerSize(size, dividerWidth)) {
      a = currentProg;
    }
    float4 outColor = mix(bgColor, toColor, a);
    outputTexture.write(outColor, gid);
  }
}
