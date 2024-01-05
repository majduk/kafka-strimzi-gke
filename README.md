# Kafka deployment using Strimzi Operator

## GCP Project
Sample Terraform code to create GCP project with needed services enabled and Service Accouints created can be found in [gcp-project](./gcp-project).

After configuring `terraform.tfvars` using [sample](./gcp-project/terraform.tfvars.sample) provided, create the project:
```
cd gcp-project
./generate_provider.py
terraform init
terraform apply
```
## GKE cluster
Sample code to create an Autoppilot cluster is in [gke-autopilot](./gke-autopilot).

After configuring `terraform.tfvars` using sample provided, create the GKE cluster:
```
cd gke-autopilot
./generate_provider.py
terraform init
terraform apply -var-file terraform.tfvars.json
```
Make sure you can connect to the cluster:
```
gcloud container clusters get-credentials my-cluster --region us-central1
```

## Strimzi Operator
Deploy the Strimzi operator using a Helm chart:
```
helm repo add strimzi https://strimzi.io/charts/
kubectl create ns kafka
helm install strimzi-operator strimzi/strimzi-kafka-operator -n kafka
```
Check the deployment status:
```
helm ls -n kafka
```

## Deploy Kafka using Strimzi
Strimzi adds some CDRs to make cluster management. Using those makes the deployment process rather straightforward:
```
kubectl apply -n kafka -f strimzi/01-basic-cluster.yaml
kubectl apply -n kafka -f strimzi/03-auth-cluster.yaml
kubectl apply -n kafka -f strimzi/03-auth-topic.yaml
kubectl apply -n kafka -f strimzi/03-auth-my-user.yaml
``` 

Cluster exposes 3 bootstrap endpoints:
- my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092 - plaintext without authentication
- my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9093 - SSL
- my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9094 - SASL_SSL

## Testing
There is a sample kcat image that can be used to test. first deploy it:
```
kubectl apply -n kafka -f kafka-clients/kafkacat.yaml
```
Secondly:
```
kubectl exec -it kafkacat -n kafka -- /bin/sh
echo "Message from my-user" |kcat \
  -b my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9094 \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=SCRAM-SHA-512 \
  -X sasl.username=my-user \
  -X sasl.password=$(cat /my-user/password) \
  -t my-topic -P
kcat -b my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9094 \
  -X security.protocol=SASL_SSL \
  -X sasl.mechanisms=SCRAM-SHA-512 \
  -X sasl.username=my-user \
  -X sasl.password=$(cat /my-user/password) \
  -t my-topic -C
```
**Note:**
kcat ignores the selfsigned SSL certificate.

## Exposing cluster
In order to expose the cluster use loadbalancer.
```
kubectl apply -n kafka -f strimzi/04-expose-cluster.yaml
```

You can test the configuration:
```
BOOTSTRAP_IP=$(kubectl -n kafka get svc my-cluster-kafka-external-bootstrap -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
bin/kafka-console-producer.sh --broker-list ${BOOTSTRAP_IP}:9095 --producer.config client.properties --topic my-topic
```

## Client configuration
To connect to the cluster using CLI or Java clients you need to create an SSL truststore and SASL configuration.

Let's start with SSL. First, get CA certificate:
```
cd kafka-clients
./gke_get_cacert.sh
```
Then create the truststore:
```
./build_truststore.sh
```
Create truststore and client config secrets:
```
./build_client_config.sh
```
**Note**
- This stores some information in plaintext. There is a better way to do it and the above is for examplar purposes.
- To disable server certificate check in case of loadbalancer passthrough add `ssl.endpoint.identification.algorithm=` to client.properties

Test the configuration:
```
kubectl apply -n kafka -f kafkaproducer.yaml
kubectl apply -n kafka -f kafkaconsumer.yaml
```
Producer:
```
kubectl exec -it kafkaproducer -n kafka -- /bin/sh
/opt/kafka/bin/kafka-console-producer.sh --broker-list my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9094 \
--producer.config /home/kafka/config/client.properties \
--topic my-topic
```
Consumer:
```
kubectl exec -it kafkaconsumer -n kafka -- /bin/sh
/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9094 \
--consumer.config /home/kafka/config/client.properties \
--topic my-topic \
--group my-group \
--from-beginning
```

## References
- [GKE docs](https://cloud.google.com/kubernetes-engine/docs/tutorials/apache-kafka-strimzi)
