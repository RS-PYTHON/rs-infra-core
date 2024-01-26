# Start and stop the cluster

## Prerequisites
Copy the openrc.sh.template into openrc.sh and change the values inside to match your configuration
```shellsession
cp -rfp inventory/sample/openrc.sh.template inventory/mycluster/openrc.sh
```

## Stop the cluster

 - After configuring the openrc.sh file, use this command to stop the cluster :
```shellsession
ansible-playbook start-stop.yaml     -i inventory/mycluster/hosts.yaml -t stop
```

## Start the cluster

 - After configuring the openrc.sh file, use this command to stop the cluster :
```shellsession
ansible-playbook start-stop.yaml     -i inventory/mycluster/hosts.yaml -t start
```

