# Dummy Toon Shader
A toon shader for Unity. Supports the Forward rendering pipeline.

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

This branch of the shader works in Unity 2018 and up, and probably on 5.6 and Unity 2017 too. Please get the master branch/regular release if you're on Unity 2019, due to local shader keywords!

For more information on the shader or how to use features, make sure to check the Wiki tab of this repository.
