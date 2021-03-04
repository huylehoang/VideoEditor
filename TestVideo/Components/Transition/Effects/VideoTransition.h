/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

#ifndef VideoTransition_h
#define VideoTransition_h

#define PI 3.141592653589
#define M_PI   3.14159265358979323846

#include <metal_stdlib>
using namespace metal;

namespace metal {
  METAL_FUNC float getTextureR(texture2d<float, access::sample> texture) {
    return float(texture.get_width())/float(texture.get_height());
  }

  METAL_FUNC float2 cover(float2 uv, float ratio, float r) {
    return 0.5 + (uv - 0.5) * float2(min(ratio/r, 1.0), min(r/ratio, 1.0));
  }

  METAL_FUNC float4 getColor(float2 uv, texture2d<float, access::sample> texture, float ratio) {
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float _textureR = getTextureR(texture);
    float2 _uv = cover(uv, ratio, _textureR);
    return texture.sample(s, _uv);
  }

  METAL_FUNC float rand(float2 co){
    return fract(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
  }

  template <typename T, typename _E = typename enable_if<is_floating_point<typename make_scalar<T>::type>::value>::type>
  METAL_FUNC T mod(T x, T y) {
      return x - y * floor(x/y);
  }
}


#endif /* VideoTransition_h */
