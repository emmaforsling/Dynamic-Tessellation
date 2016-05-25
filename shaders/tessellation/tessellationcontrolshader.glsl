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

out BezierPatch bezier_cps[];

// Uniforms
uniform vec3 cameraPos_ws;
uniform float tessScale;
uniform int bezierEnabled;

#define ID gl_InvocationID

#define cur_patch bezier_cps[gl_InvocationID]

float wij(int i, int j)
{
 return dot(vPosition[j] - vPosition[i], vNormal[i]);		// (P1 - P0) * N0 
}

float vij(int i, int j)
{
 vec3 Pj_minus_Pi = vPosition[j] - vPosition[i];			// ex P1-P0
 vec3 Ni_plus_Nj  = vNormal[i] + vNormal[j];				// V0 + V1	
 return 2.0*dot(Pj_minus_Pi, Ni_plus_Nj)/dot(Pj_minus_Pi, Pj_minus_Pi);
}

/**
*	Determine the output patch evaluationpoint
*	
*		p300 	p012 	p021 	p030
*			p102 	p111	p120
*				p201	p210
*					p300
**/
void determinePatch(){
	// Take the three points and determine its value 
	vec3 P0 = vPosition[0];		// p300
	vec3 P1 = vPosition[1];		// p030
	vec3 P2 = vPosition[2];		// p003
	
	// and its normals
	vec3 N0 = vNormal[0];		//n300
	vec3 N1 = vNormal[1];		//n030
	vec3 N2 = vNormal[2];		//n003
	
	// determine the center point for these three points
	vec3 center = (P0 + P1 + P2)/3.0;
	
	// Determine the bezier controlpoints 
	cur_patch.p210 = (2.0 * P0 + P1 - wij(0,1) * N0)/3.0;		// p210 = 2P0 + P1 - dot(n300,(P1-P0))*n300
	cur_patch.p120 = (2.0 * P1 + P0 - wij(1,0) * N1)/3.0;		 
	cur_patch.p021 = (2.0 * P1 + P2 - wij(1,2) * N1)/3.0;
	cur_patch.p012 = (2.0 * P2 + P1 - wij(2,1) * N2)/3.0;
	cur_patch.p102 = (2.0 * P2 + P0 - wij(2,0) * N2)/3.0;
	cur_patch.p201 = (2.0 * P0 + P2 - wij(0,2) * N0)/3.0;
	
	// determine the inner center point for the bezier control points
	vec3 innerCenter = ( cur_patch.p210
	  + cur_patch.p120
	  + cur_patch.p021
	  + cur_patch.p012
	  + cur_patch.p102
	  + cur_patch.p201 ) / 6.;
	
	// set p111 by using innerCenter and center
	cur_patch.p111 = innerCenter + (innerCenter - center) * 0.5;
	
	// set the normals n011,n110,n101 
	cur_patch.n011 = normalize(N0 + N1 - vij(0,1) * (P1-P0));
	cur_patch.n110 = normalize(N1 + N2 - vij(1,2) * (P2-P1));
	cur_patch.n101 = normalize(N2 + N0 - vij(2,0) * (P0-P2));

}


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
	float visibilityMeasure = pow(max(0.0, dot(-viewDirection, faceNormal)), 1.5);

	// Calculate distance from triangle to camera
	float cameraDistance = length(centerPoint - cameraPos_ws);

	// Calculate final screen size measure
	float screenSizeMeasure = area /* * visibilityMeasure */ / cameraDistance;

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
	float visibilityMeasure = pow(max(0.0, dot(normal, -viewDirection)), 1.5);

	// Calculate final screen size measure
	float screenSizeMeasure = edgeLength /* * visibilityMeasure */ / cameraDistance;

	// Return tess level based on the measure.
	return 1.0 + floor(screenSizeMeasure * 30.0 * tessScale);
}

void main()
{
	// Set the control points of the output patch
    tcPosition[ID] = vPosition[ID];
    tcNormal[ID] = vNormal[ID];
    tcTexCoord[ID] = vTexCoord[ID];

    // Set the tessellation levels (only at the first ID in each output patch)
    // Tessellation cracking fix. For some reason, the bezier tessellation
	// needs another pairing between points and edges. TODO: investigate.
    if(ID == 0 && bezierEnabled == 1)
    {
	    determinePatch();
    	gl_TessLevelInner[0] = tessScale * innerTessLvl_screenSize();
    		
    	gl_TessLevelOuter[0] = tessScale * outerTessLvl_screenSize(2, 0);
	    gl_TessLevelOuter[1] = tessScale * outerTessLvl_screenSize(1, 0);
	    gl_TessLevelOuter[2] = tessScale * outerTessLvl_screenSize(2, 1);
    }
    if(ID == 0 && bezierEnabled == 0)
    {
    	determinePatch();
    	gl_TessLevelInner[0] = tessScale * innerTessLvl_screenSize();

    	gl_TessLevelOuter[0] = tessScale * outerTessLvl_screenSize(2, 1);
    	gl_TessLevelOuter[1] = tessScale * outerTessLvl_screenSize(2, 0);
    	gl_TessLevelOuter[2] = tessScale * outerTessLvl_screenSize(1, 0);
    }
    	
}
