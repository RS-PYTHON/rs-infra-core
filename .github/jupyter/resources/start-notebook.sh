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
# Shim to emit warning and call start-notebook.py

echo "WARNING: Use start-notebook.py instead"
#Copy read-env to HOME
mkdir -p "$HOME/.ipython/profile_default/startup/"
chmod 2775 "$HOME/.ipython/profile_default/startup/"
cp /tmp/00-read-env.py "$HOME/.ipython/profile_default/startup/"

cp /tmp/jupyter_server_config.py /home/rspy/.jupyter/jupyter_server_config.py
chmod 644 /home/rspy/.jupyter/jupyter_server_config.py

cp -r /opt/rs-demo/notebooks "$HOME"

exec /usr/local/bin/start-notebook.py "$@"
