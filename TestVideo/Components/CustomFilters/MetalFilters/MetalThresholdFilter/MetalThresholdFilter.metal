/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage

#include <metal_stdlib>
using namespace metal;

constant half3 kRec709Luma  = half3(0.2126, 0.7152, 0.0722);

kernel void metalThreshold(texture2d<half, access::write> outputTexture [[texture(0)]],
                           texture2d<half, access::read> inputTexture [[texture(1)]],
                           constant float *threshold [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  const half4 inColor = inputTexture.read(gid);
  const half luma = dot(inColor.rbg, kRec709Luma);
  const half value = step(half(*threshold), luma);
  const half4 outColor(half3(value), inColor.a);
  outputTexture.write(outColor, gid);
}
