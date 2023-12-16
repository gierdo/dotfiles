# llama-cpp server with ROCm

This image runs an OpenAI compatible llama server.

It expects an gguf model available at a location specified through the
environment variable `MODEL`.

This image builds with ROCm support, even for iGPUs

For example usage, look at [llama.container](../../.config/containers/systemd/llama.container)

## GPU specific build

Building for ROCm is not necessarily portable.
I run llama on a t14s with an _AMD Ryzen 7 PRO 7840U w/ Radeon 780M Graphics_,
which translates to the ROCm gfx version `11.0.3`, which is not officially
supported by ROC, which is not officially supported by ROCm. However, by
overriding the value with `11.0.2`, we can make it work.

Building the image supports specifying a different override, if you required.

```text
podman build --build-arg VERSION=0.2.20 --build-arg OVERRIDE_GFX_VERSION=11.0.2 -t llama-cpp-python-server-rocm:0.2.20-11.0.2 .
```
