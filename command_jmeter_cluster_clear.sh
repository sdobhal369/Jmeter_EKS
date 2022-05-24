#!/usr/bin/env bash

working_dir=`pwd`

echo "checking if kubectl is present"

if ! hash kubectl 2>/dev/null
then
    echo "'kubectl' was not found in PATH"
    echo "Kindly ensure that you can acces an existing kubernetes cluster via kubectl"
    exit
fi

kubectl version --short

echo "Current list of namespaces on the kubernetes cluster:"

kubectl get namespaces | grep -v NAME | awk '{print $1}'

echo "Enter the name of the tenant name, this will be used to delete the namespace"
read tenant

echo "Delete Jmeter slave nodes"

nodes=`kubectl get no | egrep -v "master|NAME" | wc -l`

echo "Number of worker nodes on this cluster is " $nodes

echo "Delete $nodes Jmeter slave replicas and service"

kubectl delete -n $tenant -f $working_dir/jmeter_slaves_deploy.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_slaves_svc.yaml

echo "Delete Jmeter Master"

kubectl delete -n $tenant -f $working_dir/jmeter_master_configmap.yaml

kubectl delete -n $tenant -f $working_dir/jmeter_master_deploy.yaml
