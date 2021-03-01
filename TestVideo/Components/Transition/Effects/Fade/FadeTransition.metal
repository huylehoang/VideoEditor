#include <metal_stdlib>
using namespace metal;

float2 cover(float2 uv, float ratio, float r) {
  return 0.5 + (uv - 0.5) * float2(min(ratio/r, 1.0), min(r/ratio, 1.0));
}

float4 getFromColor(float2 uv, texture2d<float, access::sample> texture, float ratio, float _fromR) {
  constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
  float2 _uv = cover(uv, ratio, _fromR);
  return texture.sample(s, _uv);
}

float4 getToColor(float2 uv, texture2d<float, access::sample> texture, float ratio, float _toR) {
  constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
  float2 _uv = cover(uv, ratio, _toR);
  return texture.sample(s, _uv);
}

kernel void FadeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float _fromR = float(fromTexture.get_width())/float(fromTexture.get_height());
  float _toR = float(toTexture.get_width())/float(toTexture.get_height());
  float4 a = getFromColor(uv, fromTexture, ratio, _fromR);
  float4 b = getToColor(uv, toTexture, ratio, _toR);
  float4 outColor = mix(a, b, progress);
  outputTexture.write(outColor, gid);
}
