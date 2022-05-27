using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using ShaderToyRenderer.Data;
using UnityEngine;
using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace ShaderToyRenderer
{
    public class ShaderToyRenderer : MonoBehaviour
    {
        public ShaderToyRendererAsset data;
        public MeshRenderer renderTarget;
        public RawImage uiRenderTarget;
        public ShaderToyRendererInput input;

        private Vector4 mousePosition;


        private IEnumerator Start()
        {
            if (data)
            {
                data = Instantiate(data);
                // data.Init();
            }

            yield return null;
            if (data)
            {
                if (renderTarget != null)
                {
                    renderTarget.material = data.mainMaterial;
                }
                else
                {
                    if (uiRenderTarget != null)
                        uiRenderTarget.texture = data.mainMaterial.GetTexture(ShaderToy.iChannel0);
                }

                // Shader.SetGlobalTexture("_RippleMap", data.bufferA.RenderTexture);
                // GetComponent<MeshRenderer>().material.SetTexture("_RippleMap", data.bufferA.RenderTexture);
            }

            if (input)
            {
                input.onMouseDown = mp =>
                {
                    mousePosition.z = mp.x;
                    mousePosition.w = mp.y;
                    data.SetMousePosition(mousePosition);
                };

                input.onMouseClick = mp =>
                {
                    mousePosition.z = mp.x;
                    mousePosition.w = mp.y;
                    data.SetMousePosition(mousePosition);
                };

                input.onMouseMove = mp =>
                {
                    mousePosition.x = mp.x;
                    mousePosition.y = mp.y;
                    data.SetMousePosition(mousePosition);
                };
            }
        }


        void Update()
        {
            if (data != null)
            {
                data.Render();
            }
        }

        private void OnDestroy()
        {
            if (data)
                data.OnDispose();
        }
    }
}