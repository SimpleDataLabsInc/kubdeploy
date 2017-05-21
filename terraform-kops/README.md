# EveryTime

* Ensure that you have followed the OneTime Steps
* modify deploy.sh if you need to
* generate terraform spec using kops
```
cd kub/terraform-kops
./deploy.sh
```
* run generated terraform spec
```
  cd ./out/terraform
  $ terraform plan
  $ terraform apply
```

## Validate the cluster is running properly
```
Rajs-MBP:terraform rajbains$ kops validate cluster --state s3://simpledatalabs-io-state-store
Using cluster from kubectl context: dev1.simpledatalabs.io

Validating cluster dev1.simpledatalabs.io

INSTANCE GROUPS
NAME                    ROLE    MACHINETYPE     MIN     MAX     SUBNETS
bastions                Bastion t2.micro        1       1       utility-ap-south-1a
master-ap-south-1a      Master  t2.medium       1       1       ap-south-1a
nodes                   Node    t2.medium       1       1       ap-south-1a

NODE STATUS
NAME                                            ROLE    READY
ip-172-20-38-160.ap-south-1.compute.internal    master  True
ip-172-20-55-64.ap-south-1.compute.internal     node    True

Your cluster dev1.simpledatalabs.io is ready

Rajs-MBP:terraform rajbains$ kubectl -n kube-system get po
NAME                                                                   READY     STATUS    RESTARTS   AGE
dns-controller-629640180-db2gb                                         1/1       Running   0          13m
etcd-server-events-ip-172-20-38-160.ap-south-1.compute.internal        1/1       Running   0          14m
etcd-server-ip-172-20-38-160.ap-south-1.compute.internal               1/1       Running   0          13m
kube-apiserver-ip-172-20-38-160.ap-south-1.compute.internal            1/1       Running   0          14m
kube-controller-manager-ip-172-20-38-160.ap-south-1.compute.internal   1/1       Running   0          14m
kube-dns-782804071-6j969                                               4/4       Running   0          14m
kube-dns-782804071-fgj47                                               4/4       Running   0          12m
kube-dns-autoscaler-2813114833-d5t21                                   1/1       Running   0          14m
kube-proxy-ip-172-20-38-160.ap-south-1.compute.internal                1/1       Running   0          14m
kube-proxy-ip-172-20-55-64.ap-south-1.compute.internal                 1/1       Running   0          12m
kube-scheduler-ip-172-20-38-160.ap-south-1.compute.internal            1/1       Running   0          14m
weave-net-bm41b                                                        2/2       Running   1          13m
weave-net-jdv4d                                                        2/2       Running   0          13m
```
 
# Login into the cluster

* Get the admin credentials
```
cat ~/.kube/config | grep -i username | head -n 1
cat ~/.kube/config | grep -i password | head -n 1
```
* Run the dashboard
```
kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
```
* Login into the running dashboard using admin credentials
```
https://api.dev1.simpledatalabs.io/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/#/persistentvolume?namespace=_all
```

# OneTime

## Install kops, jq

```
 brew install kops
 brew install jq
```

## Create KOPS aws account with following privileges

kops_user.txt has the details of the created account

* AmazonEC2FullAccess
* AmazonRoute53FullAccess
* AmazonS3FullAccess
* IAMFullAccess
* AmazonVPCFullAccess

## Create S3 bucket for kops

```
aws s3api create-bucket --bucket simpledatalabs-io-state-store --region us-east-1
aws s3api put-bucket-versioning --bucket simpledatalabs-io-state-store  --versioning-configuration Status=Enabled --region us-east-1
```

## Create sub-domain in Route53
```
$ ID=$(uuidgen) && aws route53 create-hosted-zone --name simpledatalabs.io --caller-reference $ID | jq .DelegationSet.NameServers
[
  "ns-1570.awsdns-04.co.uk",
  "ns-49.awsdns-06.com",
  "ns-571.awsdns-07.net",
  "ns-1029.awsdns-00.org"
]

```

## Check DNS works
```
Rajs-MBP:terraform rajbains$ dig ns simpledatalabs.io

; <<>> DiG 9.8.3-P1 <<>> ns simpledatalabs.io
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 52543
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;simpledatalabs.io.             IN      NS

;; ANSWER SECTION:
simpledatalabs.io.      85480   IN      NS      ns-1029.awsdns-00.org.
simpledatalabs.io.      85480   IN      NS      ns-49.awsdns-06.com.
simpledatalabs.io.      85480   IN      NS      ns-571.awsdns-07.net.
simpledatalabs.io.      85480   IN      NS      ns-1570.awsdns-04.co.uk.

;; Query time: 17 msec
;; SERVER: 103.8.44.5#53(103.8.44.5)
;; WHEN: Thu Mar  9 11:58:41 2017
;; MSG SIZE  rcvd: 174
```

## Ensure that terraform writes to your own state store instead of local disk

## Create S3 bucket for kops
```
aws s3api create-bucket --bucket simpledatalabs-io-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket simpledatalabs-io-terraform-state  --versioning-configuration Status=Enabled --region us-east-1

$ terraform remote config \
  -backend=s3 \
  -backend-config="bucket=simpledatalabs-io-terraform-state" \
  -backend-config="key=infrastructure.tfstate" \
  -backend-config="region=us-east-1"
```