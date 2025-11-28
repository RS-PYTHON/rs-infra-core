# Copyright 2024 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Target Docker image name:
# ghcr.io/rs-python/rs-infra-core-jupyter
#

ARG PYTHON_VERSION=3.13.9
FROM ghcr.io/rs-python/rs-client-libraries_store:latest AS rs-client

FROM ghcr.io/rs-python/quay.io/jupyter/base-notebook:hub-5.4.2-py${PYTHON_VERSION}

ARG PYTHON_VERSION=3.13.9
ARG DASK_TAG=2024.5.2
ARG DASK_GATEWAY_TAG=2024.1.0
ARG PREFECT_TAG=3.2.13

USER root

COPY ./resources/layer-cleanup.sh ./resources/restore-apt.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh /usr/local/bin/restore-apt.sh

RUN restore-apt.sh && apt update && \
    apt install -y adduser && \
    adduser rspy && \
    layer-cleanup.sh

ENV SHELL=/bin/bash
ENV HOME=/home/rspy

COPY ./*.whl /opt/

# Install system dependencies
RUN DEBIAN_FRONTEND=noninteractive restore-apt.sh && apt update && \
    apt install -y \
    jq \
    vim \
    git \
    curl \
    unzip \
    tzdata \
    libgtk-3-0 libasound2t64 libx11-xcb1 \
    xclip \
    graphviz \
    python3-pydot \
    texlive-xetex texlive-fonts-recommended texlive-plain-generic && \
    layer-cleanup.sh

# Install python dependencies
RUN conda update -n base -c conda-forge conda && \
    conda install --yes conda-forge::python=${PYTHON_VERSION} && \
    pip install --upgrade pip && \
    pip install \
    dask[complete]==${DASK_TAG} \
    distributed==${DASK_TAG} \
    dask-gateway==${DASK_GATEWAY_TAG} \
    prefect[aws]==${PREFECT_TAG} \
    ipywidgets \
    dask-labextension \
    nbconvert[webpdf] \
    s3fs \
    boto3 \
    cftime \
    zarr \
    scipy \
    xarray \
    netCDF4 \
    h5netcdf \
    geopandas \
    matplotlib \
    nc-time-axis \
    pooch \
    fsspec \
    cartopy \
    seaborn \
    stac-api-validator && \
    pip install /opt/*.whl && \
    conda clean --all --yes && \
    layer-cleanup.sh

# Install and auto configure opentelemetry
RUN pip install opentelemetry-distro opentelemetry-exporter-otlp && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

# Install last version of firefox for automated tests
RUN curl -L -o /tmp/firefox.tar.xz "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" && \
    tar -xf /tmp/firefox.tar.xz -C /opt/ && \
    ln -s /opt/firefox/firefox /usr/bin/firefox && \
    rm /tmp/firefox.tar.xz

# Clone rs-demo repository
RUN cd /opt && \
    git clone https://github.com/RS-PYTHON/rs-demo.git

COPY --chown=rspy:rspy ./resources/00-read-env.py /tmp/00-read-env.py
COPY --chown=rspy:rspy ./resources/jupyter_server_config.py /tmp/jupyter_server_config.py

COPY resources/start-notebook.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start-notebook.sh

# Remove custom scripts
RUN rm -f /usr/local/bin/layer-cleanup.sh /usr/local/bin/restore-apt.sh

ENTRYPOINT ["start-notebook.sh"]

EXPOSE 8888

USER rspy

WORKDIR "$HOME"

# To be able to import notebooks/resources/ from python
ENV PYTHONPATH="$HOME/notebooks"

# Set labels based on the Open Containers Initiative (OCI):
# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
#
LABEL org.opencontainers.image.source="https://github.com/RS-PYTHON/rs-infra-core"
LABEL dockerfile.url="https://github.com/RS-PYTHON/rs-infra-core/blob/develop/.github/jupyter/Dockerfile"