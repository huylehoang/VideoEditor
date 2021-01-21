#include <metal_stdlib>
using namespace metal;

#include <CoreImage/CoreImage.h>
using namespace coreimage;

extern "C" float4 kernelHDRZebraFilter(sample_t s, float time, destination dest) {
  float diagline = dest.coord().x + dest.coord().y;
  float zebra = fract(diagline/20 + time*2.0);
  if ((zebra > 0.5) && (s.r > 1 || s.b > 1 || s.g > 1))
    return float4(2.0, 0.0, 0.0, 1.0);
  return s;
}
