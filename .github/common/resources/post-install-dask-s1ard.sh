#!/usr/bin/env bash
# Copyright 2025 CS Group
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
set -x

# This is a workaround for https://gitlab.eopf.copernicus.eu/S1/s1-ard-core/-/issues/10
chmod -R a+w /usr/local/lib/python3.11/site-packages/pyproj/proj_dir/share/proj

# Same as s1-ard-core/initialize_env.sh
S1_ARD_PATH=$(python -c "import s1_ard_core;print(s1_ard_core.__path__[0])")
SARSEN_PATH=$(python -c "import sarsen;print(sarsen.__path__[0])")
SARPY_PATH=$(python -c "import sarpy;print(sarpy.__path__[0])")
cp ${S1_ARD_PATH}/patch/sarsen/*py ${SARSEN_PATH}/
cp ${S1_ARD_PATH}/patch/sarpy/sentinel.py ${SARPY_PATH}/io/complex/sentinel.py
