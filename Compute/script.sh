#!/bin/bash

## get necessary certificates and keys
sudo apt-get install  -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -


## install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

## install kubectl and configuring permissions for GKE cluster
sudo apt-get install kubectl
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
## authentication for artifact registry
sudo gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin  us-central1-docker.pkg.dev

## pull the mongodb image from dockerhub ,rename and push again to artifact registry
sudo docker pull mongo
sudo docker pull abdallaabdelsalam/nodejs
sudo docker tag mongo us-central1-docker.pkg.dev/abdallahmahdy/images-repository/mongo
sudo docker tag abdallaabdelsalam/nodejs us-central1-docker.pkg.dev/abdallahmahdy/images-repository/nodejs
sudo docker push us-central1-docker.pkg.dev/abdallahmahdy/images-repository/mongo
sudo docker push us-central1-docker.pkg.dev/abdallahmahdy/images-repository/nodejs

