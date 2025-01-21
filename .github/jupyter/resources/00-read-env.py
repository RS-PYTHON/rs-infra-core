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

#Script to automatically import environment variables from $HOME/.env file
import os
from dotenv import load_dotenv
from pathlib import Path

env_path = Path(os.getenv("HOME")) / '.env'

# TODO: temporary change to deactivate OGC staging endpoint validation on client side
os.environ["RSPY_APPLY_STAGING_ENDPOINTS_VALIDATION"] = "0"
load_dotenv(dotenv_path=env_path)