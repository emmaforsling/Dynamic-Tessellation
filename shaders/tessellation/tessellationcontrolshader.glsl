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
float calculateTessLevelFromDist()
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

float calculateTessLevelFromSize()
{
	// Calculate area of the triangle
	float area = length(cross(fragPos_ws[1] - fragPos_ws[0], fragPos_ws[2] - fragPos_ws[0])) / 2.0;
	
	// Calculate a visility measure based on face normal and view direction
	vec3 faceNormal = normalize(vNormal[0] + vNormal[1] + vNormal[2]);
	vec3 centerPoint = (fragPos_ws[0] + fragPos_ws[1] + fragPos_ws[2]) / 3.0;
	vec3 viewDirection = normalize(centerPoint - cameraPos_ws);
	float visibilityMeasure = max(0.0, dot(-viewDirection, faceNormal));

	// Calculate distance from triangle to camera
	float cameraDistance = length(centerPoint - cameraPos_ws);

	// Calculate final screen size measure
	float screenSizeMeasure = area * visibilityMeasure / cameraDistance;

	if(screenSizeMeasure < 0.005)
	{
		return 1.0;
	}
	else if(screenSizeMeasure >= 0.005 && screenSizeMeasure < 0.01)
	{
		return 2.0;
	}
	else if(screenSizeMeasure >= 0.01 && screenSizeMeasure < 0.03)
	{
		return 3.0;
	}
	else if(screenSizeMeasure >= 0.03 && screenSizeMeasure < 0.035)
	{
		return 3.0;
	}
	else if(screenSizeMeasure >= 0.035 && screenSizeMeasure < 0.040)
	{
		return 4.0;
	}
	else if(screenSizeMeasure >= 0.040 && screenSizeMeasure < 0.045)
	{
		return 5.0;
	}
	else if(screenSizeMeasure >= 0.045 && screenSizeMeasure < 0.050)
	{
		return 6.0;
	}
	else if(screenSizeMeasure >= 0.050 && screenSizeMeasure < 0.055)
	{
		return 7.0;
	}
	else if(screenSizeMeasure >= 0.055 && screenSizeMeasure < 0.060)
	{
		return 8.0;
	}
	else if(screenSizeMeasure >= 0.060 && screenSizeMeasure < 0.065)
	{
		return 9.0;
	}
	else if(screenSizeMeasure >= 0.065 && screenSizeMeasure < 0.070)
	{
		return 10.0;
	}
	else if(screenSizeMeasure >= 0.070 && screenSizeMeasure < 0.1)
	{
		return 11.0;
	}
	else if(screenSizeMeasure >= 0.1)
	{
		return 24.0;
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
        float innerTessLevel = calculateTessLevelFromSize();
    	gl_TessLevelInner[0] = innerTessLevel;
    	gl_TessLevelOuter[0] = innerTessLevel;
    	gl_TessLevelOuter[1] = innerTessLevel;
    	gl_TessLevelOuter[2] = innerTessLevel;
    }
}
