using UnityEditor;
using UnityEngine;

public class RokkToonEditorGUI : ShaderGUI
{
    // Main
    private MaterialProperty mainTex = null;
    private MaterialProperty color = null;
    private MaterialProperty bumpMap = null;
    private MaterialProperty bumpScale = null;
    private MaterialProperty cutoff = null;
    private MaterialProperty emissionMap = null;
    private MaterialProperty emissionColor = null;
    private MaterialProperty cullMode = null;
    private MaterialProperty renderMode = null;
    private MaterialProperty zWrite = null;
    private MaterialProperty cutoutEnabled = null;

    // Toon lighting
    private MaterialProperty ramp = null;
    private MaterialProperty toonContrast = null;
    private MaterialProperty toonRampOffset = null;
    private MaterialProperty staticToonLight = null;
    private MaterialProperty intensity = null;
    private MaterialProperty saturation = null;
    private MaterialProperty directLightBoost = null;
    private MaterialProperty indirectLightBoost = null;

    // Metallic and specular
    private MaterialProperty metallicMode = null;
    private MaterialProperty metallicMapTex = null;
    private MaterialProperty metallic = null;
    private MaterialProperty smoothness = null;
    private MaterialProperty specularTex = null;
    private MaterialProperty specularColor = null;

    // Ramp masking
    private MaterialProperty rampMaskingEnabled = null;
    private MaterialProperty rampMaskTex = null;
    private MaterialProperty rampR = null;
    private MaterialProperty toonContrastR = null;
    private MaterialProperty toonRampOffsetR = null;
    private MaterialProperty intensityR = null;
    private MaterialProperty saturationR = null;
    private MaterialProperty rampG = null;
    private MaterialProperty toonContrastG = null;
    private MaterialProperty toonRampOffsetG = null;
    private MaterialProperty intensityG = null;
    private MaterialProperty saturationG = null;
    private MaterialProperty rampB = null;
    private MaterialProperty toonContrastB = null;
    private MaterialProperty toonRampOffsetB = null;
    private MaterialProperty intensityB = null;
    private MaterialProperty saturationB = null;

    // Rimlight
    private MaterialProperty rimLightMode = null;
    private MaterialProperty rimLightColor = null;
    private MaterialProperty rimTex = null;
    private MaterialProperty rimWidth = null;
    private MaterialProperty rimInvert = null;

    // Matcap
    private MaterialProperty matCapTex = null;
    private MaterialProperty matCapMode = null;
    private MaterialProperty matCapStrength = null;

    // Outlines
    private MaterialProperty outlineWidth = null;
    private MaterialProperty outlineColor = null;
    private MaterialProperty outlineTex = null;
    private MaterialProperty outlineScreenspaceEnabled = null;
    private MaterialProperty outlineScreenspaceMinDist = null;
    private MaterialProperty outlineScreenspaceMaxDist = null;
    private MaterialProperty outlineStencilComp = null;
    private MaterialProperty outlineCutout = null;
    private MaterialProperty outlineAlphaWidthEnabled = null;

    // Internal properties
    private MaterialProperty srcBlend = null;
    private MaterialProperty dstBlend = null;

    private MaterialEditor editor;

    private Material material;

    private float defaultLabelWidth;
    private float defaultFieldWidth;

    // Keeps track of which sections are opened and closed.
    private bool mainExpanded = true;
    private bool toonExpanded = true;
    private bool outlinesExpanded = false;
    private bool metallicExpanded = false;
    private bool matcapExpanded = false;
    private bool rimlightExpanded = false;
    private bool miscExpanded = false;

    private bool rampMaskHelpExpanded = false;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //base.OnGUI(materialEditor, properties);
        FindProperties(properties);
        editor = materialEditor;

        material = materialEditor.target as Material;

        defaultLabelWidth = EditorGUIUtility.labelWidth;
        defaultFieldWidth = EditorGUIUtility.fieldWidth;

        DrawMain();
        if (HasOutlines())
        {
            DrawOutlines();
        }
        DrawToonLighting();
        DrawMetallic();
        DrawMatcap();
        DrawRimlight();

        DrawMisc();

