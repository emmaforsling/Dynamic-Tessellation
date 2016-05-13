#version 330 core

struct BezierPatch
{
	vec3 p012;
	vec3 p021;
	vec3 p120;
	vec3 p210;
	vec3 p201;
	vec3 p102;
	vec3 p111;
	vec3 n011;
	vec3 n110;
	vec3 n101;
};

layout(triangles, equal_spacing, ccw) in;

// input from T.E.S.
in vec3 tcPosition[];
in vec3 tcNormal[];
in vec2 tcTexCoord[];
in BezierPatch bezier_cps[];

// output for the G.S.
out vec3 tePosition;
out vec3 teNormal;
out vec2 teTexCoord;
out vec3 tePatchDistance;

// uniforms
uniform mat4 MVP;
uniform mat4 V;
uniform mat4 M;
uniform mat4 P;
uniform sampler2D dispMap;
uniform float dispScale;
uniform int bezierEnabled;
uniform int dispEnabled;

/**
*	Functions interpolate2D and interpolate3D
*	perform linear interpolation of vectors that uses the barycentric tessellation
*	coordinates as weights. The output vectors are in cartesian coordinates. 
**/
vec2 interpolate2D(vec2 v0, vec2 v1, vec2 v2)
{
   	return vec2(gl_TessCoord.x) * v0 + vec2(gl_TessCoord.y) * v1 + vec2(gl_TessCoord.z) * v2;
}
vec3 interpolate3D(vec3 v0, vec3 v1, vec3 v2)
{
   	return vec3(gl_TessCoord.x) * v0 + vec3(gl_TessCoord.y) * v1 + vec3(gl_TessCoord.z) * v2;
}

/**
*	Main function
*	Builds one point
**/
void main()
{	
	if(bezierEnabled == 1.0)
	{
		vec3 tesscoord_2 = gl_TessCoord * gl_TessCoord;
		vec3 tesscoord_3 = tesscoord_2 * gl_TessCoord;
		
		float v = gl_TessCoord[0];
		float w = gl_TessCoord[1];
		float u = gl_TessCoord[2];

		float v_2 = tesscoord_2[0];
		float w_2 = tesscoord_2[1];
		float u_2 = tesscoord_2[2];
		
		float v_3 = tesscoord_3[0];
		float w_3 = tesscoord_3[1];
		float u_3 = tesscoord_3[2];
		
		// determine normal
		vec3 bezier_norm = 	tcNormal[0]	* u_2 +						// n300
							tcNormal[1]	* v_2 +						// n030
							tcNormal[2] * w_2 +						// n003
							bezier_cps[0].n011 * v * w +
							bezier_cps[0].n110 * u * v +
							bezier_cps[0].n101 * u * w;

		// determine position
		vec3 bezier_pos = 	tcPosition[0] * u_3 +
							tcPosition[1] * v_3 +
							tcPosition[2] * w_3 +
							bezier_cps[0].p210 * 3.0 * u_2 * v +
							bezier_cps[0].p120 * 3.0 * v_2 * u +
							bezier_cps[0].p201 * 3.0 * u_2 * w +
							bezier_cps[0].p021 * 3.0 * v_2 * w +
							bezier_cps[0].p102 * 3.0 * w_2 * u +
							bezier_cps[0].p012 * 3.0 * w_2 * v +
							bezier_cps[0].p111 * 6.0 * v * w * u;

		// set output variables
		tePosition = bezier_pos;
		teNormal = mat3(M) * bezier_norm;
		teTexCoord = interpolate2D(tcTexCoord[0], tcTexCoord[1], tcTexCoord[2]);
		tePatchDistance = gl_TessCoord;

		// set gl_Position in screen coordinates
		gl_Position = MVP * vec4(tePosition, 1.0);
	}
	else
	{
		// Calculate the position, normal and texture coordiantes for the new point created in the triangle
		tePosition = interpolate3D(tcPosition[0], tcPosition[1], tcPosition[2]);
		teNormal = interpolate3D(tcNormal[0], tcNormal[1], tcNormal[2]);
		teTexCoord = interpolate2D(tcTexCoord[0], tcTexCoord[1], tcTexCoord[2]);
		tePatchDistance = gl_TessCoord;

		// Stretch texture coordinates to fit a sphere
		float tu = teNormal.x / 2.0 + 0.5;
	    float tv = teNormal.y / 2.0 + 0.5;

		// Calculate a displacement 
		float displacement = dispEnabled * 0.1 * dispScale * texture(dispMap, vec2(tu, tv)).x;

		// Add the displacement
	   	tePosition += teNormal * displacement;
		
		gl_Position = MVP * vec4(tePosition, 1.0);
	}
}

