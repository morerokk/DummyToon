using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public class DummyToonEyeTrackingEditorGUI : DummyToonEditorGUI
    {
        //Eye tracking
        private MaterialProperty targetEye = null;
        private MaterialProperty maxLookRange = null;
        private MaterialProperty maxLookDistance = null;
        private MaterialProperty eyeTrackPatternTexture = null;
        private MaterialProperty eyeTrackSpeed = null;
        private MaterialProperty eyeTrackBlur = null;
        private MaterialProperty eyeTrackBlenderCorrection = null;

        // Keeps track of which sections are opened and closed.
        private bool eyeTrackingExpanded = false;

        private bool eyeTrackingTextureHelpExpanded = false;
        private bool eyeTrackingRotationCorrectionHelpExpanded = false;

        protected override void DrawShaderProperties()
        {
            base.DrawShaderProperties();
            DrawEyeTracking();
        }

        private void DrawEyeTracking()
        {
            eyeTrackingExpanded = Section("Eye Tracking", eyeTrackingExpanded);
            if (!eyeTrackingExpanded)
            {
                return;
            }

            editor.ShaderProperty(targetEye, new GUIContent("Target Eye", "In VR, this defines which eye the current eye should be looking at, allowing for more natural eye contact. No effect in non-VR."));

            editor.RangeProperty(maxLookRange, "Maximum Look Range");

            editor.FloatProperty(maxLookDistance, "Maximum Look Distance");

            TexturePropertyWithHelp(new GUIContent("Eye Tracking Pattern Texture"), eyeTrackPatternTexture, ref eyeTrackingTextureHelpExpanded, "The eye tracking pattern texture should be a horizontal black and white gradient texture. It scrolls from left to right over time. When the current pixel is black, the eyes will look straight ahead. When the current pixel is white, the eyes will look straight towards the camera. In-between values are possible.");

            editor.RangeProperty(eyeTrackSpeed, "Pattern Scroll Speed");

            editor.RangeProperty(eyeTrackBlur, "Pattern Blur");

            ShaderPropertyWithHelp(eyeTrackBlenderCorrection, new GUIContent("Blender rotation correction"), ref eyeTrackingRotationCorrectionHelpExpanded, "Blender FBX exports may be rotated 90 degrees on the X axis depending on export settings. Tick/untick this box if you experience this happening to your mesh.");
        }

        protected override void FindProperties(MaterialProperty[] props)
        {
            base.FindProperties(props);

            //Eye tracking stuff
            targetEye = FindProperty("_TargetEye");
            maxLookRange = FindProperty("_MaxLookRange");
            maxLookDistance = FindProperty("_MaxLookDistance");
            eyeTrackPatternTexture = FindProperty("_EyeTrackingPatternTex");
            eyeTrackSpeed = FindProperty("_EyeTrackingScrollSpeed");
            eyeTrackBlur = FindProperty("_EyeTrackingBlur");
            eyeTrackBlenderCorrection = FindProperty("_EyeTrackingRotationCorrection");
        }
    }
}