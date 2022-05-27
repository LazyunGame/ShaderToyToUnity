using UnityEngine;

namespace ShaderToyRenderer.Data
{
    [CreateAssetMenu(fileName = "ShaderToyRendererAsset.asset", menuName = "ShaderToy Renderer Asset", order = 0)]
    public class ShaderToyRendererAsset : ScriptableObject
    {
        public ChannelBuffer bufferA;
        public ChannelBuffer bufferB;
        public ChannelBuffer bufferC;
        public ChannelBuffer bufferD;
        public ChannelBuffer image;

        public Material mainMaterial;


        private bool _isInit;

        public void Init()
        {
            if (bufferA.bufferName != ChannelEnum.none)
            {
                bufferA.Connect(new ChannelBuffer[] {bufferA, bufferB, bufferC, bufferD, image});
            }

            if (bufferB.bufferName != ChannelEnum.none)
            {
                bufferB.Connect(new ChannelBuffer[] {bufferA, bufferB, bufferC, bufferD, image});
            }

            if (bufferC.bufferName != ChannelEnum.none)
            {
                bufferC.Connect(new ChannelBuffer[] {bufferA, bufferB, bufferC, bufferD, image});
            }

            if (bufferD.bufferName != ChannelEnum.none)
            {
                bufferD.Connect(new ChannelBuffer[] {bufferA, bufferB, bufferC, bufferD, image});
            }


            if (image.bufferName != ChannelEnum.none)
                image.Connect(new ChannelBuffer[] {bufferA, bufferB, bufferC, bufferD, image});

            if (image.bufferName != ChannelEnum.none && !mainMaterial)
            {
                mainMaterial = new Material(Shader.Find("Unlit/Display"));
            }

            if (image.bufferName != ChannelEnum.none)
                mainMaterial.SetTexture("iChannel0", image.RenderTexture);

            _isInit = true;
            FrameCount = 0;
        }

        [HideInInspector] public int FrameCount;

        public void Render()
        {
            if (!_isInit)
            {
                Init();
            }

            SetInt(ShaderToy.iFrame, FrameCount);
            if (bufferA.isConnected)
            {
                bufferA.Render();
            }

            if (bufferB.isConnected)
            {
                bufferB.Render();
            }

            if (bufferC.isConnected)
            {
                bufferC.Render();
            }

            if (bufferD.isConnected)
            {
                bufferD.Render();
            }

            if (image != null && image.isConnected)
                image.Render();
            FrameCount++;
        }

        public void OnDispose()
        {
            if (bufferA.isConnected)
            {
                bufferA.OnDispose();
            }

            if (bufferB.isConnected)
            {
                bufferB.OnDispose();
            }

            if (bufferC.isConnected)
            {
                bufferC.OnDispose();
            }

            if (bufferD.isConnected)
            {
                bufferD.OnDispose();
            }
        }

        public void SetInt(int name, int f)
        {
            Shader.SetGlobalInt(name, f);
            if (bufferA.isConnected)
            {
                bufferA.SetInt(name, f);
            }

            if (bufferB.isConnected)
            {
                bufferB.SetInt(name, f);
            }

            if (bufferC.isConnected)
            {
                bufferC.SetInt(name, f);
            }

            if (bufferD.isConnected)
            {
                bufferD.SetInt(name, f);
            }

            if (image != null && image.isConnected)
                image.SetInt(name, f);
        }


        public void SetMousePosition(Vector4 mousePos)
        {
            Debug.Log(mousePos);
            if (bufferA.isConnected)
            {
                bufferA.SetMousePosition(mousePos);
            }

            if (bufferB.isConnected)
            {
                bufferB.SetMousePosition(mousePos);
            }

            if (bufferC.isConnected)
            {
                bufferC.SetMousePosition(mousePos);
            }

            if (bufferD.isConnected)
            {
                bufferD.SetMousePosition(mousePos);
            }

            if (image != null && image.isConnected)
                image.SetMousePosition(mousePos);
        }
    }
}