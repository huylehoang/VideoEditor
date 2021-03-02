#ifndef VideoTransition_h
#define VideoTransition_h

#include <metal_stdlib>
using namespace metal;

float getTextureR(texture2d<float, access::sample> texture) {
  return float(texture.get_width())/float(texture.get_height());
}

float2 cover(float2 uv, float ratio, float r) {
  return 0.5 + (uv - 0.5) * float2(min(ratio/r, 1.0), min(r/ratio, 1.0));
}

float4 getColor(float2 uv, texture2d<float, access::sample> texture, float ratio) {
  constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
  float _textureR = getTextureR(texture);
  float2 _uv = cover(uv, ratio, _textureR);
  return texture.sample(s, _uv);
}

#endif /* VideoTransition_h */
