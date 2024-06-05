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

ARG ssh_key

USER root

RUN adduser rspy

ENV SHELL /bin/bash
ENV HOME /home/rspy
ENV RSPY_UAC_CHECK_URL http://apikeymanager.processing.svc.cluster.local:8000/check/api_key

COPY --from=rs-client /dist/whl/*.whl /tmp/
COPY ./resources/requirements.txt /opt/

RUN \
    DEBIAN_FRONTEND=noninteractive apt update && \
    apt install -y \
    vim \
    git \
    curl \
    tzdata

RUN \
    cd /opt && \
    mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts && \
    eval "$(ssh-agent -s)" && \
    echo -e $ssh_key | ssh-add - > /dev/null && \
    git clone git@github.com:RS-PYTHON/rs-demo.git

RUN pip install -U -r /opt/requirements.txt

RUN pip install -U /tmp/*.whl && opentelemetry-bootstrap -a install

COPY --chown=rspy:rspy ./resources/00-read-env.py /tmp/00-read-env.py

COPY resources/start-notebook.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/start-notebook.sh

ENTRYPOINT ["start-notebook.sh"]

EXPOSE 8888

USER rspy

WORKDIR "$HOME"