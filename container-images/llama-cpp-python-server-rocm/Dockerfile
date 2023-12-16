FROM ubuntu:jammy

RUN apt-get update && apt-get install -y --no-install-recommends \
  ninja-build \
  libopenblas-dev \
  python3-pip \
  wget \
  gpg \
  git \
  cmake \
  pkg-config \
  build-essential

RUN mkdir --parents --mode=0755 /etc/apt/keyrings \
  && wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
  gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/6.0 jammy main" > /etc/apt/sources.list.d/rocm.list \
  && echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' > /etc/apt/preferences.d/rocm-pin-600 \
  && apt-get update \
  && apt-get install -y --no-install-recommends rocm-hip-sdk

ARG VERSION=0.2.20

ARG OVERRIDE_GFX_VERSION=11.0.2
ENV HSA_OVERRIDE_GFX_VERSION=${OVERRIDE_GFX_VERSION}

RUN  CC=hipcc CXX=hipcc CMAKE_ARGS="-DLLAMA_HIPBLAS=on" pip install llama-cpp-python[server]==${VERSION}

ENV HOST=0.0.0.0
ENV PORT=8000
EXPOSE 8000

CMD ["bash", "-c", "python3 -m llama_cpp.server --n_gpu_layers 15 --host ${HOST} --port ${PORT}"]
