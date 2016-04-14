#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

// input from the T.E.S.
in vec3 tePosition[3];
in vec3 tePatchDistance[3];

// output for the F.S.
out vec3 gFacetNormal;
out vec3 gPatchDistance;
out vec3 gTriDistance;

uniform mat4 M;
uniform mat4 V;

void main()
{
	vec3 A = tePosition[2] - tePosition[0];
	vec3 B = tePosition[1] - tePosition[0];
    gFacetNormal = vec3(M * vec4(normalize( cross(A, B)),0.0) );

    gPatchDistance = tePatchDistance[0];
    gTriDistance = vec3(1, 0, 0);
    gl_Position = gl_in[0].gl_Position; EmitVertex();

    gPatchDistance = tePatchDistance[1];
    gTriDistance = vec3(0, 1, 0);
    gl_Position = gl_in[1].gl_Position; EmitVertex();
 
    gPatchDistance = tePatchDistance[2];
    gTriDistance = vec3(0, 0, 1);
    gl_Position = gl_in[2].gl_Position; EmitVertex();

	EndPrimitive();
}
