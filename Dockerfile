FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER Cailiang

ENV CONDA_DIR=/conda CONDA_VER=4.3.30

# Install conda
RUN mkdir -p $CONDA_DIR && apt update && apt install -y git curl && \
    curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  -o mconda.sh && \
    /bin/bash mconda.sh -f -b -p $CONDA_DIR && \
    rm mconda.sh

RUN mkdir -p /root/.jupyter /home/ubuntu
COPY env.yml /root/env.yml
COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py
RUN PATH=/conda/envs/canary/bin:$PATH /conda/bin/conda env create -q -f /root/env.yml && \
    ln -s /conda/envs/canary /canary && \
    ln -s /canary/lib/python3.6/site-packages/numpy/core/include/numpy /canary/include/python3.6m/numpy && \
    rm -rf /root/.cache /conda/pkgs/*

RUN echo "deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | tee /etc/apt/sources.list.d/tensorflow-serving.list && \
    curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | apt-key add - && \
    apt-get update && apt-get install tensorflow-model-server

ENV prefix="/canary/"

WORKDIR /home/ubuntu
EXPOSE 6006
EXPOSE 8888
CMD ["/canary/bin/jupyter-notebook", "--allow-root"]
