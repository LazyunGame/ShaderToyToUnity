Shader "Custom/ShaderToyUnlit"
{
    Properties
    {
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_ShaderToyFinalTexture);
            SAMPLER(sampler_ShaderToyFinalTexture);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            real4 frag (v2f i) : SV_Target
            {
                real4 col = SAMPLE_TEXTURE2D(_ShaderToyFinalTexture,sampler_ShaderToyFinalTexture, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
