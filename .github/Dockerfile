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

FROM ghcr.io/rs-python/rs-client-libraries_store:0.1a9 as rs-client

FROM quay.io/jupyter/base-notebook:hub-4.1.5

USER root

RUN adduser rspy

COPY --from=rs-client /dist/whl/*.whl /tmp/
RUN pip install -U /tmp/*.whl && opentelemetry-bootstrap -a install

RUN \
    apt update && \
    apt install -y \
    vim \
    git \
    curl

RUN \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

RUN \
    pip install -U \
    nbgitpuller \
    python-dotenv \
    boto3

ENV SHELL /bin/bash
ENV HOME /home/rspy
ENV RSPY_UAC_CHECK_URL http://apikeymanager.processing.svc.cluster.local:8000/check/api_key

EXPOSE 8888

USER rspy

WORKDIR "$HOME"