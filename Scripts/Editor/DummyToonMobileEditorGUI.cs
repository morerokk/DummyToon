using UnityEditor;
using UnityEngine;

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
        FindProperties(properties);
        editor = materialEditor;

        material = materialEditor.target as Material;

        DrawMain();

        editor.RenderQueueField();

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

    private void FindProperties(MaterialProperty[] props)
    {
        mainTex = FindProperty("_MainTex", props);
        color = FindProperty("_Color", props);
        guessLightDir = FindProperty("_GuessLightDir", props);
        useVertexColor = FindProperty("_UseVertexColor", props);

        ramp = FindProperty("_Ramp", props, false);
        matcap = FindProperty("_Matcap", props, false);
    }

    private bool HasRamp()
    {
        return this.ramp != null;
    }

    private bool HasMatcap()
    {
        return this.matcap != null;
    }

    private void SetupKeywords()
    {
        // Clear out all existing keywords first
        material.shaderKeywords = new string[] { };

        if(mainTex.textureValue != null)
        {
            material.EnableKeyword("_COLOROVERLAY_ON");
        }
        
        if(!color.colorValue.Equals(Color.white))
        {
            material.EnableKeyword("_COLORCOLOR_ON");
        }

        if(guessLightDir.floatValue == 1)
        {
            material.EnableKeyword("_EMISSION");
        }

        if(useVertexColor.floatValue == 1)
        {
            material.EnableKeyword("_COLORADDSUBDIFF_ON");
        }
    }
}
