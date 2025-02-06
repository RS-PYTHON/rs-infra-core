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

FROM ghcr.io/rs-python/rs-client-libraries_store:latest as rs-client

FROM ghcr.io/rs-python/quay.io/jupyter/base-notebook:hub-4.1.5

USER root

RUN adduser rspy

ENV SHELL /bin/bash
ENV HOME /home/rspy

COPY --from=rs-client /dist/whl/*.whl /tmp/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

#DEBUG
RUN find /tmp/

# Install system dependencies
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    apt install -y \
    vim \
    git \
    curl \
    unzip \
    tzdata \
    libgtk-3-0 libasound2 libx11-xcb1 \
    xclip && \
    layer-cleanup.sh

# Install python dependencies
RUN conda install --yes conda-forge::python=3.11.7 && \
    pip install \
    dask[complete]==2024.5.2 \
    dask-gateway==2024.1.0 \
    prefect[dask,aws]==3.1.4 \
    ipywidgets \
    dask-labextension \
    graphviz \
    s3fs \
    boto3 && \
    pip install /tmp/*.whl && \
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

ENTRYPOINT ["start-notebook.sh"]

EXPOSE 8888

USER rspy

WORKDIR "$HOME"

# Set labels based on the Open Containers Initiative (OCI):
# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
#
LABEL org.opencontainers.image.source="https://github.com/RS-PYTHON/rs-infrastructure"
LABEL org.opencontainers.image.ref.name="ghcr.io/rs-python/rs-infrastructure-jupyter"
LABEL dockerfile.url="https://github.com/RS-PYTHON/rs-infrastructure/blob/develop/.github/jupyter/Dockerfile"