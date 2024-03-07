#version 400 core

in vec3 position;
in vec4 color;

out vec4 pass_color;

uniform mat4 transformation;
uniform mat4 projection;

void main(void){
    gl_Position =  projection * transformation * vec4(position, 1.0);
    pass_color = color;
}
