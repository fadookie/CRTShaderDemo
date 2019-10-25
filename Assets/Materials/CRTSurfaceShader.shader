Shader "Custom/CRTSurfaceShader"
{
    Properties
    {
        _WaveSpeed ("Wave Speed", Range(1,20)) = 10
        _BandSize ("Band Size", Range(0.001,2.0)) = 0.5
        _AlphaOffset ("Alpha Offset", Range(-2.0,2.0)) = -0.14
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        // Also enable support for alpha blending.
        #pragma surface surf Standard fullforwardshadows alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _WaveSpeed;
        half _BandSize;
        half _AlphaOffset;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        //Taken from http://www.chilliant.com/rgb2hsv.html
        float3 HUEtoRGB(in float H)
        {
            float R = abs(H * 6 - 3) - 1;
            float G = 2 - abs(H * 6 - 2);
            float B = 2 - abs(H * 6 - 4);
            return saturate(float3(R,G,B));
        }
        
        float3 HSVtoRGB(in float3 HSV)
        {
            float3 RGB = HUEtoRGB(HSV.x);
            return ((RGB - 1) * HSV.y + 1) * HSV.z;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c;
            // Take world Y position of surface, tweak value a bit, and add offset of an animated sine wave
            float waveOffset = frac(((IN.worldPos.y * _BandSize)) + (_SinTime.w * _WaveSpeed));
            c.rgb = HSVtoRGB(float3(
                waveOffset,
                1.0,
                1.0
            )); //
            // Also animate alpha in a wave, applying user offset
            c.a = waveOffset + _AlphaOffset;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
