# chaos project

uditgaurav@Udit Gaurav ~/g/s/g/u/my-test (master)> kubectl create -f chaos-rbac.yaml 
```
serviceaccount/chaos-sa created
clusterrolebinding.rbac.authorization.k8s.io/pod-management-rolebinding created
clusterrole.rbac.authorization.k8s.io/pod-management-role created
```

uditgaurav@Udit Gaurav ~/g/s/g/u/my-test (master)> 
uditgaurav@Udit Gaurav ~/g/s/g/u/my-test (master)> 
uditgaurav@Udit Gaurav ~/g/s/g/u/my-test (master)> kubectl get sa
```
NAME       SECRETS   AGE
chaos-sa   0         7s
default    0         12d
```
