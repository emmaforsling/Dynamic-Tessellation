#version 330 core

layout(vertices = 3) out;

// input from V.S.
in vec3 vPosition[];

// output for the T.E.S.
out vec3 tcPosition[];

#define ID gl_InvocationID

void main()
{
    tcPosition[ID] = vPosition[ID];			// sets the original points to their original position
    // For the first ID for each patch
    if(ID == 0)
    {
    	gl_TessLevelInner[0] = 2.0;
    	gl_TessLevelOuter[0] = 1.0;
    	gl_TessLevelOuter[1] = 1.0;
    	gl_TessLevelOuter[2] = 1.0;
    }
}
