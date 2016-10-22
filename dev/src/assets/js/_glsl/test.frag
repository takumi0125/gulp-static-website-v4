precision mediump float;

varying vec4 vColor;
varying vec2 vUv;

void main(){
  if(vColor.a == 0.0) {
    discard;
  } else {
    gl_FragColor = vColor;
  }
}
