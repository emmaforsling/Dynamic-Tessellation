#version 330 core

// Input 
layout(location = 0) in vec3 vertexPos_ms;
layout(location = 1) in vec3 vertexNormal_ms;
layout(location = 2) in vec2 uvCoordinates;

// Uniforms
uniform mat4 M;
uniform vec3 lightPosition;

// Output
out vec3 vPosition;
out vec3 vNormal;
out vec2 vTexCoord;

void main()
{
	vPosition = vertexPos_ms;
	vNormal = normalize(vertexNormal_ms); //(M * vec4(vertexNormal_ms, 0.0)).xyz;
	vTexCoord = uvCoordinates;
}