        SetupKeywords();
    }

    // Called when user switches to this shader
    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        SetupBlendModes(material);
    }

    private void DrawMain()
    {
        mainExpanded = Section("Main", mainExpanded);
        if (!mainExpanded)
        {
            return;
        }

        //TextureProperty(mainTex, "Main Texture");
        editor.TexturePropertySingleLine(new GUIContent("Main Texture", "The main albedo texture to use."), mainTex, color);

        editor.TexturePropertySingleLine(new GUIContent("Normal Map"), bumpMap, bumpScale);

        editor.TexturePropertySingleLine(new GUIContent("Emission Map"), emissionMap, emissionColor);

        editor.ShaderProperty(cullMode, new GUIContent("Sidedness", "Which sides of the mesh should be rendered."));

        EditorGUI.BeginChangeCheck();
        editor.ShaderProperty(renderMode, new GUIContent("Render Mode", "Change the rendering mode of the material."));
        if (EditorGUI.EndChangeCheck())
        {
            SetupBlendModes();
        }

        EditorGUI.BeginChangeCheck();
        editor.ShaderProperty(cutoutEnabled, new GUIContent("Cutout", "Whether to use alpha-based cutout (alpha testing)."));
        if (EditorGUI.EndChangeCheck())
        {
            SetupBlendModes();
        }

        if (cutoutEnabled.floatValue == 1)
        {
            editor.RangeProperty(cutoff, "Alpha Cutoff");
        }

        editor.ShaderProperty(zWrite, new GUIContent("ZWrite", "Whether the shader should write to the depth buffer or not."));

        if (renderMode.floatValue != 2 && zWrite.floatValue == 0)
        {
            EditorGUILayout.HelpBox("ZWrite is disabled on a non-transparent rendering mode. This is likely not intentional.", MessageType.Warning);
        }
    }

    private void DrawToonLighting()
    {
        toonExpanded = Section("Toon Lighting", toonExpanded);
        if (!toonExpanded)
        {
            return;
        }

        ToonRampProperty(new GUIContent("Toon Ramp"), ramp);

        editor.RangeProperty(toonContrast, "Toon Contrast");
        editor.RangeProperty(toonRampOffset, "Toon Ramp Offset");
        editor.RangeProperty(intensity, "Intensity");
        editor.RangeProperty(saturation, "Saturation");
        editor.RangeProperty(directLightBoost, "Direct Lighting Boost");
        editor.RangeProperty(indirectLightBoost, "Indirect Lighting Boost");

        editor.VectorProperty(staticToonLight, "Fallback light direction");

        // Draw the ramp masking toggle and a help box button horizontally
        EditorGUILayout.BeginHorizontal();
        editor.ShaderProperty(rampMaskingEnabled, new GUIContent("Ramp Masking", "Enable the Ramp Masking feature, allowing you to use RGB masks to define up to 4 toon ramps on the same material."));
        if (GUILayout.Button("?", GUILayout.Width(25)))
        {
            rampMaskHelpExpanded = !rampMaskHelpExpanded;
        }
        EditorGUILayout.EndHorizontal();

        if (rampMaskHelpExpanded)
        {
            EditorGUILayout.HelpBox("Toon Ramp Masking is an experimental feature to allow up to 4 different toon ramps and toon values to be used on the same material. The color of the mask texture defines whether the Red, Green, Blue or Default values are used in that particular area.", MessageType.Info);
        }

        if (rampMaskingEnabled.floatValue == 1)
        {
            DrawRampMasking();
        }
    }

    private void DrawRampMasking()
    {
        editor.TexturePropertySingleLine(new GUIContent("Ramp Mask Tex    ", "A mask texture that dictates which toon ramp goes where (black, red, green, blue)."), rampMaskTex);
        EditorGUILayout.Space();

        //Red ramp
        ToonRampProperty(new GUIContent("Toon Ramp (R)", "The toon ramp texture to use on the red parts of the mask."), rampR);

        editor.RangeProperty(toonContrastR, "Toon Contrast (R)");
        editor.RangeProperty(toonRampOffsetR, "Toon Ramp Offset (R)");
        editor.RangeProperty(intensityR, "Intensity (R)");
        editor.RangeProperty(saturationR, "Saturation (R)");

        EditorGUILayout.Space();

        //Green ramp
        ToonRampProperty(new GUIContent("Toon Ramp (G)", "The toon ramp texture to use on the green parts of the mask."), rampG);
        editor.RangeProperty(toonContrastG, "Toon Contrast (G)");
        editor.RangeProperty(toonRampOffsetG, "Toon Ramp Offset (G)");
        editor.RangeProperty(intensityG, "Intensity (G)");
        editor.RangeProperty(saturationG, "Saturation (G)");

        EditorGUILayout.Space();

        //Blue ramp
        ToonRampProperty(new GUIContent("Toon Ramp (B)", "The toon ramp texture to use on the blue parts of the mask."), rampB);
        editor.RangeProperty(toonContrastB, "Toon Contrast (B)");
        editor.RangeProperty(toonRampOffsetB, "Toon Ramp Offset (B)");
        editor.RangeProperty(intensityB, "Intensity (B)");
        editor.RangeProperty(saturationB, "Saturation (B)");
    }

    private void DrawOutlines()
    {
        outlinesExpanded = Section("Outlines", outlinesExpanded);
        if (!outlinesExpanded)
        {
            return;
        }

        editor.FloatProperty(outlineWidth, "Outline Width");
        editor.TexturePropertySingleLine(new GUIContent("Outline Texture", "The main texture (RGBA) and color tint used for the outlines. Alpha determines outline width."), outlineTex, outlineColor);
        editor.ShaderProperty(outlineAlphaWidthEnabled, new GUIContent("Alpha affects width", "Whether the outline texture's alpha should affect the outline width in that area."));
        editor.ShaderProperty(outlineScreenspaceEnabled, new GUIContent("Screenspace outlines", "Whether the outlines should be screenspace (always equally large, no matter the distance)"));

        if (outlineScreenspaceEnabled.floatValue == 1)
        {
            // Draw multi-slider for min/max distance
            float minDist = outlineScreenspaceMinDist.floatValue;
            float maxDist = outlineScreenspaceMaxDist.floatValue;
            EditorGUI.BeginChangeCheck();
            EditorGUILayout.MinMaxSlider("Size Limits (Min / Max)", ref minDist, ref maxDist, 0f, 10f);
            if (EditorGUI.EndChangeCheck())
            {
                outlineScreenspaceMinDist.floatValue = minDist;
                outlineScreenspaceMaxDist.floatValue = maxDist;
            }

            editor.FloatProperty(outlineScreenspaceMinDist, "Min Size");
            editor.FloatProperty(outlineScreenspaceMaxDist, "Max Size");
        }

        editor.ShaderProperty(outlineStencilComp, new GUIContent("Outline Mode", "Outer Only will only render the outlines on the outer edges of the model."));
        editor.ShaderProperty(outlineCutout, new GUIContent("Cutout Outlines", "Whether the outlines should be subject to cutout."));

        //Display a warning if the user attempts to use outlines to create double-sidedness.
        if (
            outlineWidth.floatValue == 0
            && outlineTex.textureValue != null && mainTex.textureValue != null
            && outlineTex.textureValue.GetInstanceID() == mainTex.textureValue.GetInstanceID())
        {
            EditorGUILayout.HelpBox("Outlines should not be used to make your model double-sided. Use the \"Sidedness\" property under Main instead.", MessageType.Warning);
        }
    }

    private void DrawMetallic()
    {
        metallicExpanded = Section("Metallic", metallicExpanded);
        if (!metallicExpanded)
        {
            return;
        }

        editor.ShaderProperty(metallicMode, new GUIContent("Metallic Mode", "Set the metallic mode for this material (None, Metallic workflow, Specular workflow)"));

        //Draw either the metallic or specular controls
        if (metallicMode.floatValue == 1)
        {
            DrawMetallicWorkflow();
        }
        else if (metallicMode.floatValue == 2)
        {
            DrawSpecularWorkflow();
        }
        else
        {
            //Draw greyed out metallic
            EditorGUI.BeginDisabledGroup(true);
            DrawMetallicWorkflow();
            EditorGUI.EndDisabledGroup();
        }
    }

    private void DrawMetallicWorkflow()
    {
        editor.TexturePropertySingleLine(new GUIContent("Metallic Map", "Defines Metallic (R) and Smoothness (A). Lower smoothness blurs reflections."), metallicMapTex);
        editor.RangeProperty(metallic, "Metallic");
        editor.RangeProperty(smoothness, "Smoothness");
    }

    private void DrawSpecularWorkflow()
    {
        editor.TexturePropertyWithHDRColor(new GUIContent("Specular Map", "Defines Specular color (RGB) and Smoothness (A). Lower smoothness blurs reflections."), specularTex, specularColor, true);
        editor.RangeProperty(smoothness, "Smoothness");
    }

    private void DrawMatcap()
    {
        matcapExpanded = Section("Matcap", matcapExpanded);
        if (!matcapExpanded)
        {
            return;
        }

        editor.ShaderProperty(matCapMode, new GUIContent("Matcap Mode"));

        EditorGUI.BeginDisabledGroup(matCapMode.floatValue == 0);
        editor.TexturePropertySingleLine(new GUIContent("Matcap Texture"), matCapTex);

        editor.ShaderProperty(matCapStrength, new GUIContent("Matcap Strength"));

        if (matCapMode.floatValue != 0 && matCapStrength.floatValue == 0)
        {
            EditorGUILayout.HelpBox("Matcap strength is zero, consider turning Matcap mode off for performance.", MessageType.Warning);
        }
        EditorGUI.EndDisabledGroup();
    }

    private void DrawRimlight()
    {
        rimlightExpanded = Section("Rimlight", rimlightExpanded);
        if (!rimlightExpanded)
        {
            return;
        }

        editor.ShaderProperty(rimLightMode, new GUIContent("Rimlight Mode"));
        EditorGUI.BeginDisabledGroup(rimLightMode.floatValue == 0);

        editor.TexturePropertySingleLine(new GUIContent("Rimlight Texture", "The rimlight texture. RGB controls color, Alpha controls strength."), rimTex, rimLightColor);
        editor.RangeProperty(rimWidth, "Rimlight Width");

        editor.ShaderProperty(rimInvert, new GUIContent("Invert Rimlight"));

        if (rimLightMode.floatValue != 0 && rimLightColor.colorValue.a == 0)
        {
            EditorGUILayout.HelpBox("Rimlight alpha is set to 0. Consider turning rimlights off for performance.", MessageType.Warning);
        }

        if (rimLightMode.floatValue == 1 && rimWidth.floatValue == 0)
        {
            EditorGUILayout.HelpBox("Rimlight is additive but width is set to 0. Consider turning rimlights off for performance.", MessageType.Warning);
        }

        EditorGUI.EndDisabledGroup();
    }

    private void DrawMisc()
    {
        miscExpanded = Section("Misc", miscExpanded);
        if (!miscExpanded)
        {
            return;
        }

        editor.RenderQueueField();
    }

    private void FindProperties(MaterialProperty[] props)
    {
        // Main
        mainTex = FindProperty("_MainTex", props);
        color = FindProperty("_Color", props);
        bumpMap = FindProperty("_BumpMap", props);
        bumpScale = FindProperty("_BumpScale", props);
        cutoff = FindProperty("_Cutoff", props);
        emissionMap = FindProperty("_EmissionMap", props);
        emissionColor = FindProperty("_EmissionColor", props);
        cullMode = FindProperty("_Cull", props);
        cutoutEnabled = FindProperty("_CutoutEnabled", props);

        // Toon lighting
        ramp = FindProperty("_Ramp", props);
        toonContrast = FindProperty("_ToonContrast", props);
        toonRampOffset = FindProperty("_ToonRampOffset", props);
        staticToonLight = FindProperty("_StaticToonLight", props);
        intensity = FindProperty("_Intensity", props);
        saturation = FindProperty("_Saturation", props);
        directLightBoost = FindProperty("_DirectLightBoost", props);
        indirectLightBoost = FindProperty("_IndirectLightBoost", props);

        // Metallic and specular
        metallicMode = FindProperty("_MetallicMode", props);
        metallicMapTex = FindProperty("_MetallicGlossMap", props);
        metallic = FindProperty("_Metallic", props);
        smoothness = FindProperty("_Glossiness", props);
        specularTex = FindProperty("_SpecGlossMap", props);
        specularColor = FindProperty("_SpecColor", props);

        // Ramp masking
        rampMaskingEnabled = FindProperty("_RampMaskEnabled", props);
        rampMaskTex = FindProperty("_RampMaskTex", props);
        rampR = FindProperty("_RampR", props);
        toonContrastR = FindProperty("_ToonContrastR", props);
        toonRampOffsetR = FindProperty("_ToonRampOffsetR", props);
        intensityR = FindProperty("_IntensityR", props);
        saturationR = FindProperty("_SaturationR", props);
        rampG = FindProperty("_RampG", props);
        toonContrastG = FindProperty("_ToonContrastG", props);
        toonRampOffsetG = FindProperty("_ToonRampOffsetG", props);
        intensityG = FindProperty("_IntensityG", props);
        saturationG = FindProperty("_SaturationG", props);
        rampB = FindProperty("_RampB", props);
        toonContrastB = FindProperty("_ToonContrastB", props);
        toonRampOffsetB = FindProperty("_ToonRampOffsetB", props);
        intensityB = FindProperty("_IntensityB", props);
        saturationB = FindProperty("_SaturationB", props);

        // Rimlight
        rimLightMode = FindProperty("_RimLightMode", props);
        rimLightColor = FindProperty("_RimLightColor", props);
        rimTex = FindProperty("_RimTex", props);
        rimWidth = FindProperty("_RimWidth", props);
        rimInvert = FindProperty("_RimInvert", props);

        // Matcap
        matCapTex = FindProperty("_MatCap", props);
        matCapMode = FindProperty("_MatCapMode", props);
        matCapStrength = FindProperty("_MatCapStrength", props);

        // Outlines
        outlineWidth = FindProperty("_OutlineWidth", props, false);
        outlineColor = FindProperty("_OutlineColor", props, false);
        outlineTex = FindProperty("_OutlineTex", props, false);
        outlineStencilComp = FindProperty("_OutlineStencilComp", props, false);
        outlineCutout = FindProperty("_OutlineCutout", props, false);
        outlineAlphaWidthEnabled = FindProperty("_OutlineAlphaWidthEnabled", props, false);
        outlineScreenspaceEnabled = FindProperty("_ScreenSpaceOutline", props, false);
        outlineScreenspaceMinDist = FindProperty("_ScreenSpaceMinDist", props, false);
        outlineScreenspaceMaxDist = FindProperty("_ScreenSpaceMaxDist", props, false);

        // Internal properties
        renderMode = FindProperty("_Mode", props);
        srcBlend = FindProperty("_SrcBlend", props);
        dstBlend = FindProperty("_DstBlend", props);
        zWrite = FindProperty("_ZWrite", props);
    }

    private bool HasOutlines()
    {
        return outlineWidth != null;
    }

    /// <summary>
    /// Draws a clickable header button.
    /// </summary>
    /// <returns>A boolean indicating whether the section is currently open or not.</returns>
    private bool Section(string title, bool expanded)
    {
        // Define style for section, reuse the one from particle systems
        var style = new GUIStyle("ShurikenModuleTitle")
        {
            font = new GUIStyle(EditorStyles.label).font,
            border = new RectOffset(15, 7, 4, 4),
            fixedHeight = 22,
            contentOffset = new Vector2(20f, -2f)
        };

        var rect = GUILayoutUtility.GetRect(16f, 22f, style);
        GUI.Box(rect, title, style);

        var e = Event.current;

        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
        if (e.type == EventType.Repaint)
        {
            EditorStyles.foldout.Draw(toggleRect, false, false, expanded, false);
        }

        // Check if the user has clicked on the header.
        // If clicked, expand or collapse the header.
        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
        {
            expanded = !expanded;
            e.Use();
        }

        return expanded;
    }

    private bool TextureIsNotSetToClamp(MaterialProperty prop)
    {
        return prop.textureValue != null && prop.textureValue.wrapMode != TextureWrapMode.Clamp;
    }

    /// <summary>
    /// Draws a texture property specifically meant for Toon Ramps. Can warn the user if the toon ramp texture is not set to Clamp.
    /// </summary>
    /// <param name="guiContent">A GUIContent object to use for the label.</param>
    /// <param name="rampProperty">The material property to make the texture for. Has to be a texture.</param>
    private void ToonRampProperty(GUIContent guiContent, MaterialProperty rampProperty)
    {
        editor.TexturePropertySingleLine(guiContent, rampProperty);

        //Display warning if repeat mode is not set to clamp.
        if (TextureIsNotSetToClamp(rampProperty))
        {
            EditorGUILayout.HelpBox("Toon Ramp texture wrap mode should be set to Clamp. You may experience lighting artifacts otherwise.", MessageType.Warning);
        }
    }

    /// <summary>
    /// Draws a full-size texture property, but without squishing the preview.
    /// </summary>
    /// <param name="prop">The texture property to draw.</param>
    /// <param name="label">The label to give the texture property.</param>
    private void TextureProperty(MaterialProperty prop, string label)
    {
        editor.SetDefaultGUIWidths();
        editor.TextureProperty(prop, label);
        EditorGUIUtility.labelWidth = defaultLabelWidth;
        EditorGUIUtility.fieldWidth = defaultFieldWidth;
    }

    private void SetupKeywords()
    {
        // Delete all keywords first
        material.shaderKeywords = new string[] { };

        // Add normal map keyword if used.
        if (material.GetTexture("_BumpMap"))
        {
            material.EnableKeyword("_NORMALMAP");
        }

        // Add cutout keyword if used
        if (cutoutEnabled.floatValue == 1)
        {
            material.EnableKeyword("_ALPHATEST_ON");
        }

        // Add ramp masking keyword
        if (rampMaskingEnabled.floatValue == 1)
        {
            material.EnableKeyword("_RAMPMASK_ON");
        }

        // Add Metallic or Specular keyword if used.
        if (metallicMode.floatValue == 1)
        {
            material.EnableKeyword("_METALLICGLOSSMAP");
        }
        else if (metallicMode.floatValue == 2)
        {
            material.EnableKeyword("_SPECGLOSSMAP");
        }

        // Emission keyword
        // Emission is automatically enabled when the emission tint is set to anything other than black. Alpha is ignored for the comparison.
        Color emissionCol = emissionColor.colorValue;
        if (new Color(emissionCol.r, emissionCol.g, emissionCol.b, 1) != Color.black)
        {
            material.EnableKeyword("_EMISSION");
        }

        // Matcap keywords
        if (matCapMode.floatValue == 1)
        {
            material.EnableKeyword("_MATCAP_ADD");
        }
        else if (matCapMode.floatValue == 2)
        {
            material.EnableKeyword("_MATCAP_MULTIPLY");
        }

        // Outline alpha width keyword
        if (HasOutlines() && outlineAlphaWidthEnabled.floatValue == 1)
        {
            material.EnableKeyword("_OUTLINE_ALPHA_WIDTH_ON");
        }

        // Screenspace outline keyword
        if (HasOutlines() && outlineScreenspaceEnabled.floatValue == 1)
        {
            material.EnableKeyword("_OUTLINE_SCREENSPACE");
        }

        // Rimlight keyword
        if (rimLightMode.floatValue == 1)
        {
            material.EnableKeyword("_RIMLIGHT_ADD");
        }
        else if (rimLightMode.floatValue == 2)
        {
            material.EnableKeyword("_RIMLIGHT_MIX");
        }
    }

    // Set up material blend modes and blending/alphatest keywords, render queues and override tags
    // By default, the current material is used.
    // A material can be manually specified in case this shader is newly assigned to the material, because the properties don't exist yet.
    private void SetupBlendModes()
    {
        this.SetupBlendModes(this.material);
    }

    private void SetupBlendModes(Material material)
    {
        // Check if the render type is transparent or not
        if (material.GetInt("_Mode") == 2)
        {
            // Set up transparent blend modes
            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);

            // Enable alpha blend keyword
            material.EnableKeyword("_ALPHABLEND_ON");

            // Set queue and rendertype
            material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
            material.SetOverrideTag("RenderType", "Transparent");
        }
        else
        {
            // Set up opaque blend modes (no blending)
            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);

            // Disable alpha blend keyword
            material.DisableKeyword("_ALPHABLEND_ON");

            // If Cutout is enabled, set the queue to AlphaTest and change the rendertype
            // Otherwise, set the queue and rendertype back to default.
            if (material.GetInt("_CutoutEnabled") == 1)
            {
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                material.SetOverrideTag("RenderType", "TransparentCutout");
            }
            else
            {
                material.renderQueue = -1;
                material.SetOverrideTag("RenderType", "");
            }
        }
    }
}
