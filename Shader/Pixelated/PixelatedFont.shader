// This Unity Shader creates a pixelated font effect by combining a custom
// pixelation logic in the fragment shader with the ability to control
// pixel size and transparency threshold. It's designed to work with
// TextMeshPro or any mesh that uses a texture.

Shader "Custom/PixelatedFont_HLSL"
{
    // Properties exposed in the Unity Inspector for easy adjustment
    Properties
    {
        // _MainTex: The primary texture for the material. For TextMeshPro,
        // this will be the font atlas texture.
        _MainTex ("Font Atlas (Texture)", 2D) = "white" {}

        // _PixelSize: Controls the "blockiness" or apparent size of the pixels.
        // A smaller value means more pixels, a larger value means chunkier pixels.
        _PixelSize ("Pixel Scale", Range(0.001, 0.2)) = 0.01

        // _Threshold: Controls the alpha cut-off for the *inner* part of the font.
        // Pixels with alpha below this value start becoming transparent.
        _Threshold ("Sharpness Threshold", Range(0.0, 1.0)) = 0.5

        // _Color: A tint color for the font, useful for changing font color directly
        // in the material rather than relying solely on vertex colors.
        _Color ("Text Color", Color) = (1,1,1,1) // Default to white, fully opaque

        // _OutlineColor: Color of the pixelated outline.
        _OutlineColor ("Outline Color", Color) = (0,0,0,1) // Default to black, fully opaque

        // _OutlineXOffset: Controls the horizontal offset of the outline layer in UV space.
        // Positive values shift the outline right, negative left.
        _OutlineXOffset ("Outline X Offset", Range(-0.1, 0.1)) = 0.0

        // _OutlineYOffset: Controls the vertical offset of the outline layer in UV space.
        // Positive values shift the outline up, negative down.
        _OutlineYOffset ("Outline Y Offset", Range(-0.1, 0.1)) = 0.0

        // _OutlineScale: Controls the overall size of the outline layer relative to the main text.
        // Values > 1.0 expand the outline, < 1.0 shrink it.
        _OutlineScale ("Outline Scale", Range(0.5, 1.5)) = 1.1
    }
    SubShader
    {
        // Tags define how the shader interacts with the render pipeline.
        // "RenderType"="Transparent": Indicates transparent objects.
        // "RenderPipeline"="UniversalPipeline": Specifies it's for URP.
        // "Queue"="Transparent": Ensures it's rendered after opaque objects.
        Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" }
        LOD 100 // Level of Detail setting

        // Render States: These control how the GPU renders.
        // Blend: Configures how the fragment's color is combined with what's already on screen.
        // SrcAlpha OneMinusSrcAlpha: Standard alpha blending (e.g., for transparency).
        // This means (SourceColor * SourceAlpha) + (DestinationColor * (1 - SourceAlpha))
        Blend SrcAlpha OneMinusSrcAlpha

        // Cull Off: Disables backface culling, so both sides of the mesh are rendered.
        // This is useful for text that might be viewed from different angles.
        Cull Off

        // ZWrite Off: Prevent this shader from writing to the depth buffer.
        // Essential for transparent objects to render correctly on top of others,
        // as transparent objects should not block opaque objects behind them.
        ZWrite Off

        Pass
        {
            // HLSLPROGRAM/ENDHLSL define the start and end of our HLSL code block.
            HLSLPROGRAM
            // #pragma directives tell Unity about our shader functions and features.
            #pragma vertex Vert // Specifies Vert as the vertex shader entry point.
            #pragma fragment Frag // Specifies Frag as the fragment shader entry point.

            // Include necessary URP shader libraries for common functions and structs.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // Attributes struct: Defines the input data for each vertex from the mesh.
            struct Attributes
            {
                float4 positionOS   : POSITION; // Vertex position in object space.
                float2 uv           : TEXCOORD0; // UV coordinates for texture sampling.
                float4 color        : COLOR;     // Vertex color (e.g., from TextMeshPro).
            };

            // Varyings struct: Defines the data passed from the vertex shader to the fragment shader.
            struct Varyings
            {
                float4 positionCS : SV_POSITION; // Clip space position (used for screen rendering).
                float2 uv         : TEXCOORD0; // UVs interpolated across the triangle.
                float4 color      : COLOR;     // Vertex color interpolated across the triangle.
            };

            // Declare our texture and its sampler state explicitly using URP conventions.
            TEXTURE2D(_MainTex); // Declares the texture object
            SAMPLER(sampler_MainTex); // Declares the sampler state for _MainTex

            // Declare our shader properties as CBUFFER variables for efficient data transfer.
            CBUFFER_START(UnityProperties)
                float _PixelSize;
                float _Threshold;
                float4 _Color; // Main text color
                float4 _OutlineColor; // Outline color
                float _OutlineXOffset; // X offset for outline layer
                float _OutlineYOffset; // Y offset for outline layer
                float _OutlineScale; // Scale for outline layer
            CBUFFER_END

            // Vertex Shader: Transforms vertex data for the fragment shader.
            Varyings Vert(Attributes input)
            {
                Varyings output;
                // Transform the object space position to clip space (screen position).
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv; // Pass original UVs.
                output.color = input.color; // Pass vertex color.
                return output;
            }

            // Fragment Shader: Determines the final color of each pixel, implementing layered outline.
            half4 Frag(Varyings input) : SV_Target
            {
                // Step 1: Calculate the pixelated UV coordinate for the current fragment for the main text.
                float2 pixelatedUv = floor(input.uv / _PixelSize) * _PixelSize + 0.5 * _PixelSize;

                // Step 2: Sample the alpha for the main text layer.
                half mainAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixelatedUv).a;
                mainAlpha *= input.color.a * _Color.a; // Apply vertex and material color alphas

                // Step 3: Calculate the UV for sampling the outline layer.
                // Apply scaling around the center (0.5, 0.5) first.
                float2 baseOutlineUv = (input.uv - 0.5) * _OutlineScale + 0.5;
                // Then apply the manual offset for outline position.
                baseOutlineUv += float2(_OutlineXOffset, _OutlineYOffset);
                // Finally, apply pixelation to this transformed UV.
                float2 outlineOffsetUv = floor(baseOutlineUv / _PixelSize) * _PixelSize + 0.5 * _PixelSize;

                // Step 4: Sample the alpha for the outline layer.
                half outlineAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, outlineOffsetUv).a;
                outlineAlpha *= input.color.a * _OutlineColor.a; // Use outline color's alpha for its visibility

                half4 finalColor = 0; // Initialize final color

                // Step 5: Prioritize drawing the main text, then the outline, otherwise discard.
                // If the main text pixel is above the threshold, draw it.
                if (mainAlpha >= _Threshold)
                {
                    finalColor.rgb = input.color.rgb * _Color.rgb; // Apply main text color
                    finalColor.a = 1.0; // Ensure it's fully opaque
                }
                // Else, if the outline pixel is above the threshold (and main text isn't present), draw the outline.
                else if (outlineAlpha >= _Threshold)
                {
                    finalColor.rgb = _OutlineColor.rgb; // Apply outline color
                    finalColor.a = 1.0; // Ensure it's fully opaque
                }
                // Otherwise, the pixel is neither main text nor outline, so discard it.
                else
                {
                    discard; // Instructs the GPU to not render this pixel.
                    return 0; // Return dummy value, as discard will prevent it from being used
                }

                return finalColor;
            }
            ENDHLSL
        }
    }
    // Fallback shader if this shader cannot be used (e.g., unsupported platform).
    // "Standard" is a common fallback, but you might choose "Universal/Unlit" for URP.
    // Fallback "Standard"
}
