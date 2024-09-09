# Enable SSO for Neuvector (Keycloak with OIDC)

## 1. Pickup informations from Keycloak

Go to Keycloak UI

**Get `Client secret`**
* Select `RSPY` realm.
* Go to `Client` menu.
* Find and select `Neuvector` client.
* Open `Neuvector` client and go to `Credentials` tab.
* Copy `Client Secret` field.

**Get `Issuer`**
* Select `RSPY` realm.
* Go to `Realm settings` menu.
* Go `Endpoint` field and open `OpenID Endpoint Configuration` in a new tab.
* Copy `issuer:` field.

## 2. Configuring Keycloak in NeuVector

Regarding Neuvector documentation : [How to integrate NeuVector and Keycloak using OIDC](https://www.suse.com/fr-fr/support/kb/doc/?id=000021278)

Access the NeuVector UI and select `Settings` on the left menu.

**Identity Provider Issuer**

Copy the URL from the Keycloak issuer from step 5.

**Client ID**

Copy the Client ID name created in step 2.

**Client Secret** 

Copy the Secret collected in step 5.

**Group Claim** set to  `groups`

**Default Role** set to  `None`

Add the groups created inside Keycloak to authorize the users to access the NeuVector UI.
Select `Enable`
Submit the configuration

> [!NOTE]  
> You should see a green pop-up at the NeuVector bottom page showing the message "Server Saved!"
In your next login, you should see a `Login with OpenID` option in the NeuVector UI. Selecting this option will redirect to the Keyclaok webpage to authenticate the user. If the authentication works and the user is part of an authorized group, you will be redirected to the NeuVector UI.
