using System;
using UnityEditor;
using UnityEngine;

namespace Rokk.DummyToon.Editor
{
    public class DummyToonPenetrationEditorGUI : DummyToonEditorGUI
    {
        // Penetration
        private MaterialProperty squeeze = null;
        private MaterialProperty squeezeDist = null;
        private MaterialProperty bulgePower = null;
        private MaterialProperty bulgeOffset = null;
        private MaterialProperty length = null;
        private MaterialProperty entranceStiffness = null;
        private MaterialProperty curvature = null;
        private MaterialProperty reCurvature = null;
        private MaterialProperty wriggle = null;
        private MaterialProperty wriggleSpeed = null;

        // Keeps track of which sections are opened and closed.
        private bool penetrationExpanded = false;

        protected override void DrawShaderProperties()
        {
            base.DrawShaderProperties();
            DrawPenetration();
        }

        private void DrawPenetration()
        {
            penetrationExpanded = Section("Penetration", penetrationExpanded);
            if (!penetrationExpanded)
            {
                return;
            }

            EditorGUILayout.LabelField("Penetration Entry Deformation", EditorStyles.boldLabel);
            editor.RangeProperty(squeeze, "Squeeze Minimum Size");
            editor.RangeProperty(squeezeDist, "Squeeze Smoothness");
            editor.RangeProperty(bulgePower, "Bulge Amount");
            editor.RangeProperty(bulgeOffset, "Bulge Length");
            editor.RangeProperty(length, "Length Of Penetrator Model");

            EditorGUILayout.LabelField("Alignment Adjustment", EditorStyles.boldLabel);
            editor.RangeProperty(entranceStiffness, "Entrance Stiffness");

            EditorGUILayout.LabelField("Resting Curvature", EditorStyles.boldLabel);
            editor.RangeProperty(curvature, "Curvature");
            editor.RangeProperty(reCurvature, "ReCurvature");

            EditorGUILayout.LabelField("Movement", EditorStyles.boldLabel);
            editor.RangeProperty(wriggle, "Wriggle Amount");
            editor.RangeProperty(wriggleSpeed, "Wriggle Speed");
        }

        protected override void FindProperties(MaterialProperty[] props)
        {
            base.FindProperties(props);

            // Penetration
            squeeze = FindProperty("_squeeze");
            squeezeDist = FindProperty("_SqueezeDist");
            bulgePower = FindProperty("_BulgePower");
            bulgeOffset = FindProperty("_BulgeOffset");
            length = FindProperty("_Length");
            entranceStiffness = FindProperty("_EntranceStiffness");
            curvature = FindProperty("_Curvature");
            reCurvature = FindProperty("_ReCurvature");
            wriggle = FindProperty("_Wriggle");
            wriggleSpeed = FindProperty("_WriggleSpeed");
        }
    }
}
