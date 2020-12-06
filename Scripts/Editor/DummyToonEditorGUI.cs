using System;
using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public class DummyToonEditorGUI : DummyToonEditorBase
    {
        // Main
        private MaterialProperty mainTex = null;
        private MaterialProperty color = null;
        private MaterialProperty bumpMap = null;
        private MaterialProperty bumpScale = null;
        private MaterialProperty cutoff = null;
        private MaterialProperty emissionMap = null;
        private MaterialProperty emissionColor = null;
        private MaterialProperty emissionIsTint = null;
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
        private MaterialProperty rampTintingEnabled = null;
        private MaterialProperty indirectLightDirMergeMin = null;
        private MaterialProperty indirectLightDirMergeMax = null;
        private MaterialProperty rampAntiAliasingEnabled = null;
        private MaterialProperty overrideWorldLightDirection = null;
        private MaterialProperty additiveRampMode = null;
        private MaterialProperty additiveRamp = null;

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
        private MaterialProperty matCapTintTex = null;
        private MaterialProperty matCapColor = null;
        private MaterialProperty matCapOrigin = null;

        // Outlines
        private MaterialProperty outlineWidth = null;
        private MaterialProperty outlineColor = null;
        private MaterialProperty outlineTex = null;
        private MaterialProperty outlineScreenspaceEnabled = null;
        private MaterialProperty outlineScreenspaceMinDist = null;
        private MaterialProperty outlineScreenspaceMaxDist = null;
        private MaterialProperty outlineStencilComp = null;
        private MaterialProperty outlineAlphaWidthEnabled = null;

        // Alpha To Coverage
        private MaterialProperty alphaToCoverageEnabled = null;

        // Detail normal
        private MaterialProperty detailNormalTex = null;
        private MaterialProperty detailNormalScale = null;
        private MaterialProperty detailNormalUvMap = null;

        //Eye tracking
        private MaterialProperty targetEye = null;
        private MaterialProperty maxLookRange = null;
        private MaterialProperty maxLookDistance = null;
        private MaterialProperty eyeTrackPatternTexture = null;
        private MaterialProperty eyeTrackSpeed = null;
        private MaterialProperty eyeTrackBlur = null;
        private MaterialProperty eyeTrackBlenderCorrection = null;

        // Internal properties
        private MaterialProperty srcBlend = null;
        private MaterialProperty dstBlend = null;
        private MaterialProperty outlineStencilWriteAction;

        // Keeps track of which sections are opened and closed.
        private bool mainExpanded = true;
        private bool toonExpanded = true;
        private bool outlinesExpanded = false;
        private bool metallicExpanded = false;
        private bool matcapExpanded = false;
        private bool rimlightExpanded = false;
        private bool eyeTrackingExpanded = false;
        private bool miscExpanded = false;

        private bool emissionTintHelpExpanded = false;
        private bool rampTintHelpExpanded = false;
        private bool rampMaskHelpExpanded = false;
        private bool indirectLightMergeHelpExpanded = false;
        private bool rampAntiAliasingHelpExpanded = false;
        private bool additiveRampHelpExpanded = false;
        private bool matCapOriginHelpExpanded = false;

        private bool eyeTrackingTextureHelpExpanded = false;
        private bool eyeTrackingRotationCorrectionHelpExpanded = false;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            base.OnGUI(materialEditor, properties);

            DrawMain();
            if (HasOutlines())
            {
                DrawOutlines();
            }
            DrawToonLighting();
            DrawMetallic();
            DrawMatcap();
            DrawRimlight();

            if (HasEyeTracking())
            {
                DrawEyeTracking();
            }

            DrawMisc();

            SetupKeywords();

            if (HasOutlines())
            {
                SetupOutlineStencilValues();
            }
        }

        // Called when user switches to this shader
        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            SetupBlendModes(material);

            // Fix invalid properties carried over from Noenoe
            if (oldShader.name.ToUpperInvariant().Contains("NOENOE"))
            {
                material.SetFloat("_Intensity", 1.3f);
                material.SetFloat("_Saturation", 1f);
                material.SetFloat("_ToonContrast", 0.5f);
            }
        }

        private void DrawMain()
        {
            mainExpanded = Section("Main", mainExpanded);
            if (!mainExpanded)
            {
                return;
            }

            editor.TexturePropertySingleLine(new GUIContent("Main Texture", "The main albedo texture to use."), mainTex, color);

            editor.TexturePropertySingleLine(new GUIContent("Normal Map"), bumpMap, bumpScale);

            editor.TexturePropertySingleLine(new GUIContent("Emission Map"), emissionMap, emissionColor);

            ShaderPropertyWithHelp(
                emissionIsTint,
                new GUIContent("Tinted Emission", "If enabled, the emission is maintex * emission rather than just emission."),
                ref emissionTintHelpExpanded,
                "If enabled, the emission color is determined by main texture * emission. Useful for emission maps that are just solid colors.\r\n\r\n" +
                "If disabled, the emission map is used as-is."
            );

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

            editor.TextureScaleOffsetProperty(mainTex);
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

            EditorGUILayout.Space();

            // Light direction merge properties and help box
            LabelWithHelp(
                new GUIContent("Indirect Light Direction Merge"),
                ref indirectLightMergeHelpExpanded,
                "If the dominant light direction of the ambient lighting is too close to the direction of the most important realtime directional light, their light directions will be merged together. " +
                "This helps prevent the creation of two different light directions on the same Mixed directional light."
            );

            editor.RangeProperty(indirectLightDirMergeMin, "Minimum Merge Threshold");
            editor.RangeProperty(indirectLightDirMergeMax, "Maximum Merge Threshold");

            EditorGUILayout.Space();

            // Draw the ramp AA toggle and a help box button horizontally
            ShaderPropertyWithHelp(
                rampAntiAliasingEnabled,
                new GUIContent("Ramp Anti-Aliasing", "Enable ramp anti-aliasing, which can eliminate jagged edges on sharper toon ramps."),
                ref rampAntiAliasingHelpExpanded,
                "Enables anti-aliasing on toon ramp textures, which can help eliminate jagged edges on sharper toon ramps. The filter mode of the ramp texture must not be set to Point."
            );

            // Draw the ramp tinting toggle and a help box button horizontally
            ShaderPropertyWithHelp(
                rampTintingEnabled,
                new GUIContent("Ramp Tinting", "Enable the Ramp Tinting feature, which tints shadows to the surface color."),
                ref rampTintHelpExpanded,
                "Toon ramp tinting is an experimental feature that tints the darker side of the toon ramp towards the surface color. This can help make colors look less washed out on the dark side of the ramp. Works best with greyscale ramps, not recommended with colored ramps."
            );

            editor.VectorProperty(staticToonLight, "Fallback light direction");
            editor.ShaderProperty(overrideWorldLightDirection, new GUIContent("Always use fallback", "Whether the fallback light direction should *always* be used."));

            // Draw the ramp masking toggle and a help box button horizontally
            ShaderPropertyWithHelp(
                rampMaskingEnabled,
                new GUIContent("Ramp Masking", "Enable the Ramp Masking feature, allowing you to use RGB masks to define up to 4 toon ramps on the same material."),
                ref rampMaskHelpExpanded,
                "Toon Ramp Masking is an experimental feature to allow up to 4 different toon ramps and toon values to be used on the same material. The color of the mask texture defines whether the Red, Green, Blue or Default values are used in that particular area."
            );

            if (rampMaskingEnabled.floatValue == 1)
            {
                DrawRampMasking();
            }

            // Draw the additive ramping toggle and a help box button horizontally
            ShaderPropertyWithHelp(
                additiveRampMode,
                new GUIContent("Additive Ramp Mode", "Which additive ramp mode to use."),
                ref additiveRampHelpExpanded,
                "- None: Use the regular toon ramps.\r\n" +
                "- Additive Only: Use the additive toon ramp for all realtime lights, except the most important realtime directional light.\r\n" +
                "- Always: Always use the additive toon ramp for all realtime lights.\r\n\r\n" +
                "The \"Additive Only\" mode better preserves toon ramp colors under mixed lights, but \"Always\" mode is more consistent."
            );

            if (additiveRampMode.floatValue != 0)
            {
                editor.TexturePropertySingleLine(new GUIContent("Additive Ramp", "The toon ramp texture to use for realtime lights."), additiveRamp);
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

            editor.TexturePropertySingleLine(new GUIContent("Matcap Tint", "Tint the matcap to the specified color (RGB). Alpha controls strength."), matCapTintTex, matCapColor);

            ShaderPropertyWithHelp(matCapOrigin,
                new GUIContent("Matcap origin"),
                ref matCapOriginHelpExpanded,
                "Determines the origin point for the matcap. Changing this to \"Object\" might help with artifacts when viewing from directly above/below, but will shift the matcap if the object origin moves. " +
                "Surface is generally better for character models, while Object is often better for objects and static props.\r\n\r\n" +
                "Default: Surface");

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

        private void DrawMisc()
        {
            miscExpanded = Section("Misc", miscExpanded);
            if (!miscExpanded)
            {
                return;
            }

            editor.TexturePropertySingleLine(new GUIContent("Detail Normal Map", "An additional detail normal map."), detailNormalTex, detailNormalScale);
            editor.TextureScaleOffsetProperty(detailNormalTex);
            editor.ShaderProperty(detailNormalUvMap, new GUIContent("UV Map", "Which UV Map to use for the detail normals."));

            EditorGUILayout.Space();

            editor.ShaderProperty(alphaToCoverageEnabled, new GUIContent("Alpha To Coverage", "Whether to enable the Alpha To Coverage feature, also known as anti-aliased cutout."));

            if (alphaToCoverageEnabled.floatValue == 1)
            {
                editor.RangeProperty(cutoff, "Alpha Cutoff");
                EditorGUILayout.HelpBox("When using Alpha To Coverage, ensure that the main texture has \"Mip Maps Preserve Coverage\" enabled in the import settings.", MessageType.Info);
            }

            editor.RenderQueueField();
        }

        protected override void FindProperties(MaterialProperty[] props)
        {
            base.FindProperties(props);

            // Main
            mainTex = FindProperty("_MainTex");
            color = FindProperty("_Color");
            bumpMap = FindProperty("_BumpMap");
            bumpScale = FindProperty("_BumpScale");
            cutoff = FindProperty("_Cutoff");
            emissionMap = FindProperty("_EmissionMap");
            emissionColor = FindProperty("_EmissionColor");
            emissionIsTint = FindProperty("_EmissionMapIsTint");
            cullMode = FindProperty("_Cull");
            cutoutEnabled = FindProperty("_CutoutEnabled");

            // Toon lighting
            ramp = FindProperty("_Ramp");
            toonContrast = FindProperty("_ToonContrast");
            toonRampOffset = FindProperty("_ToonRampOffset");
            staticToonLight = FindProperty("_StaticToonLight");
            intensity = FindProperty("_Intensity");
            saturation = FindProperty("_Saturation");
            directLightBoost = FindProperty("_DirectLightBoost");
            indirectLightBoost = FindProperty("_IndirectLightBoost");
            rampTintingEnabled = FindProperty("_RampTinting");
            indirectLightDirMergeMin = FindProperty("_IndirectLightDirMergeMin");
            indirectLightDirMergeMax = FindProperty("_IndirectLightDirMergeMax");
            rampAntiAliasingEnabled = FindProperty("_RampAntiAliasingEnabled");
            overrideWorldLightDirection = FindProperty("_OverrideWorldLightDir");
            additiveRampMode = FindProperty("_AdditiveRampMode");
            additiveRamp = FindProperty("_AdditiveRamp");

            // Metallic and specular
            metallicMode = FindProperty("_MetallicMode");
            metallicMapTex = FindProperty("_MetallicGlossMap");
            metallic = FindProperty("_Metallic");
            smoothness = FindProperty("_Glossiness");
            specularTex = FindProperty("_SpecGlossMap");
            specularColor = FindProperty("_SpecColor");

            // Ramp masking
            rampMaskingEnabled = FindProperty("_RampMaskEnabled");
            rampMaskTex = FindProperty("_RampMaskTex");
            rampR = FindProperty("_RampR");
            toonContrastR = FindProperty("_ToonContrastR");
            toonRampOffsetR = FindProperty("_ToonRampOffsetR");
            intensityR = FindProperty("_IntensityR");
            saturationR = FindProperty("_SaturationR");
            rampG = FindProperty("_RampG");
            toonContrastG = FindProperty("_ToonContrastG");
            toonRampOffsetG = FindProperty("_ToonRampOffsetG");
            intensityG = FindProperty("_IntensityG");
            saturationG = FindProperty("_SaturationG");
            rampB = FindProperty("_RampB");
            toonContrastB = FindProperty("_ToonContrastB");
            toonRampOffsetB = FindProperty("_ToonRampOffsetB");
            intensityB = FindProperty("_IntensityB");
            saturationB = FindProperty("_SaturationB");

            // Rimlight
            rimLightMode = FindProperty("_RimLightMode");
            rimLightColor = FindProperty("_RimLightColor");
            rimTex = FindProperty("_RimTex");
            rimWidth = FindProperty("_RimWidth");
            rimInvert = FindProperty("_RimInvert");

            // Matcap
            matCapTex = FindProperty("_MatCap");
            matCapMode = FindProperty("_MatCapMode");
            matCapStrength = FindProperty("_MatCapStrength");
            matCapTintTex = FindProperty("_MatCapTintTex");
            matCapColor = FindProperty("_MatCapColor");
            matCapOrigin = FindProperty("_MatCapOrigin");

            // Outlines
            outlineWidth = FindProperty("_OutlineWidth", false);
            outlineColor = FindProperty("_OutlineColor", false);
            outlineTex = FindProperty("_OutlineTex", false);
            outlineStencilComp = FindProperty("_OutlineStencilComp", false);
            outlineAlphaWidthEnabled = FindProperty("_OutlineAlphaWidthEnabled", false);
            outlineScreenspaceEnabled = FindProperty("_ScreenSpaceOutline", false);
            outlineScreenspaceMinDist = FindProperty("_ScreenSpaceMinDist", false);
            outlineScreenspaceMaxDist = FindProperty("_ScreenSpaceMaxDist", false);

            // A2C
            alphaToCoverageEnabled = FindProperty("_AlphaToCoverage");

            // Detail normal
            detailNormalTex = FindProperty("_DetailNormalMap");
            detailNormalScale = FindProperty("_DetailNormalMapScale");
            detailNormalUvMap = FindProperty("_UVSec");

            //Eye tracking stuff
            targetEye = FindProperty("_TargetEye", false);
            maxLookRange = FindProperty("_MaxLookRange", false);
            maxLookDistance = FindProperty("_MaxLookDistance", false);
            eyeTrackPatternTexture = FindProperty("_EyeTrackingPatternTex", false);
            eyeTrackSpeed = FindProperty("_EyeTrackingScrollSpeed", false);
            eyeTrackBlur = FindProperty("_EyeTrackingBlur", false);
            eyeTrackBlenderCorrection = FindProperty("_EyeTrackingRotationCorrection", false);

            // Internal properties
            renderMode = FindProperty("_Mode");
            srcBlend = FindProperty("_SrcBlend");
            dstBlend = FindProperty("_DstBlend");
            zWrite = FindProperty("_ZWrite");
            outlineStencilWriteAction = FindProperty("_StencilWriteAction", false);
        }

        private bool HasOutlines()
        {
            return outlineWidth != null;
        }

        private bool HasEyeTracking()
        {
            return targetEye != null;
        }

        private void SetupKeywords()
        {
            // Delete all keywords first
            material.shaderKeywords = new string[] { };

            // Transparency keyword
            if (renderMode.floatValue == 2)
            {
                material.EnableKeyword("_ALPHABLEND_ON");
            }

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

            // Add ramp tinting keyword
            if (rampTintingEnabled.floatValue == 1)
            {
                material.EnableKeyword("_COLORCOLOR_ON");
            }

            // Add ramp masking keyword
            if (rampMaskingEnabled.floatValue == 1)
            {
                material.EnableKeyword("_COLORADDSUBDIFF_ON");
            }

            // Ramp anti-aliasing keyword
            if (rampAntiAliasingEnabled.floatValue == 1)
            {
                material.EnableKeyword("_COLOROVERLAY_ON");
            }

            // Override world light dir keyword
            if (overrideWorldLightDirection.floatValue == 1)
            {
                material.EnableKeyword("_FADING_ON");
            }

            // Additive Ramping keyword
            if (additiveRampMode.floatValue == 1)
            {
                material.EnableKeyword("_GLOSSYREFLECTIONS_OFF");
            }
            else if (additiveRampMode.floatValue == 2)
            {
                material.EnableKeyword("_SPECULARHIGHLIGHTS_OFF");
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
                material.EnableKeyword("_SUNDISK_SIMPLE");
            }
            else if (matCapMode.floatValue == 2)
            {
                material.EnableKeyword("_SUNDISK_HIGH_QUALITY");
            }

            // Matcap tint texture keyword
            if (matCapTintTex.textureValue != null && matCapMode.floatValue != 0)
            {
                material.EnableKeyword("_SUNDISK_NONE");
            }

            // Outline alpha width keyword
            if (HasOutlines() && outlineAlphaWidthEnabled.floatValue == 1)
            {
                material.EnableKeyword("_PARALLAXMAP");
            }

            // Screenspace outline keyword
            if (HasOutlines() && outlineScreenspaceEnabled.floatValue == 1)
            {
                material.EnableKeyword("_MAPPING_6_FRAMES_LAYOUT");
            }

            // Rimlight keyword
            if (rimLightMode.floatValue == 1)
            {
                material.EnableKeyword("_TERRAIN_NORMAL_MAP");
            }
            else if (rimLightMode.floatValue == 2)
            {
                material.EnableKeyword("_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A");
            }

            // A2C keyword
            if (alphaToCoverageEnabled.floatValue == 1)
            {
                material.EnableKeyword("_ALPHAMODULATE_ON");
            }

            // Detail normals keywords
            if (detailNormalTex.textureValue != null)
            {
                if (detailNormalUvMap.floatValue == 0)
                {
                    material.EnableKeyword("_REQUIRE_UV2");
                }
                else
                {
                    material.EnableKeyword("_DETAIL_MULX2");
                }
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

        private void SetupOutlineStencilValues()
        {
            // Check if outer only outline mode is enabled
            if (outlineStencilComp.floatValue == (int)UnityEngine.Rendering.CompareFunction.NotEqual)
            {
                // If so, tell ForwardBase pass to also write to the stencil buffer
                this.outlineStencilWriteAction.floatValue = (int)UnityEngine.Rendering.StencilOp.Replace;
            }
            else
            {
                // Otherwise, tell the ForwardBase pass to *not* write stencils.
                this.outlineStencilWriteAction.floatValue = (int)UnityEngine.Rendering.StencilOp.Keep;
            }
        }

        protected override void ToonRampProperty(GUIContent guiContent, MaterialProperty rampProperty)
        {
            base.ToonRampProperty(guiContent, rampProperty);

            // Display warning if ramp anti-aliasing is enabled but the toon ramp filter mode is Point.
            if (rampAntiAliasingEnabled.floatValue == 1 && TextureIsPointFiltered(rampProperty))
            {
                EditorGUILayout.HelpBox("Ramp anti-aliasing is enabled, but the filtering mode of this ramp texture is set to Point.", MessageType.Warning);
            }
        }
    }
}
