using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public class DummyToonAudioTextureEditorGUI : DummyToonEditorGUI
    {
        // Audio Texture
        private MaterialProperty audioMaskTex = null;
        private MaterialProperty audioTextureSampleUv = null;

        // Keeps track of which sections are opened and closed.
        private bool audioTextureExpanded = false;

        protected override void DrawShaderProperties()
        {
            base.DrawShaderProperties();
            DrawAudioTexture();
        }

        private void DrawAudioTexture()
        {
            audioTextureExpanded = Section("Audio Texture", audioTextureExpanded);
            if (!audioTextureExpanded)
            {
                return;
            }

            editor.TexturePropertySingleLine(new GUIContent("Audio Texture Mask", "Mask texture that defines how affected by the audio texture this part is."), audioMaskTex);
            editor.VectorProperty(audioTextureSampleUv, "Sample Location UV (XY)");
        }

        protected override void FindProperties(MaterialProperty[] props)
        {
            base.FindProperties(props);

            // Audio texture
            audioMaskTex = FindProperty("_AudioTextureMask");
            audioTextureSampleUv = FindProperty("_AudioTextureSampleLocation");
        }
    }
}