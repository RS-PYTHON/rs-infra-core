### 7. Deploy the apps


!!! warning "Disclaimer : For Wazuh Server installation"
    See **_"1. Enable Bcrypt encryption"_** in the [Wazuh-Server_Install](./how-to/Wazuh-Server_Install.md) and update the `encrypt.py` library before deploy the apps.

```shellsession
ansible-playbook apps.yaml \
    -i inventory/mycluster/hosts.yaml
```
!!! warning "Disclaimer : For Prefect-Worker post-configuration"
    See **_"2. set `Concurrency Limit` on workpool _on-demand-k8s-pool_"_** in the [Prefect-Worker](./how-to/Prefect-Worker.md) after deploy the app.

# Copyright and license

The Reference System Software as a whole is distributed under the Apache License, version 2.0. A copy of this license is available in the [LICENSE](/LICENSE) file. Reference System Software depends on third-party components and code snippets released under their own license (obviously, all compatible with the one of the Reference System Software). These dependencies are listed in the [NOTICE](NOTICE.md) file.

<br> <br>
![](media/banner_logo.jpg)
<!---
Centering the banner logo image is not rendered with mkdocs in rs-documentation repository
-->
<!---
<p align="center">
 <img src="/docs/media/banner_logo.jpg" width="71%" height="71%" />
</p>
-->
<p align="center">This project is funded by the EU and ESA.</p>
<br> <br>