# Infrastructure - Cluster Management

## Overview

Every command listed in this file needs to be executed in the terraform folder : `roles/terraform/create-cluster/tasks`

## Show what terraform objects are created

```shellsession
terraform state list
```

## Remove a terraform object from the state

NOTE: This wont delete the object from the cloud provider, it just won't be managed by terraform anymore.
```shellsession
terraform state rm <terraform_object>
```

## Show the output variables 

```shellsession
terraform output
```