# Skapa cluster-struktur med appar, helmfile och values
mkdir -p clusters/{dev,test,prod}/apps/{myservice,otherservice}
mkdir -p clusters/{dev,test,prod}/infra

for env in dev test prod; do
  for app in myservice otherservice; do
    touch clusters/$env/apps/$app/kustomization.yaml
    touch clusters/$env/apps/$app/helmfile.yaml
    touch clusters/$env/apps/$app/values-$env.yaml
  done
done

# Skapa apps-mapp med chart, base och overlays
mkdir -p apps/{myservice,otherservice}/{chart,base,overlays}

# Skapa platform och infra
mkdir -p platform
mkdir -p infra
