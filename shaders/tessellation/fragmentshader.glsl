#version 330 core

// Input from the G.S.
in vec3 gFacetNormal;
in float gPrimitive;
in vec2 gTexCoord;
in vec3 fragPos_ws;

// Output
out vec4 fragColor;

// Uniforms
uniform sampler2D dispMap;
uniform sampler2D normMap;
uniform sampler2D colorMap;
uniform vec3 cameraPos_ws;
// Scalars
uniform float k_diff, k_spec, specPow;

void main()
{
    vec3 lightPosition_ws = vec3(0.0, 0.0, 2.0);
    vec3 viewDir_ws = normalize(fragPos_ws - cameraPos_ws);

    vec3 normal_ws = /*normalize(texture(normMap, gTexCoord).xyz);//*/normalize(gFacetNormal);
    vec3 lightDirection_ws = normalize(fragPos_ws - lightPosition_ws);

    // Diffuse light
    float diffuseLight = max(0.0, dot(normal_ws, -lightDirection_ws));
    vec4 diffuseColor = vec4(1.0, 0.0, 0.0, 1.0);

    // Specular light
    vec4 specularColor = vec4(1.0, 1.0, 1.0, 1.0);
    vec3 reflectionDir_ws = reflect(lightDirection_ws, normal_ws);
    float specularLight = pow(max(0.0, dot(reflectionDir_ws, -viewDir_ws)), specPow);

    float lightDist = length(lightPosition_ws - fragPos_ws);
    float atten = min(1.0, 10.0 / lightDist);
    
    // Composite lighting contributions
    fragColor = /*atten **/ k_diff * diffuseLight * diffuseColor + k_spec * specularLight * specularColor;
}
