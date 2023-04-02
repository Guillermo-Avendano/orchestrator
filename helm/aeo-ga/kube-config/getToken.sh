#!/bin/sh
TOKEN=$(microk8s.kubectl describe secret default-token | grep -E '^token' | cut -f2 -d':' | tr -d " ")
echo $TOKEN
