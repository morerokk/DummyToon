#if SHADEROPTIMIZER_INSTALLED
using System.Collections;
using System.Text;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using System;

namespace Rokk.DummyToon.Editor.Tools
{
    [ExecuteInEditMode]
    public class MaterialLockTools
    {
        [MenuItem("Tools/Dummy Toon/Unlock Selected Materials")]
        static void UnlockSelectedMaterials()
        {
            foreach (Material material in Selection.GetFiltered<Material>(SelectionMode.Assets))
            {
                Kaj.ShaderOptimizer.Unlock(material);
                material.SetFloat("_ShaderOptimized", 0f);
            }
        }
    }
}
#endif
