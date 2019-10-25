Shader "Custom/CRTSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags {"Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
//        #pragma surface surf Standard fullforwardshadows
        #pragma surface surf Standard fullforwardshadows alpha:fade

        // Allow alpha override
//        #pragma surface surf NoLighting alpha
////
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

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
            // Albedo comes from a texture tinted by color
//            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 c;
//            c.rgb = (tex2D (_MainTex, IN.uv_MainTex) * _Color).rgb;
//            if (IN.worldPos.y % 1 == 0) c.rgb = 0;
//            fixed4 c;
//            c.rgb = fixed3(1.0, 0.5, 1.0);
//            c.rgb = HSVtoRGB(float3(0.25, 1.0, 1.0)); //
            float waveOffset = frac(((IN.worldPos.y / 2)) + (_SinTime.w * 5.0));
            c.rgb = HSVtoRGB(float3(
//                _SinTime.x,
                waveOffset,
//                frac(((IN.worldPos.y / 2)) + (_SinTime.w * 10.0)), //perfect!!
                1.0,
                1.0
            )); //
            c.a = waveOffset;
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
