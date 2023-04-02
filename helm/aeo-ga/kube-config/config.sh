kubectl apply -f ./clusterRole-api.yaml
kubectl create clusterrolebinding api-permissions --clusterrole api-permissions --serviceaccount=default:default
kubectl apply -f ./secret-defaultToken.yaml