CREATE USER keycloak WITH ENCRYPTED PASSWORD '{{ keycloak.database.password }}';
CREATE DATABASE keycloak;
GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;