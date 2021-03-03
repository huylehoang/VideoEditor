/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: Fernando Kuteken
// License: MIT
// Hexagonal math from: http://www.redblobgames.com/grids/hexagons/

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

struct Hexagon {
  float q;
  float r;
  float s;
};

Hexagon createHexagon(float q, float r){
  Hexagon hex;
  hex.q = q;
  hex.r = r;
  hex.s = -q - r;
  return hex;
}

Hexagon roundHexagon(Hexagon hex){
  float q = floor(hex.q + 0.5);
  float r = floor(hex.r + 0.5);
  float s = floor(hex.s + 0.5);

  float deltaQ = abs(q - hex.q);
  float deltaR = abs(r - hex.r);
  float deltaS = abs(s - hex.s);

  if (deltaQ > deltaR && deltaQ > deltaS)
    q = -r - s;
  else if (deltaR > deltaS)
    r = -q - s;
  else
    s = -q - r;

  return createHexagon(q, r);
}

Hexagon hexagonFromPoint(float2 point, float size, float ratio) {
  point.y /= ratio;
  point = (point - 0.5) / size;

  float q = (sqrt(3.0) / 3.0) * point.x + (-1.0 / 3.0) * point.y;
  float r = 0.0 * point.x + 2.0 / 3.0 * point.y;

  Hexagon hex = createHexagon(q, r);
  return roundHexagon(hex);
}

float2 pointFromHexagon(Hexagon hex, float size, float ratio) {
  float x = (sqrt(3.0) * hex.q + (sqrt(3.0) / 2.0) * hex.r) * size + 0.5;
  float y = (0.0 * hex.q + (3.0 / 2.0) * hex.r) * size + 0.5;

  return float2(x, y * ratio);
}

kernel void HexagonalizeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                   texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                   texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                   constant float & ratio [[ buffer(0) ]],
                                   constant float & progress [[ buffer(1) ]],
                                   constant int & steps [[ buffer(2) ]],
                                   constant float & horizontalHexagons [[ buffer(3) ]],
                                   uint2 gid [[ thread_position_in_grid ]],
                                   uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float dist = 2.0 * min(progress, 1.0 - progress);
  dist = steps > 0 ? ceil(dist * float(steps)) / float(steps) : dist;
  float size = (sqrt(3.0) / 3.0) * dist / horizontalHexagons;
  float2 point = dist > 0.0 ? pointFromHexagon(hexagonFromPoint(uv, size, ratio), size, ratio) : uv;
  float4 outColor = mix(getColor(point, fromTexture, ratio),
                        getColor(point, toTexture, ratio),
                        progress);
  outputTexture.write(outColor, gid);
}
