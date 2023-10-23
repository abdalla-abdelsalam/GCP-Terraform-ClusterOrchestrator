
## clone my repo to deploy the mongodb 
sudo git clone https://github.com/abdalla-abdelsalam/app-yaml-files
sudo openssl rand -base64 756 > ${PWD}/key
sudo chmod 600 key
gcloud container clusters get-credentials private-cluster --location asia-east1-a
cd app-yaml-files
kubectl create secret generic mongodb-keyfile --from-file=../key
kubectl apply -f config-map.yaml
kubectl apply -f gcp-storage-class.yaml
kubectl apply -f headless-service.yaml
kubectl apply -f mongo-secret.yaml
kubectl apply -f load-balancer.yaml
kubectl apply -f statefulset-before.yaml
kubectl apply -f app-config.yaml
kubectl apply -f app-secret.yaml


## initialise the mongodb replication set
#kubectl apply -f statefulset-after.yaml
# kubectl exec -it mongodb-0 -- mongosh
# db.createUser({
#   user: "user",
#   pwd: "password",
#   roles: [
#     { role: "readWrite", db: "test" }
#   ]
# })
# use admin;
# db.createUser({
#   user: "adminUsername",
#   pwd: "adminPassword",
#   roles: ["root"]
# })
# # exit
# kubectl apply -f statefulset-after.yaml
# kubectl exec -it mongodb-0 -- mongosh --username adminUsername --password adminPassword --authenticationDatabase admin 
# rs.initiate(
#   {
#     _id: "rs0",  // Specify the replica set name (replace "rs0" with your desired name).
#     members: [
#       { _id: 0, host: "mongodb-0.mongodb:27017" },  // Replace with the correct hostname and port.
#       { _id: 1, host: "mongodb-1.mongodb:27017" },  // Replace with the correct hostname and port.
#       { _id: 2, host: "mongodb-2.mongodb:27017" }   // Replace with the correct hostname and port.
#     ]
#   }
# )