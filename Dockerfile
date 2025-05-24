# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/rstudio-notebook:2025.2-stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

RUN apt-get -y install htop

# 3) install packages using notebook user
USER jovyan

# RUN conda install -y scikit-learn kraken2

RUN pip install --no-cache-dir networkx scipy

USER root
RUN mamba install -c conda-forge r-survey -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    mamba clean -a -y

FROM ubuntu:latest
RUN apt-get update && apt-get install -y \
    wget \
    python3 \
    python3-pip \
    diamond \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir \
    requests \
    tqdm \
    pandas 
RUN pip3 install --no-cache-dir eggnog-mapper
WORKDIR /opt/eggnog-mapper
ENV PATH="/opt/eggnog-mapper:${PATH}"
RUN mkdir -p /data/eggnog_db
VOLUME /data/eggnog_db
WORKDIR /data

USER jovyan

# Override command to disable running jupyter notebook at launch
CMD ["/bin/bash"]
