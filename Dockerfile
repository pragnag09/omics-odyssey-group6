# 1) choose base container
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/rstudio-notebook:2025.2-stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

# Install system packages and create required DSMLP support directory
RUN apt-get update && \
    apt-get install -y htop && \
    mkdir -p /opt/k8s-support/bin && \
    touch /opt/k8s-support/bin/initenv-createhomedir.sh && \
    chmod +x /opt/k8s-support/bin/initenv-createhomedir.sh && \
    fix-permissions /opt/k8s-support && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3) install packages using notebook user
USER jovyan

# Install all conda/mamba packages in a single run to reduce layers
RUN mamba install -y -c conda-forge -c bioconda \
    scikit-learn \
    kraken2 \
    eggnog-mapper \
    networkx \
    scipy \
    r-survey && \
    mamba clean -a -y

# 4) Create kegganog conda environment and install kegganog via pip
RUN conda create -n kegganog python=3.10 pip -y && \
    conda run -n kegganog pip install kegganog && \
    conda clean -a -y

# Optional: activate kegganog by default
# SHELL makes sure future RUN commands use conda env
SHELL ["conda", "run", "-n", "kegganog", "/bin/bash", "-c"]

# Override command to disable running jupyter notebook at launch
CMD ["/bin/bash"]
