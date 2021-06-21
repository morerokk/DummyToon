uniform float _SpecularMode;
uniform float _SpecularToonyEnabled;
uniform float _SpecularToonyCutoff;

uniform sampler2D _SpecMap;
uniform float4 _SpecularColor;

void Specular(float3 albedo, float3 lightDirection, float3 lightColor, float3 normalDir, float3 viewDirection, float attenuation, float2 uv, float occlusionStrength inout float3 finalColor)
{
	// Calculate reflection direction
	float3 reflectionDir;
	float dotProduct;
	if(_SpecularMode == 0)
	{
		// Use Blinn specular
		reflectionDir = reflect(-lightDirection, normalDir);
		// How close is our view direction to the reflection direction?
		dotProduct = max(dot(viewDirection, reflectionDir), 0);
	}
	else
	{
		// Use Blinn-Phong specular
		reflectionDir = normalize(lightDirection + viewDirection);
		dotProduct = max(dot(viewDirection, normalDir), 0);
	}

	// Sample the specular map for color and smoothness info
	float4 specMap = tex2D(_SpecMap, uv) * _SpecularColor;

	// Narrow down the reflection size/width based on smoothness
	dotProduct = pow(dotProduct, max(specMap.a, 0.05) * 100);

	// With toony specular enabled, cut off the specular after a certain point instead of smoothing it out.
	// Additionally, when not cut off, the dot product is always 1 to make it sharper.
	if(_SpecularToonyEnabled == 1)
	{
		if(dotProduct < _SpecularToonyCutoff)
		{
			dotProduct = 0;
		}
		else
		{
			dotProduct = 1;
		}
	}
	
	// Calculate the specular color
	float3 specularCol = lightColor * specMap.rgb * dotProduct * attenuation;

	// This, again, does not make much sense for normal lights.
	// However, specular highlights are also applied for the fake base ambient light, which should be negated by AO.
	#if defined(_OCCLUSION_ON)
		specularCol *= 1 - occlusionStrength;
	#endif

	// Apply the specular to the output color
	finalColor += specularCol;
}