using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public class DummyToonMobileEditorGUI : DummyToonEditorBase
    {
        private MaterialProperty mainTex = null;
        private MaterialProperty color = null;
        private MaterialProperty guessLightDir = null;
        private MaterialProperty useVertexColor = null;

        private MaterialProperty ramp = null;
        private MaterialProperty matcap = null;

        private bool guessLightDirHelpExpanded = false;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditor, properties);

            DrawMain();

            editor.RenderQueueField();

#if SHADEROPTIMIZER_INSTALLED
            if (CanMaterialBeLocked())
            {
                DrawShaderOptimizer();
            }
#endif

            DrawVersion();

            SetupKeywords();
        }

        private void DrawMain()
        {
            ColorProperty(color, "Color");
            TextureProperty(mainTex, "Main Texture", false);

            if (HasRamp())
            {
                ToonRampPropertyFullWidth("Toon Ramp", ramp);
            }

            if (HasMatcap())
            {
                TextureProperty(matcap, "Matcap", false);
            }

            ShaderPropertyWithHelp(
                guessLightDir,
                new GUIContent("Guess Light Direction", "Whether the directional light should be ignored and the light dir/color should be inferred from ambient."),
                ref guessLightDirHelpExpanded,
                "If enabled, the light direction and color is inferred from the ambient lighting. Useful if there are no realtime lights in the scene.\r\n\r\n" +
                "If disabled, the direction and color of the most important directional light is used.\r\n\r\n" +
                "When disabled, this feature can still be enabled if the global keyword \"_GUESSLIGHTDIR_GLOBAL_ON\" is enabled."
            );

            editor.ShaderProperty(useVertexColor, new GUIContent("Use Vertex Colors", "If enabled, the model's vertex colors are used as color tint."));
        }

        protected override void FindProperties(MaterialProperty[] props)
        {
            base.FindProperties(props);

            mainTex = FindProperty("_MainTex");
            color = FindProperty("_Color");
            guessLightDir = FindProperty("_GuessLightDir");
            useVertexColor = FindProperty("_UseVertexColor");

            ramp = FindProperty("_Ramp", false);
            matcap = FindProperty("_Matcap", false);
        }

        private bool HasRamp()
        {
            return this.ramp != null;
        }

        private bool HasMatcap()
        {
            return this.matcap != null;
        }

#if SHADEROPTIMIZER_INSTALLED
        private void DrawShaderOptimizer()
        {
            if (IsMaterialLocked())
            {
                if (GUILayout.Button("Unlock shader"))
                {
                    UnlockAllSelectedMaterials();
                }
            }
            else
            {
                if (GUILayout.Button("Lock in optimized shader"))
                {
                    LockAllSelectedMaterials();
                }
            }
        }
#endif

        private void SetupKeywords()
        {
            foreach (var mat in this.materials)
            {
                // Clear out all existing keywords first
                mat.shaderKeywords = new string[] { };

                if (mat.GetTexture("_MainTex") != null)
                {
                    mat.EnableKeyword("_MAINTEX_ON");
                }

                if (!mat.GetColor("_Color").Equals(Color.white))
                {
                    mat.EnableKeyword("_COLOR_ON");
                }

                if (mat.GetFloat("_GuessLightDir") == 1)
                {
                    mat.EnableKeyword("_GUESSLIGHTDIR_ON");
                }

                if (mat.GetFloat("_UseVertexColor") == 1)
                {
                    mat.EnableKeyword("_VERTEXCOLOR_ON");
                }
            }
        }
    }
}
