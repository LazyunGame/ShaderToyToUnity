using System;
using UnityEngine;

namespace ShaderToyRenderer
{
    public class ShaderToyRendererInput : MonoBehaviour
    {
        private bool _isDown = false, _isFirstDown;
        private Vector3 _lastPos, _lastDownPos;


        public Action<Vector3> onMouseMove, onMouseDown, onMouseUp, onMouseClick;


        void Update()
        {
            var p = Input.mousePosition;

            if (_isFirstDown)
            {
                if (onMouseClick != null)
                {
                    onMouseClick(p);
                }

                _isFirstDown = false;
            }


            if (Input.GetMouseButtonDown(0))
            {
                if (onMouseDown != null)
                {
                    onMouseDown(p);
                }

                _isDown = true;
                _isFirstDown = true;
            }

            if (Input.GetMouseButtonUp(0))
            {
                _isDown = false;

                if (onMouseUp != null)
                {
                    onMouseUp(p);
                }
            }

            if (_isDown)
            {
                if (onMouseMove != null)
                {
                    onMouseMove(p);
                }

                _lastPos = p;
            }
            else
            {
                if (onMouseMove != null)
                {
                    onMouseMove(Vector3.zero);
                }
            }
        }
    }

    public class ShaderToy
    {
        public static int iUVMouse = Shader.PropertyToID("iUVMouse");

        public static int iMouse = Shader.PropertyToID("iMouse");
        public static int iFrame = Shader.PropertyToID("iFrame");
        public static int iDate = Shader.PropertyToID("iDate");
        public static int iSampleRate = Shader.PropertyToID("iSampleRate");
        public static int iChannel0 = Shader.PropertyToID("iChannel0");
        public static int iChannel1 = Shader.PropertyToID("iChannel1");
        public static int iChannel2 = Shader.PropertyToID("iChannel2");
        public static int iChannel3 = Shader.PropertyToID("iChannel3");
    }
}