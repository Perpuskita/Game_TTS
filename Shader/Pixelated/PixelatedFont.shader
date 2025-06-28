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
        // Pixels with alpha below this value start becoming transparent or part of the outline.
        _Threshold ("Sharpness Threshold", Range(0.0, 1.0)) = 0.5

        // _Color: A tint color for the font, useful for changing font color directly
        // in the material rather than relying solely on vertex colors.
        _Color ("Text Color", Color) = (1,1,1,1) // Default to white, fully opaque

        // _OutlineColor: Color of the pixelated outline.
        _OutlineColor ("Outline Color", Color) = (0,0,0,1) // Default to black, fully opaque

        // _OutlineThickness: Controls the width of the outline.
        // This value defines the 'distance' from the character's solid form
        // where the outline will appear. A larger value means a thicker outline.
        _OutlineThickness ("Outline Thickness", Range(0.0, 0.2)) = 0.01 // Increased max range

        // Toggles for showing outline on specific sides. 0 = off, 1 = on.
        [Toggle] _OutlineLeft ("Show Left Outline", Float) = 1
        [Toggle] _OutlineRight ("Show Right Outline", Float) = 1
        [Toggle] _OutlineTop ("Show Top Outline", Float) = 1
        [Toggle] _OutlineBottom ("Show Bottom Outline", Float) = 1
        [Toggle] _OutlineTopLeft ("Show Top-Left Outline", Float) = 1
        [Toggle] _OutlineTopRight ("Show Top-Right Outline", Float) = 1
        [Toggle] _OutlineBottomLeft ("Show Bottom-Left Outline", Float) = 1
        [Toggle] _OutlineBottomRight ("Show Bottom-Right Outline", Float) = 1
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
                float _OutlineThickness; // Outline thickness
                // Outline side toggles (0 = off, 1 = on)
                float _OutlineLeft;
                float _OutlineRight;
                float _OutlineTop;
                float _OutlineBottom;
                float _OutlineTopLeft;
                float _OutlineTopRight;
                float _OutlineBottomLeft;
                float _OutlineBottomRight;
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

            // Fragment Shader: Determines the final color of each pixel, including outline.
            half4 Frag(Varyings input) : SV_Target
            {
                // Step 1: Calculate the pixelated UV coordinate for the current pixel.
                float2 pixelatedUv = floor(input.uv / _PixelSize) * _PixelSize + 0.5 * _PixelSize;

                // Step 2: Sample the main texture (font atlas) at the pixelated UV coordinate
                // to get the alpha value of the current pixel.
                half currentAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, pixelatedUv).a;

                // Combine with vertex color alpha and material color alpha for overall character presence.
                currentAlpha *= input.color.a * _Color.a;

                half4 finalColor = 0; // Initialize final color

                // Define the threshold for the outer edge of the outline.
                half outlineThreshold = _Threshold - _OutlineThickness;

                // Step 3: Determine if the pixel is part of the main text, outline, or fully transparent.

                // If current pixel's alpha is above the main threshold, it's the solid text.
                if (currentAlpha >= _Threshold)
                {
                    finalColor.rgb = input.color.rgb * _Color.rgb; // Apply main text color
                    finalColor.a = 1.0; // Fully opaque
                }
                // Else, check for outline conditions.
                else if (currentAlpha >= outlineThreshold) // Current pixel is within the outline range
                {
                    bool isOutline = false;

                    // Sample neighboring pixels to detect edges for directional outline
                    // These offsets are based on the _PixelSize to ensure they align with the pixel grid
                    float2 uv_left          = pixelatedUv + float2(-_PixelSize, 0.0);
                    float2 uv_right         = pixelatedUv + float2(_PixelSize, 0.0);
                    float2 uv_bottom        = pixelatedUv + float2(0.0, -_PixelSize);
                    float2 uv_top           = pixelatedUv + float2(0.0, _PixelSize);
                    float2 uv_top_left      = pixelatedUv + float2(-_PixelSize, _PixelSize);
                    float2 uv_top_right     = pixelatedUv + float2(_PixelSize, _PixelSize);
                    float2 uv_bottom_left   = pixelatedUv + float2(-_PixelSize, -_PixelSize);
                    float2 uv_bottom_right  = pixelatedUv + float2(_PixelSize, -_PixelSize);

                    // Sample alpha for neighbors (ensuring to apply vertex and material alpha factors)
                    half alpha_left         = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_left).a * input.color.a * _Color.a;
                    half alpha_right        = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_right).a * input.color.a * _Color.a;
                    half alpha_bottom       = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_bottom).a * input.color.a * _Color.a;
                    half alpha_top          = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_top).a * input.color.a * _Color.a;
                    half alpha_top_left     = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_top_left).a * input.color.a * _Color.a;
                    half alpha_top_right    = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_top_right).a * input.color.a * _Color.a;
                    half alpha_bottom_left  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_bottom_left).a * input.color.a * _Color.a;
                    half alpha_bottom_right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv_bottom_right).a * input.color.a * _Color.a;

                    // Check if current pixel is outline AND an edge exists on the enabled side
                    // An edge exists if the neighbor in that direction is *outside* the outline threshold (i.e., transparent).
                    if (_OutlineLeft > 0.5 && alpha_left < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineRight > 0.5 && alpha_right < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineBottom > 0.5 && alpha_bottom < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineTop > 0.5 && alpha_top < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineTopLeft > 0.5 && alpha_top_left < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineTopRight > 0.5 && alpha_top_right < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineBottomLeft > 0.5 && alpha_bottom_left < outlineThreshold) {
                        isOutline = true;
                    }
                    if (_OutlineBottomRight > 0.5 && alpha_bottom_right < outlineThreshold) {
                        isOutline = true;
                    }

                    if (isOutline) {
                        finalColor.rgb = _OutlineColor.rgb; // Apply outline color
                        finalColor.a = 1.0; // Fully opaque
                    } else {
                        discard; // If it's in the outline range but no selected edge, discard
                    }
                }
                // Otherwise, the pixel is outside both the text and the outline, so discard it.
                else
                {
                    discard; // Instructs the GPU to not render this pixel.
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
