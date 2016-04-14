#version 330 core

//input from the G.S.
in vec3 gFacetNormal;
in vec3 gTriDistance;
in vec3 gPatchDistance;
in float gPrimitive;

// output 
out vec4 fragColor;

float amplify(float d, float scale, float offset)
{
    d = scale * d + offset;
    d = clamp(d, 0, 1);
    d = 1 - exp2(-2*d*d);
    return d;
}

void main()
{
	vec3 lightPosition = normalize(vec3(0.0,0.0,-2.0));
	vec3 diffuseMaterial = vec3(1.0,0.0,0.0);
	vec3 ambientMaterial = vec3(0.1,0.1,0.1);

    vec3 N = normalize(gFacetNormal);
    vec3 L = lightPosition;
    float df = max(0.0, dot(N, L));
    vec3 color = ambientMaterial + df * diffuseMaterial;

    float d1 = min(min(gTriDistance.x, gTriDistance.y), gTriDistance.z);
    float d2 = min(min(gPatchDistance.x, gPatchDistance.y), gPatchDistance.z);
    color = amplify(d1, 40, -0.5) * amplify(d2, 60, -0.5) * color;

    fragColor = vec4(color, 1.0);
}
