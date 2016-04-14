#version 330 core

// Input 
layout(location = 0) in vec3 vertexPos_ms;
layout(location = 1) in vec3 vertexNormal_ms;
layout(location = 2) in vec2 uvCoordinates;

uniform vec3 lightPosition;

out vec3 vPosition;

void main()
{
	vPosition = vertexPos_ms;
}
