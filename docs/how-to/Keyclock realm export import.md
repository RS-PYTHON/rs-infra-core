# Keyclock realm export import

## Export existing realm

- Go to the Keycloak admin web page: `https://iam.{{ platform_domain_name }}/admin`
- Export the realm:
  1. Select the realm
  2. Click on Realm settings
  3. Click on Action
  4. Click on Partial export  
  ![Keycloak export part 1](/docs/media/keycloak_export_1.png)
- On the new pop-up
  1. Turn "On" for the two options "Include groups and roles" and "Include clients"  
  ![Keycloak export part 2](/docs/media/keycloak_export_2.png)