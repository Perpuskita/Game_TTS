Shader "Custom/Reflection+IOR"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (0.2, 0.4, 0.5, 0.7) // Water color with transparency
        _NormalMap ("Normal Map", 2D) = "bump" {} // Normal map for ripples
        _NormalScale ("Normal Scale", Float) = 1.0 // Scale of the normal map
        _NormalScrollSpeed ("Normal Scroll Speed", Vector) = (0.01, 0.01, 0, 0) // XY for scroll speed
        _RefractionStrength ("Refraction Strength", Range(0, 0.1)) = 0.03 // How much to distort for refraction
        _ReflectionStrength ("Reflection Strength", Range(0, 1)) = 0.8 // How strong reflections are
        _FresnelPower ("Fresnel Power", Range(0, 5)) = 2.0 // Power for Fresnel effect (controls falloff)
        _FresnelBias ("Fresnel Bias", Range(0, 1)) = 0.1 // Bias for Fresnel effect (controls minimum reflectivity)
        _Shininess ("Shininess", Range(0.03, 1)) = 0.078125 // For a simple specular highlight (optional)
        _SurfaceSmoothness ("Surface Smoothness", Range(0, 1)) = 0.9 // For reflection probe sampling smoothness (simulated)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" }

        Pass
        {
            // For transparent objects
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off // Don't write to Z-buffer so objects behind are visible
            Cull Back // Cull back faces

            HLSLPROGRAM
            // HLSL setup directives
            #pragma prefer_hlslcc gles // Optimize for GLES (mobile)
            #pragma target 2.0 // Broad mobile compatibility

            // Define vertex and fragment shaders
            #pragma vertex vert
            #pragma fragment frag

            // Include URP core libraries
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl" // For common lighting functions, like Reflect

            // Declare textures and samplers
            TEXTURE2D(_NormalMap);           SAMPLER(sampler_NormalMap);
            TEXTURE2D(_CameraOpaqueTexture); SAMPLER(sampler_CameraOpaqueTexture); // URP's screen texture for refraction
            // Note: _GlossyEnvironmentData, _GlossyEnvironmentCube, etc., are usually managed by URP for reflection probes
            // We'll simulate a simple sample here.

            // Declare shader properties
            CBUFFER_START(UnityProperties)
                half4 _BaseColor;
                half _NormalScale;
                half2 _NormalScrollSpeed;
                half _RefractionStrength;
                half _ReflectionStrength;
                half _FresnelPower;
                half _FresnelBias;
                half _Shininess;
                half _SurfaceSmoothness; // Used for simple reflection quality
            CBUFFER_END

            // Vertex input structure
            struct Attributes
            {
                float4 positionOS : POSITION; // Object space position
                float3 normalOS : NORMAL;     // Object space normal
                float4 tangentOS : TANGENT;   // Object space tangent
                float2 uv : TEXCOORD0;        // UV coordinates
            };

            // Vertex output / Fragment input structure
            struct Varyings
            {
                float4 positionCS : SV_POSITION;  // Clip space position
                float3 worldPos : TEXCOORD0;      // World space position
                float3 worldNormal : TEXCOORD1;   // World space normal
                float3 worldTangent : TEXCOORD2;  // World space tangent
                float3 worldBinormal : TEXCOORD3; // World space binormal (calculated in vert)
                float2 uv : TEXCOORD4;            // UV for normal map
                float4 screenPos : TEXCOORD5;     // Screen position for refraction
            };

            // Vertex Shader
            Varyings vert(Attributes input)
            {
                Varyings output;

                // Transform position from object to clip space
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);

                // Transform position, normal, tangent to world space
                output.worldPos = TransformObjectToWorld(input.positionOS.xyz);
                output.worldNormal = TransformObjectToWorldNormal(input.normalOS);
                output.worldTangent = TransformObjectToWorldDir(input.tangentOS.xyz);
                // Calculate world binormal
                output.worldBinormal = cross(output.worldNormal, output.worldTangent) * input.tangentOS.w;

                // Pass UVs
                output.uv = input.uv;

                // Calculate screen position for refraction lookup
                output.screenPos = ComputeScreenPos(output.positionCS);

                return output;
            }

            // Fragment Shader
            half4 frag(Varyings input) : SV_Target
            {
                // Normalize vectors for accurate calculations
                input.worldNormal = normalize(input.worldNormal);
                input.worldTangent = normalize(input.worldTangent);
                input.worldBinormal = normalize(input.worldBinormal);

                // Construct tangent to world space matrix
                float3x3 TBN = float3x3(input.worldTangent, input.worldBinormal, input.worldNormal);

                // --- Normal Mapping ---
                // Sample normal map and apply scrolling
                float2 scrolledUV = input.uv * _NormalScale + _Time.y * _NormalScrollSpeed;
                half3 tangentSpaceNormal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, scrolledUV));

                // Transform normal from tangent space to world space
                half3 finalWorldNormal = mul(tangentSpaceNormal, TBN);
                finalWorldNormal = normalize(finalWorldNormal); // Re-normalize after transformation

                // --- View Direction ---
                // Vector from world position to camera position
                half3 viewDir = normalize(_WorldSpaceCameraPos - input.worldPos);

                // --- Refraction (Screen Space Distortion) ---
                float2 refractUV = input.screenPos.xy / input.screenPos.w; // Perspective divide to get true screen UV

                // Use the world normal for distortion direction
                // A simplified "Snell's Window" effect: offset UVs based on normal
                half2 distortion = finalWorldNormal.xy * _RefractionStrength;
                refractUV += distortion;

                // Sample the opaque scene texture with distorted UVs
                half4 refractedColor = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, refractUV);

                // --- Reflection ---
                // Calculate reflection vector
                half3 reflectedDir = reflect(-viewDir, finalWorldNormal);

                // A very simplified approach to get SOME reflection without URP's full probe system:
                half3 reflectionColor = half3(0.8, 0.9, 1.0) * _ReflectionStrength; // Placeholder "sky" reflection color

                // --- Fresnel Effect ---
                // Makes reflections stronger at grazing angles
                half fresnel = _FresnelBias + (1.0 - _FresnelBias) * pow(1.0 - saturate(dot(viewDir, finalWorldNormal)), _FresnelPower);

                // --- Combine Refraction and Reflection ---
                // Blend based on Fresnel
                half4 finalColor = lerp(refractedColor, half4(reflectionColor, 1.0), fresnel);

                // Apply base color tinting and transparency
                finalColor.rgb *= _BaseColor.rgb;
                finalColor.a = _BaseColor.a; // Use base color's alpha for overall transparency

                return finalColor;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError" // Essential for URP shaders
}