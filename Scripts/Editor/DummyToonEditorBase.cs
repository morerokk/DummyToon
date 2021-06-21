using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public abstract class DummyToonEditorBase : ShaderGUI
    {
        protected MaterialEditor editor;

        protected Material material;

        protected Material[] materials;

        protected Dictionary<string, MaterialProperty> materialProperties = new Dictionary<string, MaterialProperty>();

        protected MaterialProperty shaderOptimized = null;

        private MaterialProperty[] props;

        private const string AnimatedSuffix = "Animated";

        protected static string CurrentVersion
        {
            get
            {
                return "1.4.0";
            }
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            editor = materialEditor;

            // Single material object. If multi-editing, this only refers to the first material. Use with caution.
            material = materialEditor.target as Material;

            // Cast all individual target objects to actual material objects
            // materialEditor.targets as Material[] does not work
            materials = new Material[materialEditor.targets.Length];
            for (int i = 0; i < materialEditor.targets.Length; i++)
            {
                materials[i] = materialEditor.targets[i] as Material;
            }

            try
            {
                FindProperties(properties);
            }
            catch(KeyNotFoundException e)
            {
                // This should never happen, but if it does, handle it a little more gracefully.
#if SHADEROPTIMIZER_INSTALLED
                // The primary reason this can happen is if you have an optimized shader from an older version.
                // If so, simply draw an Unlock button.
                if (material.GetFloat("_ShaderOptimized") == 1)
                {
                    EditorGUILayout.HelpBox("This material was optimized with an older version of Dummy Toon. Editing or viewing properties is not available.\n\nPress the \"unlock\" button to view and edit the material again.", MessageType.Warning);
                    if (GUILayout.Button("Unlock"))
                    {
                        UnlockMaterial();
                    }

                    // Prevent the child class from still attempting to draw the material.
                    throw;
                }
#else
                // Something else went wrong, probably on our end.
                EditorGUILayout.HelpBox("An error occurred while trying to read the material shader properties. Check the console for more information.", MessageType.Error);
                throw;
#endif
            }

            props = properties;
        }

        /// <summary>
        /// Indexes materialproperties in a dictionary by their name for faster lookups.
        /// If overridden, the base method should be called or a custom lookup should be implemented.
        /// </summary>
        /// <param name="props">An array of material properties to find.</param>
        protected virtual void FindProperties(MaterialProperty[] props)
        {
            ClearFoundProperties();

            foreach (MaterialProperty prop in props)
            {
                materialProperties[prop.name] = prop;
            }

            shaderOptimized = FindProperty("_ShaderOptimized", false);
        }

        /// <summary>
        /// More optimized version of FindProperty. Finds a material property by name.
        /// </summary>
        /// <param name="name">The name of the material property to find.</param>
        /// <param name="mandatory">If true, an exception is raised if the property could not be found. If false, returns null. True by default.</param>
        /// <returns>The requested MaterialProperty if it exists.</returns>
        protected virtual MaterialProperty FindProperty(string name, bool mandatory)
        {
            MaterialProperty prop;
            if (materialProperties.TryGetValue(name, out prop))
            {
                return prop;
            }
            else if (mandatory)
            {
                throw new KeyNotFoundException(string.Format("Could not find mandatory property '{0}'", name));
            }

            return null;
        }

        /// <summary>
        /// More optimized version of FindProperty. Finds a material property by name.
        /// </summary>
        /// <param name="name">The name of the material property to find.</param>
        /// <returns>The requested MaterialProperty if it exists.</returns>
        protected virtual MaterialProperty FindProperty(string name)
        {
            return FindProperty(name, true);
        }

        /// <summary>
        /// Clear all earlier found properties, to prevent caching properties that no longer exist.
        /// </summary>
        protected virtual void ClearFoundProperties()
        {
            materialProperties.Clear();
        }

        /// <summary>
        /// Draws a clickable header button.
        /// </summary>
        /// <returns>A boolean indicating whether the section is currently open or not.</returns>
        protected virtual bool Section(string title, bool expanded)
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

        protected bool TextureIsNotSetToClamp(MaterialProperty prop)
        {
            return prop.textureValue != null && prop.textureValue.wrapMode != TextureWrapMode.Clamp;
        }

        protected bool TextureIsPointFiltered(MaterialProperty prop)
        {
            return prop.textureValue != null && prop.textureValue.filterMode == FilterMode.Point;
        }

        /// <summary>
        /// Draws a texture property specifically meant for Toon Ramps. Can warn the user if the toon ramp texture is not set to Clamp.
        /// </summary>
        /// <param name="guiContent">A GUIContent object to use for the label.</param>
        /// <param name="rampProperty">The material property to draw the texture for. Has to be a texture property.</param>
        protected virtual void ToonRampProperty(GUIContent guiContent, MaterialProperty rampProperty)
        {
            if (rampProperty.type != MaterialProperty.PropType.Texture)
            {
                throw new ArgumentOutOfRangeException("rampProperty", rampProperty, "rampProperty parameter must be a texture!");
            }

            editor.TexturePropertySingleLine(guiContent, rampProperty);

            // Display warning if wrap mode is not set to clamp.
            if (TextureIsNotSetToClamp(rampProperty))
            {
                EditorGUILayout.HelpBox("Toon Ramp texture wrap mode should be set to Clamp. You may experience lighting artifacts otherwise.", MessageType.Warning);
            }
        }

        /// <summary>
        /// Draws a texture property specifically meant for Toon Ramps. Can warn the user if the toon ramp texture is not set to Clamp.
        /// This version draws a larger and wider property.
        /// </summary>
        /// <param name="label">Text to use in the label.</param>
        /// <param name="rampProperty">The material property to draw the texture for. Has to be a texture property.</param>
        protected virtual void ToonRampPropertyFullWidth(string label, MaterialProperty rampProperty)
        {
            if (rampProperty.type != MaterialProperty.PropType.Texture)
            {
                throw new ArgumentOutOfRangeException("rampProperty", rampProperty, "rampProperty parameter must be a texture!");
            }

            TextureProperty(rampProperty, label, false);

            // Display warning if wrap mode is not set to clamp.
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
        /// <param name="scaleOffset">Whether to give this property a tiling and offset field.</param>
        protected virtual void TextureProperty(MaterialProperty prop, string label, bool scaleOffset)
        {
            if (prop.type != MaterialProperty.PropType.Texture)
            {
                throw new ArgumentOutOfRangeException("prop", prop, "prop parameter must be a texture!");
            }

            // Save existing label and field widths
            float defaultLabelWidth = EditorGUIUtility.labelWidth;
            float defaultFieldWidth = EditorGUIUtility.fieldWidth;

            // Reset field widths, draw property
            editor.SetDefaultGUIWidths();
            editor.TextureProperty(prop, label, scaleOffset);

            // Restore label and field widths
            EditorGUIUtility.labelWidth = defaultLabelWidth;
            EditorGUIUtility.fieldWidth = defaultFieldWidth;
        }

        /// <summary>
        /// Draws a full-size texture property, but without squishing the preview.
        /// </summary>
        /// <param name="prop">The texture property to draw.</param>
        /// <param name="label">The label to give the texture property.</param>
        protected virtual void TextureProperty(MaterialProperty prop, string label)
        {
            TextureProperty(prop, label, true);
        }

        /// <summary>
        /// Draw a color property with an appropriate small field size
        /// </summary>
        /// <param name="prop">The color property to draw.</param>
        /// <param name="label">The text label to give to this property.</param>
        protected virtual void ColorProperty(MaterialProperty prop, string label)
        {
            // Save existing label and field widths
            float defaultLabelWidth = EditorGUIUtility.labelWidth;
            float defaultFieldWidth = EditorGUIUtility.fieldWidth;

            // Reset field widths, draw property
            editor.SetDefaultGUIWidths();
            editor.ColorProperty(prop, label);

            // Restore label and field widths
            EditorGUIUtility.labelWidth = defaultLabelWidth;
            EditorGUIUtility.fieldWidth = defaultFieldWidth;
        }

        /// <summary>
        /// Draws a shader property with a help button and an expandable help box.
        /// </summary>
        /// <param name="prop">The shader property to draw with a help box.</param>
        /// <param name="label">A GUIContent object containing the label of the property.</param>
        /// <param name="expanded">A ref bool that tracks whether the help box is currently expanded.</param>
        /// <param name="helpText">The text to put in the help box.</param>
        protected virtual void ShaderPropertyWithHelp(MaterialProperty prop, GUIContent label, ref bool expanded, string helpText)
        {
            EditorGUILayout.BeginHorizontal();
            editor.ShaderProperty(prop, label);
            if (GUILayout.Button("?", GUILayout.Width(25)))
            {
                expanded = !expanded;
            }
            EditorGUILayout.EndHorizontal();

            if (expanded)
            {
                EditorGUILayout.HelpBox(helpText, MessageType.Info);
            }
        }

        /// <summary>
        /// Draws a single-line texture property with a help button and an expandable help box.
        /// </summary>
        /// <param name="label">A GUIContent object containing the label of the texture.</param>
        /// <param name="prop">The texture property to draw with a help box.</param>
        /// <param name="expanded">A ref bool that tracks whether the help box is currently expanded.</param>
        /// <param name="helpText">The text to put in the help box.</param>
        protected virtual void TexturePropertyWithHelp(GUIContent label, MaterialProperty prop, ref bool expanded, string helpText)
        {
            if (prop.type != MaterialProperty.PropType.Texture)
            {
                throw new ArgumentOutOfRangeException("prop", prop, "prop parameter must be a texture!");
            }

            EditorGUILayout.BeginHorizontal();
            editor.TexturePropertySingleLine(label, prop);
            if (GUILayout.Button("?", GUILayout.Width(25)))
            {
                expanded = !expanded;
            }
            EditorGUILayout.EndHorizontal();

            if (expanded)
            {
                EditorGUILayout.HelpBox(helpText, MessageType.Info);
            }
        }

        protected virtual void LabelWithHelp(GUIContent label, ref bool expanded, string helpText)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(label);
            if (GUILayout.Button("?", GUILayout.Width(25)))
            {
                expanded = !expanded;
            }
            EditorGUILayout.EndHorizontal();

            if (expanded)
            {
                EditorGUILayout.HelpBox(helpText, MessageType.Info);
            }
        }

        protected virtual void Divider()
        {
            Divider(Color.gray);
        }

        protected virtual void Divider(Color color)
        {
            Divider(color, 2, 10);
        }

        protected virtual void Divider(Color color, int thickness, int padding)
        {
            Rect r = EditorGUILayout.GetControlRect(GUILayout.Height(padding + thickness));
            r.height = thickness;
            r.y += padding / 2;
            r.x -= 2;
            r.width += 6;
            EditorGUI.DrawRect(r, color);
        }


        /// <summary>
        /// Get a list of all currently selected materials.
        /// </summary>
        /// <returns>A list of selected materials</returns>
        protected List<Material> GetAllSelectedMaterials()
        {
            return materials.ToList();
        }

        protected virtual bool IsMaterialLocked()
        {
#if SHADEROPTIMIZER_INSTALLED
            return shaderOptimized != null && shaderOptimized.floatValue == 1;
#else
            return false;
#endif
        }

        protected virtual bool IsMaterialLocked(Material material)
        {
#if SHADEROPTIMIZER_INSTALLED
            return material.GetInt("_ShaderOptimized") == 1;
#else
            return false;
#endif
        }

        protected virtual bool CanMaterialBeLocked()
        {
#if SHADEROPTIMIZER_INSTALLED
            return shaderOptimized != null;
#else
            return false;
#endif
        }

#if SHADEROPTIMIZER_INSTALLED
        private static MaterialProperty GetFakeAnimatedProperty(string propName)
        {
            // Horrible reflection hack, currently the only way to instantiate a new MaterialProperty and set its name, which is what the optimizer checks for.
            var materialProperty = new MaterialProperty();
            var nameField = materialProperty.GetType().GetField("m_Name", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            nameField.SetValue(materialProperty, propName + AnimatedSuffix);
            var typeField = materialProperty.GetType().GetField("m_Type", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            typeField.SetValue(materialProperty, MaterialProperty.PropType.Float);
            var valueField = materialProperty.GetType().GetField("m_Value", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
            valueField.SetValue(materialProperty, 1.0f);

            return materialProperty;
        }

        /// <summary>
        /// Locks the material, optimizing it.
        /// </summary>
        protected virtual void LockMaterial()
        {
            shaderOptimized.floatValue = 1;
            Kaj.ShaderOptimizer.Lock(material, materialProperties.Values.ToArray());
        }

        /// <summary>
        /// Locks the material, optimizing it.
        /// </summary>
        /// <param name="animatedProperties">A list of property names to keep and not optimize away.</param>
        protected virtual void LockMaterial(List<string> animatedProperties)
        {
            var matProps = materialProperties.Values.ToList();
            foreach (string prop in animatedProperties)
            {
                var materialProperty = GetFakeAnimatedProperty(prop);
                matProps.Add(materialProperty);
            }

            shaderOptimized.floatValue = 1;
            Kaj.ShaderOptimizer.Lock(material, matProps.ToArray());
        }

        /// <summary>
        /// Locks all currently selected materials.
        /// </summary>
        protected virtual void LockAllSelectedMaterials()
        {
            foreach(Material mat in this.materials)
            {
                if(!mat.HasProperty("_ShaderOptimized"))
                {
                    continue;
                }

                mat.SetFloat("_ShaderOptimized", 1);
                var matProps = MaterialEditor.GetMaterialProperties(new UnityEngine.Object[] { mat });
                Kaj.ShaderOptimizer.Lock(mat, matProps);
            }
        }

        /// <summary>
        /// Locks all currently selected materials.
        /// </summary>
        /// <param name="animatedProperties">A list of property names to keep and not optimize away.</param>
        protected virtual void LockAllSelectedMaterials(List<string> animatedProperties)
        {
            foreach (Material mat in this.materials)
            {
                if (!mat.HasProperty("_ShaderOptimized"))
                {
                    continue;
                }

                var matProps = MaterialEditor.GetMaterialProperties(new UnityEngine.Object[] { mat }).ToList();
                foreach (string prop in animatedProperties)
                {
                    var materialProperty = GetFakeAnimatedProperty(prop);
                    matProps.Add(materialProperty);
                }

                mat.SetFloat("_ShaderOptimized", 1);
                Kaj.ShaderOptimizer.Lock(mat, matProps.ToArray());
            }
        }

        /// <summary>
        /// Unlocks the material and sets the shader back to its original.
        /// </summary>
        protected virtual void UnlockMaterial()
        {
            material.SetFloat("_ShaderOptimized", 0);
            Kaj.ShaderOptimizer.Unlock(material);
        }

        /// <summary>
        /// Unlocks all selected materials, setting their shader back to its original.
        /// </summary>
        protected virtual void UnlockAllSelectedMaterials()
        {
            foreach (Material mat in this.materials)
            {
                if (!mat.HasProperty("_ShaderOptimized"))
                {
                    continue;
                }
                mat.SetFloat("_ShaderOptimized", 0);
                Kaj.ShaderOptimizer.Unlock(mat);
            }
        }
#endif
        protected void DrawVersion()
        {
            EditorGUILayout.LabelField("Dummy Toon Shader v" + CurrentVersion, EditorStyles.boldLabel);
        }
    }
}
