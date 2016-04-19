#version 330 core
layout(triangles, equal_spacing, ccw) in;

// uniforms
uniform mat4 MVP;
uniform sampler2D dispMap;

// input from T.E.S.
in vec3 tcPosition[];
in vec3 tcNormal[];
in vec2 tcTexCoord[];

// output for the G.S.
out vec3 tePosition;
out vec3 teNormal;
out vec2 teTexCoord;
out vec3 tePatchDistance;

vec2 interpolate2D(vec2 v0, vec2 v1, vec2 v2)
{
   	return vec2(gl_TessCoord.x) * v0 + vec2(gl_TessCoord.y) * v1 + vec2(gl_TessCoord.z) * v2;
}

vec3 interpolate3D(vec3 v0, vec3 v1, vec3 v2)
{
   	return vec3(gl_TessCoord.x) * v0 + vec3(gl_TessCoord.y) * v1 + vec3(gl_TessCoord.z) * v2;
}

// Builds one point
void main()
{
	vec3 p0 = gl_TessCoord.x * tcPosition[0];
	vec3 p1 = gl_TessCoord.y * tcPosition[1];
	vec3 p2 = gl_TessCoord.z * tcPosition[2];

	tePatchDistance = gl_TessCoord;
	tePosition = p0 + p1 + p2;

	teNormal = interpolate3D(tcNormal[0], tcNormal[1], tcNormal[2]);
	teTexCoord = interpolate2D(tcTexCoord[0], tcTexCoord[1], tcTexCoord[2]);
	float displacement = 0.5 * texture(dispMap, teTexCoord.xy).x;

   	tePosition += teNormal * displacement;
	gl_Position = MVP * vec4(tePosition, 1.0);
}

