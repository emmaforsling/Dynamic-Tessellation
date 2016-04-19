#version 330 core

// This shader is executed once per control point in the output patch,
// and we start by defining this number.
layout(vertices = 3) out;

// input from V.S.
in vec3 vPosition[];
in vec3 vNormal[];
in vec2 vTexCoord[];

// output for the T.E.S.
out vec3 tcPosition[];
out vec3 tcNormal[];
out vec2 tcTexCoord[];

#define ID gl_InvocationID

void main()
{
	// Set the control points of the output patch
    tcPosition[ID] = vPosition[ID];
    tcNormal[ID] = vNormal[ID];
    tcTexCoord[ID] = vTexCoord[ID];
    
    // Set the tessellation levels (only at the first ID in each output patch)
    if(ID == 0)
    {
    	gl_TessLevelInner[0] = 6.0;
    	gl_TessLevelOuter[0] = 6.0;
    	gl_TessLevelOuter[1] = 6.0;
    	gl_TessLevelOuter[2] = 6.0;
    }
}
