/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: gre
// License: MIT

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float2 cube_project (float2 p, float floating) {
  return p * float2(1.0, -1.2) + float2(0.0, -floating/100.);
}

bool cube_inBounds (float2 p) {
  return all(float2(0.0) < p) && all(p < float2(1.0));
}

// p : the position
// persp : the perspective in [ 0, 1 ]
// center : the xcenter in [0, 1] \ 0.5 excluded
float2 cube_xskew (float2 p, float persp, float center) {
  float x = mix(p.x, 1.0-p.x, center);
  return (
          (float2( x, (p.y - 0.5*(1.0-persp) * x) / (1.0+(persp-1.0)*x) ) - float2(0.5-abs(center - 0.5), 0.0))
          * float2(0.5 / abs(center - 0.5) * (center<0.5 ? 1.0 : -1.0), 1.0)
          + float2(center<0.5 ? 0.0 : 1.0, 0.0)
          );
}

kernel void CubeTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                           texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                           texture2d<float, access::sample> toTexture [[ texture(2) ]],
                           constant float & ratio [[ buffer(0) ]],
                           constant float & progress [[ buffer(1) ]],
                           constant float & persp [[ buffer(2) ]],
                           constant float & unzoom [[ buffer(3) ]],
                           constant float & reflection [[ buffer(4) ]],
                           constant float & floating [[ buffer(5) ]],
                           uint2 gid [[ thread_position_in_grid ]],
                           uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;
  float2 texCoord = uv.xy / float2(1.0).xy;



  float uz = unzoom * 2.0*(0.5 - abs(0.5 - progress));
  float2 p = -uz*0.5+(1.0+uz) * uv;
  float2 fromP = cube_xskew((p - float2(progress, 0.0)) / float2(1.0 - progress, 1.0),
                       1.0 - mix(progress, 0.0, persp),
                       0.0);
  float2 toP = cube_xskew(p/float2(progress, 1.0),
                     mix(pow(progress, 2.0), 1.0, persp),
                     1.0);
  // FIXME avoid branching might help perf!
  if (cube_inBounds(fromP)) {
    outputTexture.write(getColor(fromP, fromTexture, ratio), gid);
    return;
  } else if (cube_inBounds(toP)) {
    outputTexture.write(getColor(toP, toTexture, ratio), gid);
    return;
  }

  float4 c = float4(0.0, 0.0, 0.0, 1.0);
  fromP = cube_project(fromP, floating);
  // FIXME avoid branching might help perf!
  if (cube_inBounds(fromP)) {
      c += mix(float4(0.0), getColor(fromP, fromTexture, ratio), reflection * mix(1.0, 0.0, fromP.y));
  }
  toP = cube_project(toP, floating);
  if (cube_inBounds(toP)) {
      c += mix(float4(0.0), getColor(toP, toTexture, ratio), reflection * mix(1.0, 0.0, toP.y));
  }

  outputTexture.write(c, gid);
}
