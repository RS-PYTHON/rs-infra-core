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

USER root

COPY ./resources/requirements.txt /opt/
COPY ./resources/requirements-force.txt /opt/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

# Install dependencies necessary for execution (e.g. libpq) not compilation (gcc)
RUN \
    apt update && \
    apt install -y libpq-dev gcc git && \
    layer-cleanup.sh

# Install requirements
RUN pip install -U -r /opt/requirements.txt && \
    layer-cleanup.sh

# Install rs-server-staging
RUN pip install --upgrade rs-server-staging==0.2a9 && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

# Fix versions 
RUN pip install --force-reinstall -r /opt/requirements-force.txt && \
    layer-cleanup.sh

# Add a default user
RUN useradd -m user
USER user
WORKDIR /home/user

# Set labels based on the Open Containers Initiative (OCI):
# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
#
LABEL org.opencontainers.image.source="https://github.com/RS-PYTHON/rs-infrastructure"
LABEL org.opencontainers.image.ref.name="ghcr.io/rs-python/rs-infrastructure-dask-gateway"
LABEL dockerfile.url="https://github.com/RS-PYTHON/rs-infrastructure/blob/develop/.github/dask-gateway/Dockerfile"
