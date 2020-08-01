using System;
using UnityEditor;
using UnityEngine;

public abstract class DummyToonEditorBase : ShaderGUI
{
    protected MaterialEditor editor;

    protected Material material;

    /// <summary>
    /// Draws a clickable header button.
    /// </summary>
    /// <returns>A boolean indicating whether the section is currently open or not.</returns>
    protected bool Section(string title, bool expanded)
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
}
