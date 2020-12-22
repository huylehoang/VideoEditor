#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>
using namespace coreimage;

extern "C" float4 kernelThresholdFilter(sample_t s, float threshold) {
  float luma = dot(s.rgb, float3(0.2126, 0.7152, 0.0722));
  float value = step(threshold, luma);
  float3 rgb = float3(value);
  return float4(rgb, s.a);
}
