Shader "Custom/Unlit/TextureEffectUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveSpeed ("Wave Speed", Range(1,20)) = 10
        _BandSize ("Band Size", Range(0.001,2.0)) = 0.5
        _AlphaOffset ("Alpha Offset", Range(-2.0,2.0)) = -0.14
        [Enum(Additive,0,Multiplicative,1,Alpha,2,Replace,3)] _TextureBlendMode ("Texture Blend Mode", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _WaveSpeed;
            half _BandSize;
            half _AlphaOffset;
            int _TextureBlendMode;
            
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 c = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, c);
                
                fixed4 overlay;
                float waveOffset = frac(((i.worldPos.y * _BandSize)) + (_SinTime.w * _WaveSpeed));
                overlay.rgb = HSVtoRGB(float3(
                    waveOffset,
                    1.0,
                    1.0
                )); //
                // Also animate alpha in a wave, applying user offset
                overlay.a = waveOffset + _AlphaOffset;
                
                // Blend procedural pattern with uniform texture
                // There are other types of blending but these and alpha are the main ones
                switch(_TextureBlendMode) {
                    case 0: { // Additive blend
                        c.rgb += overlay.rgb; 
                        break;
                    } case 1: { // Multiplicative blend
                        c.rgb *= overlay.rgb; 
                        break;
                    } case 2: { // Simple alpha blend - I may not have implemented this properly sorry
                        overlay += (1 - overlay.a) * c;
                        c = overlay;
                        break;
                    } case 3: { // Replace texture
                        c.rgb = overlay.rgb; 
                        break;
                    }
                }
                return c;
            }
            ENDCG
        }
    }
}
