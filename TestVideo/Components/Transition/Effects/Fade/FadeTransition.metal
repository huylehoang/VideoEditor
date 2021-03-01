#include <metal_stdlib>
using namespace metal;

kernel void FadeTransition(texture2d<half, access::write> outputTexture [[ texture(0) ]],
                               texture2d<half, access::read> fromTexture [[ texture(1) ]],
                               texture2d<half, access::sample> toTexture [[ texture(2) ]],
                               constant float & ratio [[ buffer(0) ]],
                               constant float & progress [[ buffer(1) ]],
                               uint2 gid [[ thread_position_in_grid ]]) {
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
  const half4 fromTextureColor = fromTexture.read(gid);
  const half4 toTextureColor = toTexture.sample(quadSampler,
                                                float2(float(gid.x) / outputTexture.get_width(),
                                                       float(gid.y) / outputTexture.get_height()));
  const half4 outColor = mix(fromTextureColor, toTextureColor, progress);
  outputTexture.write(outColor, gid);
}
