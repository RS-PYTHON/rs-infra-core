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

FROM ghcr.io/dask/dask-gateway:2024.1.0

ARG IMAGE2BUILD
ARG DASK_TAG="2024.5.2"
ARG DASK_GATEWAY_TAG="2024.1.0"

USER root

#COPY ./resources/requirements.txt /opt/
#COPY ./resources/requirements-force.txt /opt/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

# Install dependencies necessary for execution (e.g. libpq) not compilation (gcc)
RUN \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libpq-dev gcc git wget && \
    layer-cleanup.sh

RUN wget -P /opt/ "https://raw.githubusercontent.com/dask/dask-gateway/refs/tags/${DASK_GATEWAY_TAG}/dask-gateway-server/Dockerfile.requirements.txt" && \
    pip install --no-cache-dir -r /opt/Dockerfile.requirements.txt && \
    layer-cleanup.sh

# Install Dask with correct version
RUN pip install \
    dask==${DASK_TAG} \
    dask-gateway==${DASK_GATEWAY_TAG} \
    dask-gateway-server[local]==${DASK_GATEWAY_TAG} \
    bokeh>=3.1.0 \
    jupyter-server-proxy && \
    layer-cleanup.sh

# Install whatever
RUN --mount=type=secret,id=eopf_token \
    pip install -r /opt/requirement-${IMAGE2BUILD}.txt && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

# Add a default user
RUN useradd -m user
USER user
WORKDIR /home/user
