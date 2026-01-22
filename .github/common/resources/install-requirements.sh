#!/bin/bash
# Copyright 2023-2026 Airbus, CS Group
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

set -euo pipefail

PYTHON_VERSION=3.13.11

# Install miniforge
mkdir -p ~/miniforge3
wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O ~/miniforge3/miniforge.sh
bash ~/miniforge3/miniforge.sh -b -u -p ~/miniforge3
rm -f ~/miniforge3/miniforge.sh

# Init conda
~/miniforge3/bin/conda init bash
conda update -n base -c defaults conda

# Create conda env with python
# conda update -n base -c defaults conda
conda create -y -n rspy python=$PYTHON_VERSION

# Install Ansible, Terraform, Openstackclient
# DO NOT INSTALL THESE VERSIONS:
# - kubernetes-helm 4.0 - see https://github.com/kubernetes-sigs/kustomize/issues/6013
# - kustomize 5.8.0 - see https://github.com/kubernetes-sigs/kustomize/issues/6014 - https://github.com/kubernetes-sigs/kustomize/issues/6027 - https://github.com/kubernetes-sigs/kustomize/issues/6031
conda run -n rspy conda install -y -c conda-forge ansible terraform python-openstackclient passlib boto3 "kubernetes-helm<4" kubernetes-client python-kubernetes "bcrypt<5" "kustomize<5.8.0"

conda run -n rspy ansible-galaxy collection install openstack.cloud amazon.aws kubernetes.core community.general
