# AI-Augmented Delivery Pipeline

This repository demonstrates a resilient, declarative CI/CD pipeline built to aggressively protect production environments from degraded releases. 

Rather than relying on manual QA sign-offs, this pipeline integrates active anomaly-based health checks. Immediately following a deployment, Jenkins runs an automated evaluation script that queries Prometheus for statistical deviations in the application's HTTP error rates. If the metrics breach acceptable thresholds, Jenkins instantly triggers a `helm rollback`, reverting the cluster to the last stable release and alerting the engineering team.

## Development Methodology

* **GitHub Copilot & LLM Tooling:** The repetitive boilerplate for the Terraform modules (IAM, S3) and Helm charts was rapidly prototyped using GitHub Copilot, significantly accelerating the initial infrastructure-as-code scaffolding.
* **Jenkins Declarative Pipeline:** Orchestrates the multi-stage deployment and the `post { failure }` rollback loop.
* **Prometheus Integration:** Acts as the quantitative judge for deployment success by measuring live traffic error rates.

## Usage

1. **Configure Credentials:** Ensure Jenkins has the `eks-kubeconfig` credential loaded to authenticate with the target cluster.
2. **Execute Pipeline:** Trigger the Jenkins job. The pipeline will:
   * Apply necessary Terraform dependencies.
   * Upgrade the Helm release.
   * Pause to allow traffic generation.
   * Execute `scripts/anomaly_health_check.sh` to query Prometheus.
3. **Observe Rollback:** To test the safety net, deploy an intentionally broken container image. The health check script will detect the resulting 5xx errors and trigger the automated Helm rollback.
