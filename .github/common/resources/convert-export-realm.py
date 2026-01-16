#!/usr/bin/env python3
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

import sys
import json
import re
from urllib.parse import urlparse
from ruamel.yaml import YAML

def remove_ids_and_containerids(obj):
    if isinstance(obj, dict):
        return {k: remove_ids_and_containerids(v) for k, v in obj.items() if k not in ("id", "containerId")}
    elif isinstance(obj, list):
        return [remove_ids_and_containerids(el) for el in obj]
    else:
        return obj

def sort_lists(obj):
    if isinstance(obj, dict):
        return {k: sort_lists(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        if all(not isinstance(el, (dict, list)) for el in obj):
            return sorted(obj, key=lambda x: str(x))
        if all(isinstance(el, dict) for el in obj) and obj:
            recursed = [sort_lists(el) for el in obj]
            def sort_key(el):
                clientId = str(el.get("clientId", ""))
                priority = el.get("priority")
                if isinstance(priority, str) and priority.isdigit():
                    priority = int(priority)
                elif not isinstance(priority, int):
                    priority = float("inf")
                name = str(el.get("name", ""))
                return (clientId, priority, name)
            return sorted(recursed, key=sort_key)
        return [sort_lists(el) for el in obj]
    else:
        return obj

def extract_realm_name(obj):
    # Try data['realm']['realm'] or data['realm'] as string
    if isinstance(obj.get("realm"), dict):
        return obj["realm"].get("realm")
    elif isinstance(obj.get("realm"), str):
        return obj["realm"]
    return None

def extract_platform_domain(obj):
    # Scan all rootUrl/adminUrl values and pick domain
    domains = set()
    def scan(o):
        if isinstance(o, dict):
            for k, v in o.items():
                if k in ("rootUrl", "adminUrl") and isinstance(v, str) and v.startswith("https://"):
                    parsed = urlparse(v)
                    host = parsed.hostname
                    if host and "." in host:
                        # remove subdomain (keep domain)
                        parts = host.split(".")
                        domains.add(".".join(parts[1:]))
                else:
                    scan(v)
        elif isinstance(o, list):
            for el in o:
                scan(el)
    scan(obj)
    return list(domains)[0]

def inject_realm_variables(obj, original_realm, variable="{{ keycloak.realm.name }}"):
    if isinstance(obj, dict):
        return {k: inject_realm_variables(v, original_realm, variable) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [inject_realm_variables(el, original_realm, variable) for el in obj]
    elif isinstance(obj, str):
        s = obj
        s = s.replace(f"/realms/{original_realm}/", f"/realms/{variable}/")
        s = s.replace(f"/admin/{original_realm}/console/", f"/admin/{variable}/console/")
        return s
    else:
        return obj

def inject_platform_variables(obj, original_domain, variable="{{ platform_domain_name }}"):
    if isinstance(obj, dict):
        return {k: inject_platform_variables(v, original_domain, variable) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [inject_platform_variables(el, original_domain, variable) for el in obj]
    elif isinstance(obj, str):
        s = re.sub(
            r"https://([a-zA-Z0-9_-]+)\." + re.escape(original_domain),
            r"https://\1." + variable,
            obj
        )
        return s
    else:
        return obj

def inject_client_secrets(obj):
    if isinstance(obj, dict):
        new_obj = {}
        client_id = obj.get("clientId")
        for k, v in obj.items():
            if k == "secret" and isinstance(v, str) and v == "**********" and client_id:
                new_obj[k] = f"{{{{ {client_id}_oidc_client_secret }}}}"
            else:
                new_obj[k] = inject_client_secrets(v)
        return new_obj
    elif isinstance(obj, list):
        return [inject_client_secrets(el) for el in obj]
    else:
        return obj

def inject_smtp_variables(realm_map):
    """
    Replace specific SMTP keys with variables in spec.realm.smtpServer.
    Only handles the case where smtpServer is a dict under spec.realm.
    Other keys are left unchanged.
    """
    smtp_server = realm_map.get("smtpServer")
    smtp_map = {
        "from": "{{ keycloak.smtp.from }}",
        "host": "{{ keycloak.smtp.host }}",
        "password": "{{ keycloak.smtp.password }}",
        "port": "{{ keycloak.smtp.port }}",
        "ssl": "{{ keycloak.smtp.ssl }}",
        "starttls": "{{ keycloak.smtp.starttls }}",
        "user": "{{ keycloak.smtp.user }}"
    }
    # Replace only the keys specified in smtp_map
    for key, var in smtp_map.items():
        if key in smtp_server:
            smtp_server[key] = var
    # Sort keys alphabetically
    realm_map["smtpServer"] = dict(sorted(smtp_server.items()))
    return realm_map

def main(inpath, outpath):
    with open(inpath, "r", encoding="utf-8") as f:
        data = json.load(f)

    cleaned = remove_ids_and_containerids(data)
    sorted_cleaned = sort_lists(cleaned)

    realm_map = sorted_cleaned if isinstance(sorted_cleaned, dict) else {"data": sorted_cleaned}

    original_realm = extract_realm_name(realm_map)
    original_domain = extract_platform_domain(realm_map)

    realm_map = inject_realm_variables(realm_map, original_realm)
    realm_map = inject_platform_variables(realm_map, original_domain)
    realm_map = inject_client_secrets(realm_map)
    realm_map = inject_smtp_variables(realm_map)

    final = {
        "apiVersion": "k8s.keycloak.org/v2alpha1",
        "kind": "KeycloakRealmImport",
        "metadata": {"name": "rspy", "namespace": "iam", "labels": {"wait-for-deployment": "Done"}},
        "spec": {"keycloakCRName": "keycloak", "realm": realm_map},
    }

    yaml = YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.width = 130
    yaml.preserve_quotes = False

    license_header = """# Copyright 2023-2026 Airbus, CS Group
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
"""

    with open(outpath, "w", encoding="utf-8") as f:
        f.write(license_header + "\n")
        yaml.dump(final, f)

    print(f"Transformation completed: {outpath}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.json> <output.yaml>", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
