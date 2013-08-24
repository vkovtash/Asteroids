attribute vec4 Position; 

varying vec4 DestinationColor; 

uniform vec4 SourceColor;
uniform mat4 Projection;
uniform mat4 Modelview;

void main(void) { 
    DestinationColor = SourceColor; 
    gl_Position = Projection * Modelview * Position;
}