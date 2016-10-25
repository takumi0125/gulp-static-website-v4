uniform mat4 modelViewMatrix;
uniform mat4 modelMatrix;
uniform mat4 projectionMatrix;

attribute vec3 position;
attribute vec2 uv;

varying vec4 vColor;
varying vec2 vUv;

#pragma glslify: PI = require('./lib/PI.glsl')
#pragma glslify: rotateVec3 = require('./lib/rotateVec3.glsl')
#pragma glslify: map = require('./lib/map.glsl')
#pragma glslify: hsv2rgb = require('./lib/hsv2rgb.glsl')
#pragma glslify: easeOutExpo = require('glsl-easings/exponential-out')
#pragma glslify: snoise2 = require('glsl-noise/simplex/2d')
#pragma glslify: snoise3 = require('glsl-noise/simplex/3d')

void main() {
  vec3 pos = vec3(0.0) + PI;

  vec4 modelViewPos = modelViewMatrix * vec4(pos, 1.0);
  gl_Position = projectionMatrix * modelViewPos;
  vColor = vec4(0.0, 0.0, 0.0, 1.0);

  vUv = uv;
}
