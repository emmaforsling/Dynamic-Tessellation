#version 330 core
layout(triangles, equal_spacing, ccw) in;

// input from T.E.S.
in vec3 tcPosition[];
in vec3 tcNormal[];
in vec2 tcTexCoord[];

// output for the G.S.
out vec3 tePosition;
out vec3 teNormal;
out vec2 teTexCoord;
out vec3 tePatchDistance;

// uniforms
uniform mat4 MVP;
uniform sampler2D dispMap;
uniform float dispScale;

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
	// Calculate the position, normal and texture coordiantes for the new point created in the triangle
	tePosition = interpolate3D(tcPosition[0], tcPosition[1], tcPosition[2]);
	teNormal = interpolate3D(tcNormal[0], tcNormal[1], tcNormal[2]);
	teTexCoord = interpolate2D(tcTexCoord[0], tcTexCoord[1], tcTexCoord[2]);
	tePatchDistance = gl_TessCoord;

	// Stretch texture coordinates to fit a sphere
	float tu = teNormal.x / 2.0 + 0.5;
    float tv = teNormal.y / 2.0 + 0.5;

	// Calculate a displacement 
	float displacement = 0.1 * dispScale * texture(dispMap, vec2(tu, tv)).x;

	// Add the displacement
   	tePosition += teNormal * displacement;
	
	gl_Position = MVP * vec4(tePosition, 1.0);
}

