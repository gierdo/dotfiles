FROM python:3-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
  ninja-build \
  libopenblas-dev \
  cmake \
  pkg-config \
  build-essential \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

ARG VERSION=0.2.19

RUN CMAKE_ARGS="-DLLAMA_BLAS=ON -DLLAMA_BLAS_VENDOR=OpenBLAS" python3 -m pip install llama-cpp-python[server]==${VERSION}

ENV HOST=0.0.0.0
ENV PORT=8000
EXPOSE 8000

CMD ["bash", "-c", "uvicorn --factory llama_cpp.server.app:create_app --host $HOST --port $PORT"]
