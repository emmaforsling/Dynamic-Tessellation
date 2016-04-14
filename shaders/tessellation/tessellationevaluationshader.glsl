#version 330 core
layout(triangles, equal_spacing, ccw) in;

// uniforms
uniform mat4 MVP;

// input from T.E.S.
in vec3 tcPosition[];

// output for the G.S.
out vec3 tePosition;
out vec3 tePatchDistance;

// Builds one point
void main()
{
	vec3 p0 = gl_TessCoord.x * tcPosition[0];
	vec3 p1 = gl_TessCoord.y * tcPosition[1];
	vec3 p2 = gl_TessCoord.z * tcPosition[2];
	tePatchDistance = gl_TessCoord;
	tePosition = p0 + p1 + p2;
	gl_Position = MVP * vec4(tePosition, 1.0);
}
