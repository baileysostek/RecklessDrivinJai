#version 330 core
layout (location = 0) in vec3 aPos;

uniform float aspect_ratio;
uniform mat4 model;
uniform mat4 transformation;
uniform mat4 projection;

void main()
{
  gl_Position = projection * transformation * model * vec4(aPos.x, aPos.y, aPos.z, 1.0);
}