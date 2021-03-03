/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions

// Author: 0gust1
// License: MIT
// Simplex noise :
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : MIT
//               2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//


//My own first transition — based on crosshatch code (from pthrasher), using  simplex noise formula (copied and pasted)
//-> cooler with high contrasted images (isolated dark subject on light background f.e.)
//TODO : try to rebase it on DoomTransition (from zeh)?
//optimizations :
//luminance (see http://stackoverflow.com/questions/596216/formula-to-determine-brightness-of-rgb-color#answer-596241)
// Y = (R+R+B+G+G+G)/6
//or Y = (R+R+R+B+G+G+G+G)>>3

#include <metal_stdlib>
#include "VideoTransition.h"

using namespace metal;

float3 mod289(float3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 permute(float3 x) {
  return mod289(((x * 34.0)+1.0) * x);
}

float snoise(float2 v) {
  const float4 C = float4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                          0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                          -0.577350269189626,  // -1.0 + 2.0 * C.x
                          0.024390243902439); // 1.0 / 41.0
  // First corner
  float2 i  = floor(v + dot(v, C.yy) );
  float2 x0 = v -   i + dot(i, C.xx);

  // Other corners
  float2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  // Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
                     + i.x + float3(0.0, i1.x, 1.0 ));

  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

  // Gradients: 41 points uniformly over a line, mapped onto a diamond.
  // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  float3 x = 2.0 * fract(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;

  // Normalise gradients implicitly by scaling m
  // Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

  // Compute final noise value at P
  float3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

// Simplex noise -- end

float luminance(float4 color){
  //(0.299*R + 0.587*G + 0.114*B)
  return color.r*0.299+color.g*0.587+color.b*0.114;
}

kernel void LuminanceMeltTransition(texture2d<float, access::write> outputTexture [[ texture(0) ]],
                                    texture2d<float, access::sample> fromTexture [[ texture(1) ]],
                                    texture2d<float, access::sample> toTexture [[ texture(2) ]],
                                    constant float & ratio [[ buffer(0) ]],
                                    constant float & progress [[ buffer(1) ]],
                                    constant bool & direction [[ buffer(2) ]],
                                    constant bool & above [[ buffer(3) ]],
                                    constant float & l_threshold [[ buffer(4) ]],
                                    uint2 gid [[ thread_position_in_grid ]],
                                    uint2 tpg [[ threads_per_grid ]])
{
  if ((gid.x >= outputTexture.get_width()) || (gid.y >= outputTexture.get_height())) { return; }
  float2 uv = float2(gid) / float2(tpg);
  uv.y = 1.0 - uv.y;

  float2 center = float2(1.0, direction);

  float2 p = uv.xy / float2(1.0).xy;
  if (progress == 0.0) {
    outputTexture.write(getColor(p, fromTexture, ratio), gid);
  } else if (progress == 1.0) {
    outputTexture.write(getColor(p, toTexture, ratio), gid);
  } else {
    float x = progress;
    float dist = distance(center, p)- progress*exp(snoise(float2(p.x, 0.0)));
    float r = x - rand(float2(p.x, 0.1));
    float m;
    if(above){
      m = dist <= r && luminance(getColor(p, fromTexture, ratio)) > l_threshold ? 1.0 : (progress*progress*progress);
    } else{
      m = dist <= r && luminance(getColor(p, fromTexture, ratio)) < l_threshold ? 1.0 : (progress*progress*progress);
    }
    float4 outColor = mix(getColor(p, fromTexture, ratio),
                          getColor(p, toTexture, ratio),
                          m);
    outputTexture.write(outColor, gid);
  }
}
