# Dummy Toon Shader
A toon shader for Unity 2019 and up. Supports the Forward rendering pipeline. For earlier versions of Unity, check the `unity2018` branch.

## Features
* Solid toon shading that looks good and consistent in a large variety of different lighting setups
* Supports baked lighting, realtime lighting, shadows, vertex lights and anything else you can expect a Unity scene to have.
* VR-friendly and light on performance
* Normal maps, detail normals, emission
* Opaque, Cutout, Transparent and Alpha To Coverage rendering modes
* Outlines
* Matcaps
* Rimlight
* Custom toon ramps, supporting up to 4 different toon ramps on the same material, helping keep the amount of drawcalls down
* Experimental "eye tracking" feature, which allows a character to dynamically look at the camera and back forward using only a shader
* Custom editor GUI with integrated help boxes and a clean interface

## Installation
Grab the latest release from the "Releases" tab of this repository. Download and import the unity package. If your Unity version is older than the package, download this repository as zip instead, and extract it to your assets folder.

This shader only works in Unity 2019 and up, due to the reliance on local shader keywords.

For more information on the shader or how to use features, make sure to check the Wiki tab of this repository.

#Third Party
This shader has optional built-in support for some third-party libraries or shaders. These are automatically detected.
* **[Kaj Shader Optimizer](https://github.com/DarthShader/Kaj-Unity-Shaders):** When the shader optimizer is installed, a button is automatically added to the shader inspector that allows you to automatically "lock in" the material, generating a new auto-optimized shader. This gives a nice performance boost on the GPU, and bakes the enabled material keywords directly into the shader.

Note: if the automatic detection for shader optimizer doesn't work, you can manually add the `SHADEROPTIMIZER_INSTALLED` keyword to your project's define symbols. You may have to delete the `Dummy Toon Shader/Scripts/Editor/ShaderOptimizerSupport` folder to prevent the define from being automatically deleted.
