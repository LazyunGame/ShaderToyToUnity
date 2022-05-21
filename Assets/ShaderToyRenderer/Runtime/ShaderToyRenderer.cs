using System;
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
        public Camera myCamera;
        public string CameraName;

        private Vector4 mousePosition;
        public Transform xMax, xMin, zMax, zMin;


        public Rect Area
        {
            get
            {
                return new Rect(xMax.position.x, zMax.position.z, Vector3.Distance(xMax.position, xMin.position),
                    Vector3.Distance(zMax.position, zMin.position));
            }
        }

        private void Start()
        {
            if (data)
            {
                data = Instantiate(data);
                // data.Init();
            }

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
                GetComponent<MeshRenderer>().material.SetTexture("_RippleMap", data.bufferA.RenderTexture);
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
                if (!myCamera)
                {
                    myCamera = FindObjectsOfType<Camera>().FirstOrDefault(t => t.name == CameraName);
                }

                data.Render(myCamera);
            }
        }

        private void OnDestroy()
        {
            if (data)
                data.OnDispose();
        }
    }
}