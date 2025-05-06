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

# Get the wheel of the rs-dpr-service, in order to install it later on
FROM ghcr.io/rs-python/rs-dpr-service:latest as dpr_service

ARG IMAGE2BUILD
ARG DASK_TAG=2024.5.2
ARG DASK_GATEWAY_TAG=2024.1.0
ARG PREFECT_TAG=3.2.13
ARG PREFECT_DASK_TAG=0.3.3

USER root

COPY ./*.whl ./
COPY ./resources/requirements-dask-eopf.txt /opt/
COPY ./resources/requirements-dask-staging.txt /opt/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

# Install dependencies necessary for execution (e.g. libpq) not compilation (gcc)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libpq-dev libexpat1 gcc git wget && \
    pip install --no-cache-dir -q --upgrade pip && \
    layer-cleanup.sh

# Download and install dask-gateway-server requirements
RUN wget -q -P /opt/ "https://raw.githubusercontent.com/dask/dask-gateway/refs/tags/${DASK_GATEWAY_TAG}/dask-gateway-server/Dockerfile.requirements.txt" && \
    sed -i "s|\(^\s*dask-gateway-server\)|# \1|g" /opt/Dockerfile.requirements.txt && \
    pip install --no-cache-dir -r /opt/Dockerfile.requirements.txt && \
    layer-cleanup.sh

# Install whatever
RUN --mount=type=secret,id=GITLAB_EOPF_TOKEN \
    GITLAB_EOPF_TOKEN=$(cat /run/secrets/GITLAB_EOPF_TOKEN) \
    RS_SERVER_COMMON_WHEEL=$(find . -maxdepth 1 -type f -name 'rs_server_common-*-py3-none-any.whl' | head -n 1) \
    RS_SERVER_STAGING_WHEEL=$(find . -maxdepth 1 -type f -name 'rs_server_staging-*-py3-none-any.whl' | head -n 1) \
    pip install -U -r /opt/requirements-${IMAGE2BUILD}.txt && \
    rm -f /opt/Dockerfile.requirements.txt /opt/requirements-dask-eopf.txt /opt/requirements-dask-staging.txt ./*.whl && \
    layer-cleanup.sh

# copy the dpr-service requirements file and the wheel as well
COPY ./resources/requirements-dpr-service.txt /opt/
COPY --from=dpr_service /rs-dpr-service/whl /tmp/whl
# Install Dask with correct version
RUN pip install \
        dask[complete]==${DASK_TAG} \
        distributed==${DASK_TAG} \
        dask-gateway==${DASK_GATEWAY_TAG} \
        dask-gateway-server[kubernetes]==${DASK_GATEWAY_TAG} \
        bokeh">=3.1.0" \
        jupyter-server-proxy && \
    if [ "${IMAGE2BUILD}" = "dask-eopf" ]; then \
        pip install \
            prefect[aws]==${PREFECT_TAG} \
            prefect-dask==${PREFECT_DASK_TAG} && \
        pip install -U -r /opt/requirements.dpr-service.txt && \
        pip install --no-cache-dir /tmp/whl/rs_dpr_service-*.whl && \
        rm -f /opt/requirements.dpr-service.txt ; \
    fi && \
    layer-cleanup.sh

# Install and auto configure opentelemetry
RUN pip install opentelemetry-distro opentelemetry-exporter-otlp opentelemetry-instrumentation-aws-lambda opentelemetry-test-utils && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

RUN if [ "${IMAGE2BUILD}" = "dask-eopf" ]; then \
        apt update && apt install -y python3-pydot graphviz && layer-cleanup.sh; \
    fi
RUN apt autoremove -y gcc && layer-cleanup.sh

# Add a default user
RUN useradd -m user
USER user
WORKDIR /home/user

# Set labels based on the Open Containers Initiative (OCI):
# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
#
LABEL org.opencontainers.image.source="https://github.com/RS-PYTHON/rs-infra-core"
# ghcr.io/rs-python/rs-infra-core-dask-staging or ghcr.io/rs-python/rs-infra-core-dask-eopf
LABEL org.opencontainers.image.ref.name="ghcr.io/rs-python/rs-infra-core-${IMAGE2BUILD}"
LABEL dockerfile.url="https://github.com/RS-PYTHON/rs-infra-core/blob/develop/.github/dask-gateway/Dockerfile"
