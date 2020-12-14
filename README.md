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