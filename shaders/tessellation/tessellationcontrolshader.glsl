#version 330 core

// This shader is executed once per control point in the output patch,
// and we start by defining this number.
layout(vertices = 3) out;

// input from V.S.
in vec3 vPosition[];
in vec3 vNormal[];
in vec2 vTexCoord[];
in vec3 fragPos_ws[];
// output for the T.E.S.
out vec3 tcPosition[];
out vec3 tcNormal[];
out vec2 tcTexCoord[];

// Uniforms
uniform vec3 cameraPos_ws;
uniform float tessScale;

#define ID gl_InvocationID

// If camera position is near, tesselate more
float calculateTessLevel()
{
    float distToCamera = length(cameraPos_ws - (fragPos_ws[0] + fragPos_ws[1] + fragPos_ws[2]) / 3.0 ) ;
    if(distToCamera < 40.0 * tessScale && distToCamera > 31.0 * tessScale)
    {
        return 2.0;
    }
    else if(distToCamera <= 31.0 * tessScale && distToCamera > 23.0 * tessScale)
    {
        return 3.0;
    }
    else if(distToCamera <= 23.0 * tessScale && distToCamera > 16.0 * tessScale)
    {
        return 4.0;
    }
    else if(distToCamera <= 16.0 * tessScale && distToCamera > 11.0 * tessScale)
    {
        return 5.0;
    }
    else if(distToCamera <= 11.0 * tessScale && distToCamera > 7.0 * tessScale)
    {
        return 6.0;
    }
    else if(distToCamera <= 7.0 * tessScale && distToCamera > 4.0 * tessScale)
    {
        return 7.0;
    }
    else if(distToCamera <= 4.0 * tessScale && distToCamera > 2.0 * tessScale)
    {
        return 8.0;
    }
    else if(distToCamera <= 2.0 * tessScale && distToCamera > 1.0 * tessScale)
    {
        return 9.0;
    }
    else if(distToCamera <= 1.0 * tessScale)
    {
        return 10.0;
    }
    else
    {
        return 1.0;
    }
}

void main()
{
	// Set the control points of the output patch
    tcPosition[ID] = vPosition[ID];
    tcNormal[ID] = vNormal[ID];
    tcTexCoord[ID] = vTexCoord[ID];

    // Set the tessellation levels (only at the first ID in each output patch)
    if(ID == 0)
    {
        float innerTessLevel = calculateTessLevel();
    	gl_TessLevelInner[0] = innerTessLevel;
    	gl_TessLevelOuter[0] = innerTessLevel;
    	gl_TessLevelOuter[1] = innerTessLevel;
    	gl_TessLevelOuter[2] = innerTessLevel;
    }
}
