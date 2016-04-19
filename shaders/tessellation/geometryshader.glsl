#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

// input from the T.E.S.
in vec3 tePosition[3];
in vec3 teNormal[3];
in vec2 teTexCoord[3];
in vec3 tePatchDistance[3];

// output for the F.S.
out vec3 gFacetNormal;
out vec3 gPatchDistance;
out vec3 gTriDistance;
out vec2 gTexCoord;
out vec3 fragPos_ws;

uniform mat4 M;
uniform mat4 V;

void main()
{
    // Calculate new normals
	vec3 A = tePosition[1] - tePosition[0];
	vec3 B = tePosition[2] - tePosition[0];
    gFacetNormal = mat3(M) * normalize(cross(A, B));    // Per face normal

    gPatchDistance = tePatchDistance[0];
    gTriDistance = vec3(1, 0, 0);
    gl_Position = gl_in[0].gl_Position;
    gTexCoord = teTexCoord[0];
    fragPos_ws = (M * vec4(tePosition[0], 1.0)).xyz;
    //gFacetNormal = mat3(M) * teNormal[0];             // Alternatively, per vertex normals...
    EmitVertex();

    gPatchDistance = tePatchDistance[1];
    gTriDistance = vec3(0, 1, 0);
    gl_Position = gl_in[1].gl_Position;
    gTexCoord = teTexCoord[1];
    fragPos_ws = (M * vec4(tePosition[1], 1.0)).xyz;
    //gFacetNormal = mat3(M) * teNormal[1];             // Alternatively, per vertex normals...
    EmitVertex();
 
    gPatchDistance = tePatchDistance[2];
    gTriDistance = vec3(0, 0, 1);
    gl_Position = gl_in[2].gl_Position;
    gTexCoord = teTexCoord[2];
    fragPos_ws = (M * vec4(tePosition[2], 1.0)).xyz;
    //gFacetNormal = mat3(M) * teNormal[2];             // Alternatively, per vertex normals...
    EmitVertex();

	EndPrimitive();
}
