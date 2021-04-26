#if UNITY_EDITOR
using System;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;

namespace Rokk.DummyToon.Editor.ShaderOptimizerSupport
{
    [InitializeOnLoad]
    public static class ShaderOptimizerKeywordSetter
    {
        /// <summary>
        /// Add the shader optimizer global define keyword if the shader optimizer exists. If it doesn't, remove the define keyword.
        /// This class should ALWAYS be in a separate assembly definition so that it can auto-fix compile errors in the main assembly!
        /// </summary>
        static ShaderOptimizerKeywordSetter()
        {
            // Check for shader optimizer keyword right now
            CheckShaderOptimizerKeyword();
        }

        private static void CheckShaderOptimizerKeyword()
        {
            // Can't just do var optimizerType = Type.GetType("Kaj.ShaderOptimizer");
            // Because this script is in a separate assembly definition
            Type optimizerType = null;
            var mainEditorAssembly = AppDomain.CurrentDomain.GetAssemblies().Where(a => a.FullName.StartsWith("Assembly-CSharp-Editor")).FirstOrDefault();
            if (mainEditorAssembly != null)
            {
                foreach (var type in mainEditorAssembly.GetTypes())
                {
                    if (type.FullName == "Kaj.ShaderOptimizer")
                    {
                        optimizerType = type;
                        break;
                    }
                }
            }

            string definesString = PlayerSettings.GetScriptingDefineSymbolsForGroup(EditorUserBuildSettings.selectedBuildTargetGroup);
            List<string> allDefines = definesString.Split(';').ToList();

            if (optimizerType != null)
            {
                // Optimizer exists and is installed, add define symbol if necessary
                if (!allDefines.Contains("SHADEROPTIMIZER_INSTALLED"))
                {
                    allDefines.Add("SHADEROPTIMIZER_INSTALLED");
                    PlayerSettings.SetScriptingDefineSymbolsForGroup(EditorUserBuildSettings.selectedBuildTargetGroup, string.Join(";", allDefines.ToArray()));
                }
            }
            else
            {
                // Optimizer does not exist, remove the define symbol if necessary
                if (allDefines.Contains("SHADEROPTIMIZER_INSTALLED"))
                {
                    allDefines.Remove("SHADEROPTIMIZER_INSTALLED");
                    PlayerSettings.SetScriptingDefineSymbolsForGroup(EditorUserBuildSettings.selectedBuildTargetGroup, string.Join(";", allDefines.ToArray()));
                }
            }
        }
    }
}
#endif
