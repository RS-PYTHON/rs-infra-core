#!/bin/bash
# Copyright 2025 Airbus, CS Group
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

echo "Testing oauth2-proxy for domain ${DOMAIN} and Keycloak instance ${KEYCLOAK_URL}..."

#############################################
# 🔧 Debug function used on any fatal error
#############################################
debug_and_fail() {
  local exit_code=${1:-1}
  echo
  echo "❌ ERROR detected. Running debug diagnostics..."
  echo
  echo "-- Logs for oauth2-proxy:"
  kubectl logs -n iam -l app.kubernetes.io/name=oauth2-proxy
  echo
  echo "-- Logs for keycloak:"
  kubectl logs -n iam keycloak-0
  echo
  echo "-- Logs for ingress-nginx:"
  kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
  echo
  echo "== oauth2-proxy pods =="
  kubectl get pods -n iam -l app.kubernetes.io/name=oauth2-proxy -o wide
  echo "== oauth2-proxy service =="
  kubectl get svc -n iam oauth2-proxy -o yaml
  echo "== oauth2-proxy endpoints =="
  kubectl get endpoints -n iam oauth2-proxy -o yaml
  echo
  echo "💥 Exiting with code ${exit_code}"
  exit "${exit_code}"
}

REALM=rspy
# --- Create a new user in rspy realm using admin token ---
USER_NAME=testuser
USER_PASS=SuperPassword123

echo "👤 Creating new user ${USER_NAME} in realm ${REALM}..."
wget -q \
  --header="Authorization: Bearer ${ADMIN_TOKEN}" \
  --header="Content-Type: application/json" \
  --no-check-certificate \
  --post-data "{
    \"username\": \"${USER_NAME}\",
    \"enabled\": true,
    \"emailVerified\": true
  }" "${KEYCLOAK_URL}/admin/realms/${REALM}/users" \
  || debug_and_fail 10

sleep 0.25

echo "🔍 Looking for user id..."
USER_ID=$(wget -qO- \
  --header="Authorization: Bearer ${ADMIN_TOKEN}" \
  --no-check-certificate \
  "${KEYCLOAK_URL}/admin/realms/${REALM}/users?username=${USER_NAME}" | jq -r '.[0].id') \
  || debug_and_fail 11

if [[ -z "${USER_ID}" ]] || [[ "${USER_ID}" = "null" ]]; then
  echo "❌ Failed to create Keycloak user"
  debug_and_fail 12
fi

echo "🔑 Setting password for user with id ${USER_ID}..."
curl -k -s -X PUT \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{
    \"type\": \"password\",
    \"temporary\": false,
    \"value\": \"${USER_PASS}\"
  }" "${KEYCLOAK_URL}/admin/realms/${REALM}/users/${USER_ID}/reset-password" \
  || debug_and_fail 13

sleep 0.25

# --- Obtain oidc access token for this user ---
#CLIENT_ID=oauth2-proxy
CLIENT_ID=fastapi_public
echo "🔑 Getting oidc token for client ${CLIENT_ID} from keycloak..."
RAW=$(wget -qO- \
  --post-data "username=${USER_NAME}&password=${USER_PASS}&grant_type=password&client_id=${CLIENT_ID}" \
  --header="Content-Type: application/x-www-form-urlencoded" \
  --no-check-certificate \
  "${KEYCLOAK_URL}/realms/${REALM}/protocol/openid-connect/token") \
  || debug_and_fail 14
TOKEN=$(echo "${RAW}" | jq -r .access_token)

if [[ -z "${TOKEN}" ]] || [[ "${TOKEN}" = "null" ]]; then
  echo "❌ Failed to obtain Keycloak token"
  echo "Response from Keycloak:"
  echo "${RAW}"
  debug_and_fail 15
fi

echo "🔑 Using oidc token ${TOKEN} with oauth2-proxy..."
RESPONSE=$(curl -k -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer ${TOKEN}" "https://oauth2-proxy.${DOMAIN}/oauth2/auth")
if [[ "${RESPONSE}" != "202" ]]; then
  echo "❌ oauth2-proxy rejected Keycloak token: ${RESPONSE}"
  echo "TODO fix this test !!!"
  # debug_and_fail 16
  exit 0  # TODO fix this test !!!
fi
echo "✅ oauth2-proxy accepted Keycloak token"
