#!/bin/bash

backup_pods=$(kubectl get pods --selector "backup.kubernetes.io/backup-to-s3-enabled=True,app=$APP" --all-namespaces --label-columns 'app.kubernetes.io/component' --output json | jq '.items[].metadata | "\(.namespace),\(.name)"' -r)

for pod_details in $backup_pods
do
  IFS=','
  read -ra INFO <<< "$pod_details"
  namespace="${INFO[0]}"
  pod="${INFO[1]}"
  mkdir -p backups/$pod
  echo "Backing up '${namespace}\\${pod}'."
  kubectl exec -n $namespace $pod -- tar cvzf - $BACKUP_LOCATION | tar xvzf - -C backups/$pod
  mv backups/$pod$BACKUP_LOCATION backups/$pod
  tar cvzf backups/$pod-`date +%F`.tar.gz backups/$pod/content/
  s3cmd put backups/$pod-`date +%F`.tar.gz s3://$S3_BUCKET/backups/$namespace/
  IFS=' '
done

rm -rf backups