/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage

#include <metal_stdlib>
using namespace metal;

kernel void metalSourceOverlay(texture2d<half, access::write> outputTexture [[texture(0)]],
                               texture2d<half, access::read> inputTexture [[texture(1)]],
                               texture2d<half, access::sample> inputTexture2 [[texture(2)]],
                               uint2 gid [[thread_position_in_grid]]) {
  
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  
  const half4 textureColor = inputTexture.read(gid);
  constexpr sampler quadSampler(mag_filter::linear, min_filter::linear);
  const half4 textureColor2 = inputTexture2.sample(quadSampler, float2(float(gid.x) / outputTexture.get_width(), float(gid.y) / outputTexture.get_height()));
  
  const half4 outColor = mix(textureColor, textureColor2, textureColor2.a);
  outputTexture.write(outColor, gid);
}
