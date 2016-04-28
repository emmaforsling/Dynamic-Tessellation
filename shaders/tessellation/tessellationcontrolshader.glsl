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

/*
*	Function innerTessLvl_screenSize calculates a tessellation level based on a measure representing
*	the size of the patch on the screen.
*/
float innerTessLvl_screenSize()
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
	float screenSizeMeasure = area / cameraDistance;

	// Return tess level based on the measure. [TODO: rewrite!]
	return 1.0 + floor(screenSizeMeasure * 100.0 * tessScale);
}


/* 
*  Function outerTessLvl_screenSize calculates a tessellation level per edge,
*  based on a measure representing its size on the screen. The function makes
*  the tessellation avoid cracks along edges shared between primitives.
*/
float outerTessLvl_screenSize(int _vIdx0, int _vIdx1)
{
	// Calculate length of edge
	float edgeLength = length(fragPos_ws[_vIdx0] - fragPos_ws[_vIdx1]);

	// Calculate mean normal of edge
	vec3 normal = normalize(vNormal[_vIdx0] + vNormal[_vIdx1]);

	// Calculate mean distance from edge to camera
	vec3 meanPos = (fragPos_ws[_vIdx0] + fragPos_ws[_vIdx1]) / 2.0;
	float cameraDistance = length(meanPos - cameraPos_ws);

	// Calculate view direction to mean position
	vec3 viewDirection = normalize(meanPos - cameraPos_ws);
	
	// Calculate visibility measure based on view direction and normal
	float visibilityMeasure = max(0.0, dot(normal, -viewDirection));

	// Calculate final screen size measure
	float screenSizeMeasure = edgeLength * visibilityMeasure / cameraDistance;

	// Return tess level based on the measure. [TODO: rewrite!]
	return 1.0 + floor(screenSizeMeasure * 25.0 * tessScale);
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
    	gl_TessLevelInner[0] = tessScale * innerTessLvl_screenSize();
    	gl_TessLevelOuter[0] = tessScale * outerTessLvl_screenSize(1, 2);
    	gl_TessLevelOuter[1] = tessScale * outerTessLvl_screenSize(2, 0);
    	gl_TessLevelOuter[2] = tessScale * outerTessLvl_screenSize(0, 1);
    }
}
