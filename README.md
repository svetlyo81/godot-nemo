# godot-nemo

Godot-Nemo is my custom Godot Engine build that can run Mistral-Nemo-Instruct-2407 (the 12b model) and SDXL finetunes based on Godot 4 and the Godot LLM plugin, llama.cpp, stable-diffusion.cpp, and OpenCV. It targets Windows 10 and Vulkan compatible GPUs with 6GB VRAM.

## Compiling the source

Install Git and clone the repositories:

```
git clone https://github.com/svetlyo81/llama.cpp
git clone https://github.com/svetlyo81/stable-diffusion.cpp
git clone https://github.com/svetlyo81/godot
git clone https://github.com/svetlyo81/godot-nemo

git clone https://github.com/opencv/opencv.git -b 4.x
cd opencv
git clone https://github.com/opencv/opencv_contrib -b 4.x
```

### Building llama.cpp

```
cd llama.cpp
mkdir build
cd build
```

#### CUDA build

Install Visual Studio 2022, CMake and the CUDA Toolkit (https://developer.nvidia.com/cuda-toolkit) and optionally copy the following files to godot/bin (create the bin folder since it doesn't exist yet). While not required to run Godot on your system, the files would be needed on systems that don't have the toolkit installed. Microsoft Visual C++ Redistributable may be required on systems where Visual Studio isn't available. It should be installed along with the NVIDIA drivers but can be found here too https://aka.ms/vs/17/release/vc_redist.x64.exe

CUDA/bin/cublas64_XX.dll -> godot/bin

CUDA/bin/cublasLt64_XX.dll -> godot/bin

CUDA/bin/cudart64_XX.dll -> godot/bin

```
cmake .. -DBUILD_SHARED_LIBS=ON -DGGML_CUDA=ON
cmake --build . --config Release
```

Copy the files to the respective folders:

llama.cpp/build/bin/release/ggml.dll -> godot/bin

llama.cpp/build/bin/release/llama.dll -> godot/bin

llama.cpp/build/src/Release/llama.lib -> godot/modules/gdllama/llama-win

llama.cpp/build/ggml/src/Release/ggml.lib -> godot/modules/gdllama/llama-win

#### Vulkan build

Install MSYS2:

https://github.com/msys2/msys2-installer/releases

https://github.com/msys2/msys2-installer/releases/download/2024-12-08/msys2-x86_64-20241208.exe

Run the following commands in the UCRT64 terminal:

```
pacman -S git \
    mingw-w64-ucrt-x86_64-gcc \
    mingw-w64-ucrt-x86_64-cmake \
    mingw-w64-ucrt-x86_64-vulkan-devel \
    mingw-w64-ucrt-x86_64-shaderc \
    mingw-w64-ucrt-x86_64-scons
```

```
cmake .. -DBUILD_SHARED_LIBS=ON -DGGML_VULKAN=1
cmake --build . --config Release
```

llama.cpp/build/bin/release/libggml.dll -> godot/bin

llama.cpp/build/bin/release/libllama.dll -> godot/bin

llama.cpp/build/ggml/src/libggml.dll.a -> godot/modules/gdllama/llama-win

llama.cpp/build/src/libllama.dll.a -> godot/modules/gdllama/llama-win

llama.cpp/build/common/libcommon.a -> godot/modules/gdllama/llama-win

msys2/ucrt64/bin/libgcc_s_seh-1.dll -> godot/bin

msys2/ucrt64/bin/libgomp-1.dll -> godot/bin

msys2/ucrt64/bin/libstdc++-6.dll -> godot/bin

msys2/ucrt64/bin/libwinpthread-1.dll -> godot/bin

### Building stable-diffusion.cpp

```
cd stable-diffusion.cpp
mkdir build
cd build
```

#### CUDA build

```
cmake .. -DSD_BUILD_SHARED_LIBS=ON -DSD_CUDA=ON
cmake --build . --config Release
```

stable-diffusion.cpp/build/bin/release/stable-diffusion.dll -> godot/bin

stable-diffusion.cpp/build/release/stable-diffusion.lib -> godot/modules/gdllama/diffusion-win

#### Vulkan build

```
cmake .. -DSD_BUILD_SHARED_LIBS=ON -DSD_VULKAN=ON
cmake --build . --config Release
```

stable-diffusion.cpp/build/bin/libstable-diffusion.dll -> godot/bin

stable-diffusion.cpp/build/libstable-diffusion.dll.a -> godot/modules/gdllama/diffusion-win

### Building OpenCV

```
cd opencv
mkdir build
cd build
```

#### Visual Studio 2022

```
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_opencv_legacy=OFF -DBUILD_EXAMPLES=ON -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ..
cmake --build . --config Release -j 7
cmake --install . --config Release
```

build/install/include/opencv2 -> $(VC_IncludePath), for example:
Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.38.33130/include

all the .lib files in build/install/x64/vc17/lib -> $(VC_LibraryPath_x64), for example:
Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.38.33130/lib/x64

build/bin/Release/ opencv_core4130.dll opencv_imgproc4130.dll opencv_imgcodecs4130.dll opencv_dnn4130.dll opencv_dnn_superres4130.dll -> godot/bin

#### MSYS2

```
cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/mingw64 -DBUILD_SHARED_LIBS=ON -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DBUILD_opencv_legacy=OFF -DBUILD_EXAMPLES=ON -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules ..
ninja
ninja install
```

msys2\mingw64\include\opencv2 -> msys2\ucrt64\include

all the .a files in msys2\mingw64\x64\mingw\lib -> msys2\ucrt64\lib

msys2\mingw64\x64\mingw\bin\ libopencv_core4130.dll libopencv_imgproc4130.dll libopencv_imgcodecs4130.dll libopencv_dnn4130.dll libopencv_dnn_superres4130.dll -> godot/bin

### Building Godot

#### Visual Studio 2022

Generate Visual Studio solution:

```
scons platform=windows vsproj=yes dev_build=yes
```

Build without debug symbols (dev_build=yes for debug build):

```
scons platform=windows dev_build=no
```

Adding the --clean parameter to the command above will clean the respective build.

#### MSYS2

```
scons platform=windows use_mingw=yes
```

## Running the demo

Download the following files and put them in the godot-nemo/godot-nemo-demo folder:


Mistral-Nemo-Instruct-2407.Q5_K_M.gguf

https://huggingface.co/bartowski/Mistral-Nemo-Instruct-2407-GGUF/blob/9124e92876a2a7c0e8741d7176343f45b3896960/Mistral-Nemo-Instruct-2407-Q5_K_M.gguf


mxbai-embed-large-v1.Q5_K_M.gguf

https://huggingface.co/ChristianAzinn/mxbai-embed-large-v1-gguf/blob/main/mxbai-embed-large-v1.Q5_K_M.gguf


DreamShaperXL_Lightning-SFW.safetensors

https://huggingface.co/Lykon/dreamshaper-xl-lightning/blob/main/DreamShaperXL_Lightning-SFW.safetensors


The Godot Editor binaries will be placed in godot/bin, run the console one and drag the godot-nemo-demo folder in the Editor window the first time you open the demo.

## On the dangers of AI

I think the main danger of using AI in games is reproducing copyrighted material. This can happen without AI too and anyone can sue anybody for anything. In a real world game application you may want to query the LLM with the user prompt to detect mentions of copyrighted material and use img2img to control image generation. There is also concern that some users may become attached to fictional AI characters and consequently be manipulated by them to do something or be exploited in some way.

I don't have actual experience in any of this, also I'm not responsible for others but with all the controversy surrounding AI I felt that I should at least mention it. Again, with more than 50% of humans believeing either/both that the Earth is flat and that there's an invisible man watching them from the sky at all times personally I consider humans to be the danger at this time. They're more likely to do somebody harm than admit they're wrong about something. I wish it was a joke but beware the dangers.

## References

[Godot Engine](https://github.com/godotengine/godot)

[Godot LLM Plugin](https://github.com/Adriankhl/godot-llm-template)

[llama.cpp](https://github.com/ggerganov/llama.cpp)

[stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp)

[OpenCV](https://github.com/opencv)
