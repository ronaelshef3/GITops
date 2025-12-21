# GITops: ArgoCD Deployment and Infrastructure on Kind

This repository is the Single Source of Truth for our environment. It manages the whole קלאסטר using ArgoCD logic and Helm charts.

## Local Setup on Kind
The installation scripts in this repo are specially build to setup a local environment on Kind (Kubernetes in Docker). This allows you to test the whole פייפליין on your machine before going to the cloud.

1. First, make sure your Kind קלאסטר is running.
2. Run the installation script:
   .\installArgo.ps1 
   * This script creates the 'argocd' namespace.
   * It installs the stable ArgoCD manifests.
   * It waits for the פודים to be ready and starts a port-forward to https://localhost:8080.
3. Get your admin password:
   .\pass.ps1
   * This decodes the initial secret so you can login to the UI.

## The ArgoCD Application (argocd.yaml)
We use the 'Application' resource to manage the QuakeWatch דפלויימנט:
* Project: default.
* Source: It points to our GITops repo and the 'my-app-chart' folder.
* Destination: It deploys everything into 'my-app-namespace'.
* Sync Policy: We use automated sync with selfHeal and prune. If you change something manually in the קלאסטר, ArgoCD will fix it back to what is written in Git.
* Sync Waves: The app is set to wave "1" so it wait for the CRDs and base monitoring to be ready.

## The Automation Flow (Push -> Docker -> Argo)
Every time you push code to the App repo, the following happens:
* A new Docker version is build and pushed to the registry with a dynamic tag like v0.25.
* At the same time, the פייפליין updates the 'image.tag' here in the values.yaml file.
* ArgoCD is "sensitive" to any change in this repo. Once it sees the new tag in Git, it automatically renders the new manifests and syncs the running app to the new version.

## Helm Chart and Manifests (my-app-chart)
Inside the templates folder we manage all the K8s objects:
* deployment.yaml: The main logic with HPA and probes.
* service.yaml: Exposed on NodePort 30080.
* ingress.yaml & httproute.yaml: For traffic routing.
* service-monitor.yaml: For the monitoring stack.
* hpa.yaml: For automatic scaling.

## Monitoring with Prometheus
We also deploy a monitoring stack:
* kube-prometheus-stack: Managed via ArgoCD.
* Scraping: The app has annotations so Prometheus pull מטריקות from port 5000.

## Monitring Stack
Inside the קלאסטר, we also deploy the monitoring tools:
* kube-prometheus-stack: Managed as an Argo application.
* Metrics Scraping: The application pods have annotations in the values.yaml so Prometheus can collect מטריקות from port 5000.

## Project Structure (Only Source)
GITops/
├── my-app-chart/            # Helm chart for the app

│   ├── templates/           # K8s manifests

|    |--deployment.yaml      # Deployment with HPA and Probes

│   ├── service.yaml         # Service exposed on NodePort 30080

│   └── service-monitor.yaml # Integration for prometheus


│   ├── values.yaml          # Standard config

│   └── values_prod.yaml     # Prod scale (10 replicas)

├── argocd.yaml              # ArgoCD App definition

├── pomitius.yaml            # Prometheus setup

├── installArgo.ps1          # Kind installation script

└── pass.ps1                 # Password tool

## Troubleshooting the Deployment
[