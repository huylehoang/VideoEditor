/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage

#include <metal_stdlib>
using namespace metal;

// Luminance Constants
// Values from "Graphics Shaders: Theory and Practice" by Bailey and Cunningham
constant half3 kLuminanceWeighting = half3(0.2125, 0.7154, 0.0721);

kernel void metalSaturation(texture2d<half, access::write> outputTexture [[texture(0)]],
                            texture2d<half, access::read> inputTexture [[texture(1)]],
                            constant float *saturation [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  const half4 inColor = inputTexture.read(gid);
  const half luminance = dot(inColor.rgb, kLuminanceWeighting);
  const half4 outColor(mix(half3(luminance), inColor.rgb, half(*saturation)), inColor.a);
  outputTexture.write(outColor, gid);
}
