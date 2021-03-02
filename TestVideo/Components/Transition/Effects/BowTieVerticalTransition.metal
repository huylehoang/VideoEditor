/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float vertical_check(float2 p1, float2 p2, float2 p3) {
  return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool vertical_pointInTriangle (float2 pt, float2 p1, float2 p2, float2 p3) {
  bool b1, b2, b3;
  b1 = vertical_check(pt, p1, p2) < 0.0;
  b2 = vertical_check(pt, p2, p3) < 0.0;
  b3 = vertical_check(pt, p3, p1) < 0.0;
  return ((b1 == b2) && (b2 == b3));
}

bool in_top_triangle(float2 p, float progress) {
  float2 vertex1, vertex2, vertex3;
  vertex1 = float2(0.5, progress);
  vertex2 = float2(0.5 - progress, 0.0);
  vertex3 = float2(0.5 + progress, 0.0);
  if (vertical_pointInTriangle(p, vertex1, vertex2, vertex3))
  {
    return true;
  }
  return false;
}

bool in_bottom_triangle(float2 p, float progress) {
  float2 vertex1, vertex2, vertex3;
  vertex1 = float2(0.5, 1.0 - progress);
  vertex2 = float2(0.5-progress, 1.0);
  vertex3 = float2(0.5+progress, 1.0);
  if (vertical_pointInTriangle(p, vertex1, vertex2, vertex3))
  {
    return true;
  }
  return false;
}

float vertical_blur_edge(float2 bot1, float2 bot2, float2 top, float2 testPt) {
  float2 lineDir = bot1 - top;
  float2 perpDir = float2(lineDir.y, -lineDir.x);
  float2 dirToPt1 = bot1 - testPt;
  float dist1 = abs(dot(normalize(perpDir), dirToPt1));
  
  lineDir = bot2 - top;
  perpDir = float2(lineDir.y, -lineDir.x);
  dirToPt1 = bot2 - testPt;
  float min_dist = min(abs(dot(normalize(perpDir), dirToPt1)), dist1);
  
  if (min_dist < 0.005) {
    return min_dist / 0.005;
  } else {
    return 1.0;
  }
}

kernel void BowTieVerticalTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
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
  float4 fromColor = getColor(uv, fromTexture, ratio);
  float4 toColor = getColor(uv, toTexture, ratio);
  if (in_top_triangle(uv, progress)) {
    if (progress < 0.1) {
      outputTexture.write(fromColor, gid);
      return;
    }
    if (uv.y < 0.5) {
      float2 vertex1 = float2(0.5, progress);
      float2 vertex2 = float2(0.5-progress, 0.0);
      float2 vertex3 = float2(0.5+progress, 0.0);
      float vBlurEdge = vertical_blur_edge(vertex2, vertex3, vertex1, uv);
      float4 outColor = mix(fromColor, toColor, vBlurEdge);
      outputTexture.write(outColor, gid);
    } else {
      if (progress > 0.0) {
        outputTexture.write(toColor, gid);
      } else {
        outputTexture.write(fromColor, gid);
      }
    }
  } else if (in_bottom_triangle(uv, progress)) {
    if (uv.y >= 0.5) {
      float2 vertex1 = float2(0.5, 1.0-progress);
      float2 vertex2 = float2(0.5-progress, 1.0);
      float2 vertex3 = float2(0.5+progress, 1.0);
      float vBlurEdge = vertical_blur_edge(vertex2, vertex3, vertex1, uv);
      float4 outColor = mix(fromColor, toColor, vBlurEdge);
      outputTexture.write(outColor, gid);
    } else {
      outputTexture.write(fromColor, gid);
    }
  } else {
    outputTexture.write(fromColor, gid);
  }
}