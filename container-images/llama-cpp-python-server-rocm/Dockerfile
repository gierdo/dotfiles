FROM ubuntu:noble AS rocm_base

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  wget \
  gpg \
  pkg-config \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

ARG ROCM_VERSION=6.2.4

RUN mkdir --parents --mode=0755 /etc/apt/keyrings \
  && wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
  gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} noble main" > /etc/apt/sources.list.d/rocm.list \
  && echo 'Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600' > /etc/apt/preferences.d/rocm-pin-600

# Allow caching the runtime base even if llama_cpp is rebuilt
FROM rocm_base AS runtime_base

RUN apt-get update && apt-get install -y --no-install-recommends \
  python3-pip \
  rocm-hip-libraries \
  rocm-device-libs \
  rocm-llvm \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/


FROM runtime_base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
  ninja-build \
  libopenblas-dev \
  git \
  cmake \
  pkg-config \
  build-essential \
  rocm-hip-sdk \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

ARG OVERRIDE_GFX_VERSION=11.0.2
ENV HSA_OVERRIDE_GFX_VERSION=${OVERRIDE_GFX_VERSION}
ARG LLAMA_CPP_VERSION=0.3.6

RUN CC=hipcc CXX=hipcc CMAKE_ARGS="-DLLAMA_HIPBLAS=on" pip install --user --break-system-packages llama-cpp-python[server]==${LLAMA_CPP_VERSION}

FROM runtime_base AS final
LABEL maintainer="Dominikus Gierlach <dominik.gierlach@gmail.com>"

ARG OVERRIDE_GFX_VERSION=11.0.2
ENV HSA_OVERRIDE_GFX_VERSION=${OVERRIDE_GFX_VERSION}

COPY --from=builder /root/.local /root/.local

ENV HOST=0.0.0.0
ENV PORT=8000
EXPOSE 8000

CMD ["bash", "-c", "python3 -m llama_cpp.server --n_gpu_layers 15 --host ${HOST} --port ${PORT}"]
