# Terraform — GCP Test Environment (Complete Resource Specification)

This README documents the complete, production-grade Terraform design for the Test environment described in the architecture sheet. It lists every resource, exact configuration, network allocations, sizes, OS choices, security considerations, IAM bindings and other operational details. Use this as the single source-of-truth for requirements before implementing the Terraform modules in terraform/.

WARNING: This file is a detailed design and contains IP/CIDR choices and default sizes. Validate ranges against your organisation's IP plan before applying.

---

Table of contents
- Overview & purpose
- Global settings (provider, project, region, zones)
- Networking (VPC, subnets, private service networking, firewalls)
- Cloud SQL (Postgres) — full spec
- GKE cluster & node pool — full spec
- OAM server VM — full spec
- Shared storage (preferred: Filestore; alternative: GCS)
- Load Balancer & DNS — full spec
- Cloud Operations (monitoring, logging, Prometheus)
- Snapshot schedule (disks)
- Modules mapping
- Variables & outputs (summary)
- Backend (remote state) config
- How to initialize / plan / apply
- Architecture diagram (Mermaid)
- Change log

---

1) Overview & Purpose
- Environment: test
- Goal: Private, secure, regional GKE cluster with private Cloud SQL (Postgres HA), an OAM VM in the private subnet, shared storage, global HTTP(S) LB for GKE ingress with managed SSL, Cloud DNS and Cloud Operations integrated. Use modules, least-privilege IAM and remote state.

2) Global settings (defaults)
- GCP Project: variable: var.project_id (example default: test-project-123)
- Organization / Folder: set externally (not in this README)
- Region (primary): us-central1 (changeable via var.region)
- GKE cluster location type: regional (us-central1)
- Zones used (regional cluster): us-central1-a, us-central1-b, us-central1-c
- Terraform version: 1.6+ (use >=1.6 in versions.tf)
- Providers: google v>=4.x (use latest stable that supports resources used)
- Labels / tags: each resource gets labels: env=test, owner=${var.owner}, project=${var.project_id}
- Naming convention prefix: var.prefix (default: test)

3) Networking (VPC + subnets + private service networking)
- VPC
  - Name: test-vpc
  - Auto mode: disabled (custom)
  - Primary CIDR: 10.0.0.0/16
  - Flow logs: enabled on subnets (configurable)
  - Shared VPC: not enabled by default; can be adapted to host project
  - Purpose: host GKE, compute, DB, Filestore internal networks

- Subnets (regional: us-central1)
  - Subnet: test-subnet-gke
    - CIDR: 10.0.2.0/22 (1024 addresses) — used for GKE nodes/pods service IP allocation separation
    - Purpose: GKE node VM NICs (private cluster nodes)
    - Private Google Access: enabled
  - Subnet: test-subnet-compute
    - CIDR: 10.0.1.0/24 — compute VMs (OAM)
    - Purpose: OAM server VM (private)
    - Private Google Access: enabled
  - Subnet: test-subnet-db
    - CIDR: 10.0.3.0/28 — reserved small block for Cloud SQL private IP allocation + peering
    - Purpose: Cloud SQL private IP allocation range and private service connection
  - Peered range for Private Service Connect (Cloud SQL): 10.1.0.0/28 — reserved for private services (var.sql_private_range)
    - This range will be allocated via google_service_networking_connection for private service networking

- IP allocations (examples)
  - VPC primary: 10.0.0.0/16
  - GKE pod CIDR (secondary range): 10.4.0.0/14 (for pods across cluster)
  - GKE service CIDR (secondary): 10.8.0.0/20 (services)
  - Cloud SQL private IP: assigned from 10.0.3.0/28 after peering (e.g., 10.0.3.2)
  - Filestore IP: allocated from test-subnet-gke or test-subnet-compute (e.g., 10.0.2.10)

- Private Service Networking
  - Enable google_service_networking_connection to connect servicenetworking.googleapis.com and allocate var.sql_private_range (default 10.1.0.0/28)
  - Required for Cloud SQL private IP.

- Firewall rules
  - fw-allow-ssh-oam
    - Source ranges: var.oam_ssh_source_cidrs (default: ["203.0.113.0/32"] — replace with your office/bastion IP)
    - Target tags: oam-server
    - Ports: tcp:22
    - Purpose: restrict SSH to OAM server only
  - fw-gke-master-to-nodes
    - Source: GKE control plane CIDR (managed) — allow control plane → node traffic for necessary ports (TCP 10250, 443 etc.)
    - Use google_container_cluster's master_authorized_networks / private cluster options and GKE-managed firewall rules where possible
  - fw-lb-healthchecks
    - Source ranges: 130.211.0.0/22 and 35.191.0.0/16 (GCP LB health check ranges)
    - Ports: tcp:<health-check-port> (default 80/443)
  - fw-db-access-from-gke
    - Source ranges: GKE nodes' subnet (test-subnet-gke CIDR)
    - Target: Cloud SQL private IP (via network policy / authorized networks not required for private IP)
    - Ports: tcp:5432
    - Purpose: restrict DB access to GKE nodes only
  - fw-internal-icmp & fw-internal-all
    - Allow internal traffic between subnets (establish connectivity for operations, health checks, filestore)

4) Cloud SQL — PostgreSQL (full spec)
- Resource: google_sql_database_instance (high availability)
- Name: test-sql-postgres
- Region: us-central1 (regional instance for HA)
- HA (High Availability): enabled — regional HA (failover to standby instance in another zone)
- Machine / Instance tier: custom to meet memory requirement
  - vCPU: default (customize via var.sql_vcpu — default 2)
  - Memory: 15 GB → set machine type db-custom-2-15360 (2 vCPU, 15360 MB RAM) OR adjust variable to db-custom-4-15360 if more vCPU needed
  - Note: Terraform variable var.sql_db_machine (default "db-custom-2-15360")
- Storage
  - Storage type: SSD (pd-ssd)
  - Size: 200 GB (var.sql_storage_gb = 200)
  - Storage auto-extension: enabled (autoscaling)
- Backups & Recovery
  - Automated backups: enabled (daily window configurable)
  - Point-in-time recovery (PITR): enabled (binlog / point-in-time restore)
  - Backup retention: var.sql_backup_retention_days (default 7)
- Connectivity
  - Public IP: disabled
  - Private IP: enabled — uses service networking and allocated range var.sql_private_range
- Users & DB
  - Primary DB created: var.sql_database_name (default "appdb")
  - Admin user: created via Cloud SQL (use secure secret manager or terraform sensitive var for password)
  - Additional users: created per var.sql_users map (usernames + passwords)
- IAM
  - Workload Identity: Add IAM binding allowing GKE Workload Identity service account (KSA mapped to GCP SA) to access Cloud SQL via Cloud SQL Client role (roles/cloudsql.client) only
  - Grant principle: serviceAccount:${var.gke_workload_identity_gsa}
- Maintenance
  - Maintenance window scheduled off-hours (var.sql_maintenance_window)
  - Database flags: set as needed (e.g., log_statement = 'all' only if required)

5) GKE Cluster — Regional Private Cluster
- Cluster resource: google_container_cluster (or use terraform-google-modules/kubernetes-engine/google)
- Name: test-gke-cluster
- Location type: regional (us-central1)
- Network & subnetwork: VPC test-vpc and test-subnet-gke
- Private cluster: enabled
  - private_cluster_config: enable private endpoint (no public endpoint), master authorized networks optionally enabled for admin CIDRs
- Node Pools
  - Node pool resource uses module nodepool (see nodepool section)
  - Node pool name: worker-pool-1
  - Node count (initial): 3 (var.node_count = 3)
  - Minimum nodes (autoscaler): 1
  - Maximum nodes (autoscaler): 6 (var.node_pool_max = 6)
  - Autoscaling: enabled
  - Machine type: n2-standard-8
    - vCPU: 8
    - Memory: 32 GB
  - Boot disk
    - Size: 500 GB (var.node_boot_disk_gb = 500)
    - Type: pd-ssd
  - OS image
    - RHEL-based container-optimized image (var.node_image: "rhel-8-container-optimized" or GKE supported RHEL container image)
    - If RHEL license required, enable license/terms and set image type accordingly (ensure project has RHEL subscriptions)
  - Node pool HA: nodes distributed across regional zones: us-central1-a,b,c
  - Node pool autoscaler: enabled (min and max as above)
  - Node metadata: enable block-project-ssh-keys = true (enforce SSH via bastion)
  - Node pool IAM: node service account with least privileges (node SA with roles/container.nodeServiceAccount, roles/logging.logWriter, roles/monitoring.metricWriter, roles/monitoring.viewer as needed)
- Cluster features
  - Workload Identity: enabled (recommended)
  - Pod CIDR secondary ranges:
    - pods: 10.4.0.0/14
    - services: 10.8.0.0/20
  - Cloud Operations (Cloud Monitoring + Logging): enabled (enable_stackdriver=true)
  - Private endpoint: master endpoint accessible only via private IP or authorized networks
  - GKE Autopilot: not used — standard GKE

6) GKE Node pool details (module: nodepool)
- module will create:
  - Managed Instance Group(s) for node pool
  - Instance template using n2-standard-8, disk size 500GB, image RHEL container image
  - Preemptible: false (not preemptible)
  - Node labels: k8s-node-role=worker, env=test
  - Node taints: none by default (configurable)
  - Autoscaling: enabled (Cluster Autoscaler)
  - Upgrade strategy: surge upgrades with safe defaults
  - Disk snapshot schedule: resource policy applied to boot disks (see snapshots section)

7) OAM Server (VM) — Repo, Prometheus, CD server
- Resource: google_compute_instance
- Name: test-oam-server
- Zone: us-central1-b (one of cluster zones)
- Machine type: n2-standard-16
  - vCPU: 16
  - Memory: 64 GB
- Boot disk:
  - OS: RHEL 8 (rhel-8 image family / project: rhel-cloud)
  - Size: 150 GB (boot); provide main application data disk separate — see below
- Data disk (attached persistent disk)
  - Size: 1500 GB (1.5 TB)
  - Type: pd-ssd (or pd-balanced if cost optimization desired)
  - Auto-delete: false
  - Snapshot schedule: attached to snapshot policy daily with 7 days retention (resource policy)
- Network
  - NIC: attached to test-subnet-compute (private)
  - No external IP (private only)
  - Access via bastion / VPN / Cloud IAP SSH (recommend IAP)
- Startup Script
  - Provisioning: cloud-init / metadata startup script to install:
    - basic packages (git, docker, jq, monitoring agent)
    - Docker runtime / container runtime suitable for CD/CI
    - Register Prometheus node exporter if needed
  - Script stored in module variable var.oam_startup_script or pulled from GCS
- Tags: oam-server, monitoring-enabled
- IAM
  - Service Account: dedicated VM service account with least privilege for required APIs (storage access to push logs or artifacts, compute read for snapshot ops as needed)

8) Shared Storage (preferred: Filestore) — 500 GB
Preferred: Filestore (NFS) for POSIX filesystem
- Filestore instance (tier: standard or enterprise depending performance)
  - Name: test-filestore
  - Tier: STANDARD (or HIGH_SCALE depending on throughput need)
  - Capacity: 500 GB
  - Region/Zone: us-central1 (select same region as GKE)
  - Network: VPC test-vpc and reserved IP (e.g., 10.0.2.10)
  - Mount: NFS export path (e.g., /vol1)
  - Access control: export policies restrict to test-subnet-gke, test-subnet-compute
  - Use-case: shared storage for OAM, Prometheus remote write, or legacy apps

Alternative: GCS bucket with versioning (if NFS not required)
- GCS bucket: test-shared-storage
  - Versioning: enabled
  - Uniform bucket-level access: enabled
  - Lifecycle: expire object non-current versions after 30 days (configurable)
  - Access: via IAM (principals only), not publicly accessible

9) Load Balancer — Global HTTP(S) Load Balancer (GKE Ingress)
- Type: Global external HTTP(S) load balancer using GKE Ingress and NEG backend
- Frontend
  - IPv4 global static IP: Reserve address var.lb_ip_name (e.g., test-lb-ip)
  - IPv6: not configured by default
  - Protocols: HTTP & HTTPS
  - SSL: Google Managed SSL Certificate (managed)
    - Certificate resource: google_compute_managed_ssl_certificate (or use GKE ingress-managed cert)
    - Domains: var.lb_domains (example: app.test.example.com)
- Backend
  - Backend service: referencing Kubernetes NEG (Network Endpoint Groups) created by GKE Ingress
  - Health checks: HTTP/HTTPS health check (path: /healthz or configurable)
  - Session affinity: none by default
  - Connection draining / timeout: configured per traffic profile
- Security
  - Enable Cloud Armor (optional) with a default deny/allow policies if required
- DNS
  - A record created pointing domain to the reserved global LB IP

10) Cloud DNS
- Managed zone: test-public-zone (public) or private zone for internal records
  - DNS zone: example.com. (change via var.dns_zone)
- Records
  - A record: app.test.example.com -> LB external IP
  - Internal records (private zone) for internal services:
    - db.internal.test.example.com -> Cloud SQL private IP
    - oam.internal.test.example.com -> OAM VM internal IP
    - filestore.internal.test.example.com -> Filestore IP
- TTLs: default 300s

11) Cloud Operations (Monitoring + Logging)
- Enable APIs: monitoring.googleapis.com and logging.googleapis.com
- Logging
  - Cloud Logging enabled for GKE, VM, Cloud SQL
  - Log sinks
    - Sink to BigQuery for audit logs (optional)
    - Sink to GCS for long-term log archive
  - IAM for sinks: use service accounts with least privilege
- Monitoring
  - Enable builtin dashboards for GKE and Cloud SQL
  - Create custom dashboards (module) for node resource usage, DB metrics, OAM server metrics
  - Alerting
    - Alert policy: node CPU > 85% sustained 5m
    - DB storage utilization > 80%
    - LB 5xx error rate > threshold
    - Disk snapshot failures
- Prometheus
  - Prometheus running on GKE (operator or kube-prometheus-stack)
  - Prometheus scraper config: scrape kubelets, cAdvisor, pod metrics (prometheus-operator)
  - Remote write to Stackdriver if needed (or use Managed Service for Prometheus)
- IAM
  - Monitoring service account for GKE workloads created with restricted roles (roles/monitoring.metricWriter, roles/logging.logWriter)

12) Snapshot schedule (compute disk snapshots nightly, 7 days retention)
- Resource: google_compute_resource_policy (snapshot schedule policy)
  - Frequency: daily
  - Time window: var.snapshot_time (default 03:00)
  - Retention: 7 days
- Apply to disks
  - OAM VM data disk attached to test-oam-server
  - GKE node boot disks:
    - Use resourcePolicy or use an instance template with attached resource policy to schedule snapshots for MIGs (node pool disks). Note: snapshot scheduling for node boot disks is supported by resource policies attached to disk resources or via instance template disk settings
- Snapshot label/tagging: env=test, snapshot-policy=daily-7

13) IAM & Least Privilege (summary)
- Service accounts created
  - gke-node-sa: roles required: roles/logging.logWriter, roles/monitoring.metricWriter, roles/stackdriver.resourceMetadata.writer, roles/iam.serviceAccountUser only if needed
  - gke-workload-sa (GCP SA): bound to Kubernetes KSA via Workload Identity and granted roles/cloudsql.client for DB access
  - oam-vm-sa: minimal roles for storage access (roles/storage.objectViewer/Creator as required)
  - sql-sa: Cloud SQL admin access only to manage instance (if required). Prefer to manage SQL via infra pipeline not runtime.
- IAM Bindings
  - Cloud SQL: roles/cloudsql.client to gke-workload-identity SA only
  - Cloud DNS: managed zone owner to DNS admin SA for automation (roles/dns.admin) — minimize to specific SA
  - LB: run as user with roles/compute.networkAdmin or use terraform service account with compute.networkAdmin limited to resource creation scope
- Principle of least privilege enforced via module defaults

14) Modules mapping (terraform/modules)
- modules/vpc — implements VPC, subnets, private service networking, firewall rules
- modules/gke — implements GKE cluster (private, regional) and Workload Identity
- modules/nodepool — implements node pool(s) with autoscaler, disk configs and labels
- modules/sql — implements Cloud SQL Postgres HA instance, users, DB, private IP — uses terraform-google-modules/sql-db module if desired
- modules/vm — implements OAM server VM with attached data disk and startup script
- modules/storage — implements Filestore and/or GCS bucket with lifecycle and versioning
- modules/lb — configures global HTTP(S) LB, static IP and SSL certs, integrates with GKE Ingress/NEG
- modules/dns — cloud DNS managed zones and records
- modules/monitoring — creates dashboards, alert policies, log sinks, Prometheus integration config
- modules/snapshots — resource policies for snapshots and attachment to disks

15) Terraform backend (remote state)
- Backend: GCS
  - bucket: var.tfstate_bucket (example: test-terraform-state)
  - prefix: environments/test/terraform.tfstate
  - Enable object versioning on bucket
  - IAM: terraform SA must have roles/storage.objectAdmin on the bucket
  - State locking: achieved through GCS object metadata and storage - gcs does not provide strong locking by itself; best practice: use Terraform Cloud or use Google Cloud Storage with state locking via google backend + use consistency with service account. (GCS provides optimistic concurrency using generation numbers)
- Example backend configuration: environments/test/backend.tf (see repo)

16) Variables (selected defaults)
- var.project_id = "test-project-123"
- var.region = "us-central1"
- var.zones = ["us-central1-a","us-central1-b","us-central1-c"]
- var.prefix = "test"
- var.owner = "infrastructure-team@example.com"
- var.vpc_cidr = "10.0.0.0/16"
- var.subnet_gke_cidr = "10.0.2.0/22"
- var.subnet_compute_cidr = "10.0.1.0/24"
- var.subnet_db_cidr = "10.0.3.0/28"
- var.sql_private_range = "10.1.0.0/28"
- var.pod_cidr = "10.4.0.0/14"
- var.service_cidr = "10.8.0.0/20"
- var.sql_db_machine = "db-custom-2-15360"
- var.sql_storage_gb = 200
- var.node_count = 3
- var.node_boot_disk_gb = 500
- var.node_machine_type = "n2-standard-8"
- var.oam_machine_type = "n2-standard-16"
- var.oam_data_disk_gb = 1500
- var.filestore_size_gb = 500
- var.lb_domains = ["app.test.example.com"]
- var.tfstate_bucket = "test-terraform-state"
- All variables have sensible defaults; override via environments/test/terraform.tfvars

17) Outputs (summary of key outputs)
- output.cluster_name
- output.cluster_endpoint (internal/private endpoint)
- output.kubeconfig (or instructions to retrieve via gcloud)
- output.gke_master_private_ip
- output.gke_node_pool_ids
- output.sql_instance_name
- output.sql_private_ip
- output.sql_connection_name
- output.oam_instance_id
- output.oam_internal_ip
- output.filestore_ip
- output.lb_ipv4_address
- output.dns_zone_name

18) How to initialize / plan / apply
- Prereqs:
  - Install Terraform 1.6+
  - Install gcloud and authenticate: gcloud auth application-default login
  - Set project: gcloud config set project ${PROJECT_ID}
  - Ensure APIs enabled: container.googleapis.com, sqladmin.googleapis.com, compute.googleapis.com, monitoring.googleapis.com, servicemanagement.googleapis.com, servicemanagement.googleapis.com, servicenetworking.googleapis.com, filestore.googleapis.com, dns.googleapis.com
- Example commands (Windows PowerShell / cmd)
  - cd c:\Users\Sathishkumar.KATHIRV\OneDrive - HR365\Desktop\tf\terraform\environments\test
  - terraform init
  - terraform plan -var-file="terraform.tfvars"
  - terraform apply -var-file="terraform.tfvars"
- Backend: configure environments/test/backend.tf with your tfstate bucket and prefix before terraform init
- Sensitive values (DB passwords) should be passed via environment variables or secret manager referenced by Terraform

19) Security & Operational Notes
- No public IPs: GKE control plane & nodes are private, Cloud SQL is private, OAM VM has no external IP.
- SSH access: use Bastion or Cloud IAP; restricted only to var.oam_ssh_source_cidrs.
- RHEL images may require license acceptance and subscription—confirm with your subscription and GCP marketplace usage.
- Workload Identity is mandatory for Cloud SQL access from GKE — do NOT embed DB credentials in pods; use IAM + Cloud SQL Auth Proxy where needed.
- Backups: you must test point-in-time recovery (PITR) periodically.
- Snapshot retention: 7 days; modify as per policy.
- Filestore performance and tier should be chosen after workload profiling.

20) Architecture diagram (Mermaid)
```mermaid
flowchart LR
  subgraph VPC[ VPC: test-vpc (10.0.0.0/16) ]
    subgraph GKE_SUBNET[ GKE Subnet 10.0.2.0/22 ]
      GKE[GKE Regional Cluster (private)]
      FIL[Filestore (10.0.2.10)]
    end
    subgraph COMPUTE_SUBNET[ Compute Subnet 10.0.1.0/24 ]
      OAM[OAM Server VM (n2-std-16, 1.5TB data)]
    end
    subgraph DB_SUBNET[ DB Subnet 10.0.3.0/28 ]
      SQL[Cloud SQL Postgres (private IP)]
    end
  end

  Internet --> LB[Global HTTP(S) Load Balancer (managed cert)]
  LB -->|NEG| GKE
  DNS((Cloud DNS)) --> LB
  GKE --> SQL
  OAM --> SQL
  GKE --> FIL
  OAM --> FIL
  Monitoring[Cloud Operations] --> GKE
  Monitoring --> OAM
  Monitoring --> SQL
```

21) Change log & next steps
- This README provides concrete defaults. Before apply:
  - Replace placeholder domain names and IPs (oam_ssh_source_cidrs, lb_domains).
  - Confirm RHEL licensing & image names in your GCP account.
  - Ensure APIs are enabled and service account for Terraform has required roles (project IAM).
  - Review subnet CIDRs against global IP plan to avoid collisions.

---

If you want, I can now:
- Generate the full terraform code for all modules and environment files in the requested folder structure (terraform/modules/* and terraform/environments/test/*).
- Or produce just the environments/test/backend.tf, main.tf and variables.tf wiring the modules.

Please confirm whether to:
1) Generate full module implementations now (this will be lengthy, I will create all files under the folder), or
2) Only generate environment wiring and backend (you will implement modules), or
3) Make any change to IP ranges / machine sizes / region defaults before code generation.

// filepath: c:\Users\Sathishkumar.KATHIRV\OneDrive - HR365\Desktop\tf\terraform\README.md
# Terraform — GCP Test Environment (Complete Resource Specification)

This README documents the complete, production-grade Terraform design for the Test environment described in the architecture sheet. It lists every resource, exact configuration, network allocations, sizes, OS choices, security considerations, IAM bindings and other operational details. Use this as the single source-of-truth for requirements before implementing the Terraform modules in terraform/.

WARNING: This file is a detailed design and contains IP/CIDR choices and default sizes. Validate ranges against your organisation's IP plan before applying.

---

Table of contents
- Overview & purpose
- Global settings (provider, project, region, zones)
- Networking (VPC, subnets, private service networking, firewalls)
- Cloud SQL (Postgres) — full spec
- GKE cluster & node pool — full spec
- OAM server VM — full spec
- Shared storage (preferred: Filestore; alternative: GCS)
- Load Balancer & DNS — full spec
- Cloud Operations (monitoring, logging, Prometheus)
- Snapshot schedule (disks)
- Modules mapping
- Variables & outputs (summary)
- Backend (remote state) config
- How to initialize / plan / apply
- Architecture diagram (Mermaid)
- Change log

---

1) Overview & Purpose
- Environment: test
- Goal: Private, secure, regional GKE cluster with private Cloud SQL (Postgres HA), an OAM VM in the private subnet, shared storage, global HTTP(S) LB for GKE ingress with managed SSL, Cloud DNS and Cloud Operations integrated. Use modules, least-privilege IAM and remote state.

2) Global settings (defaults)
- GCP Project: variable: var.project_id (example default: test-project-123)
- Organization / Folder: set externally (not in this README)
- Region (primary): us-central1 (changeable via var.region)
- GKE cluster location type: regional (us-central1)
- Zones used (regional cluster): us-central1-a, us-central1-b, us-central1-c
- Terraform version: 1.6+ (use >=1.6 in versions.tf)
- Providers: google v>=4.x (use latest stable that supports resources used)
- Labels / tags: each resource gets labels: env=test, owner=${var.owner}, project=${var.project_id}
- Naming convention prefix: var.prefix (default: test)

3) Networking (VPC + subnets + private service networking)
- VPC
  - Name: test-vpc
  - Auto mode: disabled (custom)
  - Primary CIDR: 10.0.0.0/16
  - Flow logs: enabled on subnets (configurable)
  - Shared VPC: not enabled by default; can be adapted to host project
  - Purpose: host GKE, compute, DB, Filestore internal networks

- Subnets (regional: us-central1)
  - Subnet: test-subnet-gke
    - CIDR: 10.0.2.0/22 (1024 addresses) — used for GKE nodes/pods service IP allocation separation
    - Purpose: GKE node VM NICs (private cluster nodes)
    - Private Google Access: enabled
  - Subnet: test-subnet-compute
    - CIDR: 10.0.1.0/24 — compute VMs (OAM)
    - Purpose: OAM server VM (private)
    - Private Google Access: enabled
  - Subnet: test-subnet-db
    - CIDR: 10.0.3.0/28 — reserved small block for Cloud SQL private IP allocation + peering
    - Purpose: Cloud SQL private IP allocation range and private service connection
  - Peered range for Private Service Connect (Cloud SQL): 10.1.0.0/28 — reserved for private services (var.sql_private_range)
    - This range will be allocated via google_service_networking_connection for private service networking

- IP allocations (examples)
  - VPC primary: 10.0.0.0/16
  - GKE pod CIDR (secondary range): 10.4.0.0/14 (for pods across cluster)
  - GKE service CIDR (secondary): 10.8.0.0/20 (services)
  - Cloud SQL private IP: assigned from 10.0.3.0/28 after peering (e.g., 10.0.3.2)
  - Filestore IP: allocated from test-subnet-gke or test-subnet-compute (e.g., 10.0.2.10)

- Private Service Networking
  - Enable google_service_networking_connection to connect servicenetworking.googleapis.com and allocate var.sql_private_range (default 10.1.0.0/28)
  - Required for Cloud SQL private IP.

- Firewall rules
  - fw-allow-ssh-oam
    - Source ranges: var.oam_ssh_source_cidrs (default: ["203.0.113.0/32"] — replace with your office/bastion IP)
    - Target tags: oam-server
    - Ports: tcp:22
    - Purpose: restrict SSH to OAM server only
  - fw-gke-master-to-nodes
    - Source: GKE control plane CIDR (managed) — allow control plane → node traffic for necessary ports (TCP 10250, 443 etc.)
    - Use google_container_cluster's master_authorized_networks / private cluster options and GKE-managed firewall rules where possible
  - fw-lb-healthchecks
    - Source ranges: 130.211.0.0/22 and 35.191.0.0/16 (GCP LB health check ranges)
    - Ports: tcp:<health-check-port> (default 80/443)
  - fw-db-access-from-gke
    - Source ranges: GKE nodes' subnet (test-subnet-gke CIDR)
    - Target: Cloud SQL private IP (via network policy / authorized networks not required for private IP)
    - Ports: tcp:5432
    - Purpose: restrict DB access to GKE nodes only
  - fw-internal-icmp & fw-internal-all
    - Allow internal traffic between subnets (establish connectivity for operations, health checks, filestore)

4) Cloud SQL — PostgreSQL (full spec)
- Resource: google_sql_database_instance (high availability)
- Name: test-sql-postgres
- Region: us-central1 (regional instance for HA)
- HA (High Availability): enabled — regional HA (failover to standby instance in another zone)
- Machine / Instance tier: custom to meet memory requirement
  - vCPU: default (customize via var.sql_vcpu — default 2)
  - Memory: 15 GB → set machine type db-custom-2-15360 (2 vCPU, 15360 MB RAM) OR adjust variable to db-custom-4-15360 if more vCPU needed
  - Note: Terraform variable var.sql_db_machine (default "db-custom-2-15360")
- Storage
  - Storage type: SSD (pd-ssd)
  - Size: 200 GB (var.sql_storage_gb = 200)
  - Storage auto-extension: enabled (autoscaling)
- Backups & Recovery
  - Automated backups: enabled (daily window configurable)
  - Point-in-time recovery (PITR): enabled (binlog / point-in-time restore)
  - Backup retention: var.sql_backup_retention_days (default 7)
- Connectivity
  - Public IP: disabled
  - Private IP: enabled — uses service networking and allocated range var.sql_private_range
- Users & DB
  - Primary DB created: var.sql_database_name (default "appdb")
  - Admin user: created via Cloud SQL (use secure secret manager or terraform sensitive var for password)
  - Additional users: created per var.sql_users map (usernames + passwords)
- IAM
  - Workload Identity: Add IAM binding allowing GKE Workload Identity service account (KSA mapped to GCP SA) to access Cloud SQL via Cloud SQL Client role (roles/cloudsql.client) only
  - Grant principle: serviceAccount:${var.gke_workload_identity_gsa}
- Maintenance
  - Maintenance window scheduled off-hours (var.sql_maintenance_window)
  - Database flags: set as needed (e.g., log_statement = 'all' only if required)

5) GKE Cluster — Regional Private Cluster
- Cluster resource: google_container_cluster (or use terraform-google-modules/kubernetes-engine/google)
- Name: test-gke-cluster
- Location type: regional (us-central1)
- Network & subnetwork: VPC test-vpc and test-subnet-gke
- Private cluster: enabled
  - private_cluster_config: enable private endpoint (no public endpoint), master authorized networks optionally enabled for admin CIDRs
- Node Pools
  - Node pool resource uses module nodepool (see nodepool section)
  - Node pool name: worker-pool-1
  - Node count (initial): 3 (var.node_count = 3)
  - Minimum nodes (autoscaler): 1
  - Maximum nodes (autoscaler): 6 (var.node_pool_max = 6)
  - Autoscaling: enabled
  - Machine type: n2-standard-8
    - vCPU: 8
    - Memory: 32 GB
  - Boot disk
    - Size: 500 GB (var.node_boot_disk_gb = 500)
    - Type: pd-ssd
  - OS image
    - RHEL-based container-optimized image (var.node_image: "rhel-8-container-optimized" or GKE supported RHEL container image)
    - If RHEL license required, enable license/terms and set image type accordingly (ensure project has RHEL subscriptions)
  - Node pool HA: nodes distributed across regional zones: us-central1-a,b,c
  - Node pool autoscaler: enabled (min and max as above)
  - Node metadata: enable block-project-ssh-keys = true (enforce SSH via bastion)
  - Node pool IAM: node service account with least privileges (node SA with roles/container.nodeServiceAccount, roles/logging.logWriter, roles/monitoring.metricWriter, roles/monitoring.viewer as needed)
- Cluster features
  - Workload Identity: enabled (recommended)
  - Pod CIDR secondary ranges:
    - pods: 10.4.0.0/14
    - services: 10.8.0.0/20
  - Cloud Operations (Cloud Monitoring + Logging): enabled (enable_stackdriver=true)
  - Private endpoint: master endpoint accessible only via private IP or authorized networks
  - GKE Autopilot: not used — standard GKE

6) GKE Node pool details (module: nodepool)
- module will create:
  - Managed Instance Group(s) for node pool
  - Instance template using n2-standard-8, disk size 500GB, image RHEL container image
  - Preemptible: false (not preemptible)
  - Node labels: k8s-node-role=worker, env=test
  - Node taints: none by default (configurable)
  - Autoscaling: enabled (Cluster Autoscaler)
  - Upgrade strategy: surge upgrades with safe defaults
  - Disk snapshot schedule: resource policy applied to boot disks (see snapshots section)

7) OAM Server (VM) — Repo, Prometheus, CD server
- Resource: google_compute_instance
- Name: test-oam-server
- Zone: us-central1-b (one of cluster zones)
- Machine type: n2-standard-16
  - vCPU: 16
  - Memory: 64 GB
- Boot disk:
  - OS: RHEL 8 (rhel-8 image family / project: rhel-cloud)
  - Size: 150 GB (boot); provide main application data disk separate — see below
- Data disk (attached persistent disk)
  - Size: 1500 GB (1.5 TB)
  - Type: pd-ssd (or pd-balanced if cost optimization desired)
  - Auto-delete: false
  - Snapshot schedule: attached to snapshot policy daily with 7 days retention (resource policy)
- Network
  - NIC: attached to test-subnet-compute (private)
  - No external IP (private only)
  - Access via bastion / VPN / Cloud IAP SSH (recommend IAP)
- Startup Script
  - Provisioning: cloud-init / metadata startup script to install:
    - basic packages (git, docker, jq, monitoring agent)
    - Docker runtime / container runtime suitable for CD/CI
    - Register Prometheus node exporter if needed
  - Script stored in module variable var.oam_startup_script or pulled from GCS
- Tags: oam-server, monitoring-enabled
- IAM
  - Service Account: dedicated VM service account with least privilege for required APIs (storage access to push logs or artifacts, compute read for snapshot ops as needed)

8) Shared Storage (preferred: Filestore) — 500 GB
Preferred: Filestore (NFS) for POSIX filesystem
- Filestore instance (tier: standard or enterprise depending performance)
  - Name: test-filestore
  - Tier: STANDARD (or HIGH_SCALE depending on throughput need)
  - Capacity: 500 GB
  - Region/Zone: us-central1 (select same region as GKE)
  - Network: VPC test-vpc and reserved IP (e.g., 10.0.2.10)
  - Mount: NFS export path (e.g., /vol1)
  - Access control: export policies restrict to test-subnet-gke, test-subnet-compute
  - Use-case: shared storage for OAM, Prometheus remote write, or legacy apps

Alternative: GCS bucket with versioning (if NFS not required)
- GCS bucket: test-shared-storage
  - Versioning: enabled
  - Uniform bucket-level access: enabled
  - Lifecycle: expire object non-current versions after 30 days (configurable)
  - Access: via IAM (principals only), not publicly accessible

9) Load Balancer — Global HTTP(S) Load Balancer (GKE Ingress)
- Type: Global external HTTP(S) load balancer using GKE Ingress and NEG backend
- Frontend
  - IPv4 global static IP: Reserve address var.lb_ip_name (e.g., test-lb-ip)
  - IPv6: not configured by default
  - Protocols: HTTP & HTTPS
  - SSL: Google Managed SSL Certificate (managed)
    - Certificate resource: google_compute_managed_ssl_certificate (or use GKE ingress-managed cert)
    - Domains: var.lb_domains (example: app.test.example.com)
- Backend
  - Backend service: referencing Kubernetes NEG (Network Endpoint Groups) created by GKE Ingress
  - Health checks: HTTP/HTTPS health check (path: /healthz or configurable)
  - Session affinity: none by default
  - Connection draining / timeout: configured per traffic profile
- Security
  - Enable Cloud Armor (optional) with a default deny/allow policies if required
- DNS
  - A record created pointing domain to the reserved global LB IP

10) Cloud DNS
- Managed zone: test-public-zone (public) or private zone for internal records
  - DNS zone: example.com. (change via var.dns_zone)
- Records
  - A record: app.test.example.com -> LB external IP
  - Internal records (private zone) for internal services:
    - db.internal.test.example.com -> Cloud SQL private IP
    - oam.internal.test.example.com -> OAM VM internal IP
    - filestore.internal.test.example.com -> Filestore IP
- TTLs: default 300s

11) Cloud Operations (Monitoring + Logging)
- Enable APIs: monitoring.googleapis.com and logging.googleapis.com
- Logging
  - Cloud Logging enabled for GKE, VM, Cloud SQL
  - Log sinks
    - Sink to BigQuery for audit logs (optional)
    - Sink to GCS for long-term log archive
  - IAM for sinks: use service accounts with least privilege
- Monitoring
  - Enable builtin dashboards for GKE and Cloud SQL
  - Create custom dashboards (module) for node resource usage, DB metrics, OAM server metrics
  - Alerting
    - Alert policy: node CPU > 85% sustained 5m
    - DB storage utilization > 80%
    - LB 5xx error rate > threshold
    - Disk snapshot failures
- Prometheus
  - Prometheus running on GKE (operator or kube-prometheus-stack)
  - Prometheus scraper config: scrape kubelets, cAdvisor, pod metrics (prometheus-operator)
  - Remote write to Stackdriver if needed (or use Managed Service for Prometheus)
- IAM
  - Monitoring service account for GKE workloads created with restricted roles (roles/monitoring.metricWriter, roles/logging.logWriter)

12) Snapshot schedule (compute disk snapshots nightly, 7 days retention)
- Resource: google_compute_resource_policy (snapshot schedule policy)
  - Frequency: daily
  - Time window: var.snapshot_time (default 03:00)
  - Retention: 7 days
- Apply to disks
  - OAM VM data disk attached to test-oam-server
  - GKE node boot disks:
    - Use resourcePolicy or use an instance template with attached resource policy to schedule snapshots for MIGs (node pool disks). Note: snapshot scheduling for node boot disks is supported by resource policies attached to disk resources or via instance template disk settings
- Snapshot label/tagging: env=test, snapshot-policy=daily-7

13) IAM & Least Privilege (summary)
- Service accounts created
  - gke-node-sa: roles required: roles/logging.logWriter, roles/monitoring.metricWriter, roles/stackdriver.resourceMetadata.writer, roles/iam.serviceAccountUser only if needed
  - gke-workload-sa (GCP SA): bound to Kubernetes KSA via Workload Identity and granted roles/cloudsql.client for DB access
  - oam-vm-sa: minimal roles for storage access (roles/storage.objectViewer/Creator as required)
  - sql-sa: Cloud SQL admin access only to manage instance (if required). Prefer to manage SQL via infra pipeline not runtime.
- IAM Bindings
  - Cloud SQL: roles/cloudsql.client to gke-workload-identity SA only
  - Cloud DNS: managed zone owner to DNS admin SA for automation (roles/dns.admin) — minimize to specific SA
  - LB: run as user with roles/compute.networkAdmin or use terraform service account with compute.networkAdmin limited to resource creation scope
- Principle of least privilege enforced via module defaults

14) Modules mapping (terraform/modules)
- modules/vpc — implements VPC, subnets, private service networking, firewall rules
- modules/gke — implements GKE cluster (private, regional) and Workload Identity
- modules/nodepool — implements node pool(s) with autoscaler, disk configs and labels
- modules/sql — implements Cloud SQL Postgres HA instance, users, DB, private IP — uses terraform-google-modules/sql-db module if desired
- modules/vm — implements OAM server VM with attached data disk and startup script
- modules/storage — implements Filestore and/or GCS bucket with lifecycle and versioning
- modules/lb — configures global HTTP(S) LB, static IP and SSL certs, integrates with GKE Ingress/NEG
- modules/dns — cloud DNS managed zones and records
- modules/monitoring — creates dashboards, alert policies, log sinks, Prometheus integration config
- modules/snapshots — resource policies for snapshots and attachment to disks

15) Terraform backend (remote state)
- Backend: GCS
  - bucket: var.tfstate_bucket (example: test-terraform-state)
  - prefix: environments/test/terraform.tfstate
  - Enable object versioning on bucket
  - IAM: terraform SA must have roles/storage.objectAdmin on the bucket
  - State locking: achieved through GCS object metadata and storage - gcs does not provide strong locking by itself; best practice: use Terraform Cloud or use Google Cloud Storage with state locking via google backend + use consistency with service account. (GCS provides optimistic concurrency using generation numbers)
- Example backend configuration: environments/test/backend.tf (see repo)

16) Variables (selected defaults)
- var.project_id = "test-project-123"
- var.region = "us-central1"
- var.zones = ["us-central1-a","us-central1-b","us-central1-c"]
- var.prefix = "test"
- var.owner = "infrastructure-team@example.com"
- var.vpc_cidr = "10.0.0.0/16"
- var.subnet_gke_cidr = "10.0.2.0/22"
- var.subnet_compute_cidr = "10.0.1.0/24"
- var.subnet_db_cidr = "10.0.3.0/28"
- var.sql_private_range = "10.1.0.0/28"
- var.pod_cidr = "10.4.0.0/14"
- var.service_cidr = "10.8.0.0/20"
- var.sql_db_machine = "db-custom-2-15360"
- var.sql_storage_gb = 200
- var.node_count = 3
- var.node_boot_disk_gb = 500
- var.node_machine_type = "n2-standard-8"
- var.oam_machine_type = "n2-standard-16"
- var.oam_data_disk_gb = 1500
- var.filestore_size_gb = 500
- var.lb_domains = ["app.test.example.com"]
- var.tfstate_bucket = "test-terraform-state"
- All variables have sensible defaults; override via environments/test/terraform.tfvars

17) Outputs (summary of key outputs)
- output.cluster_name
- output.cluster_endpoint (internal/private endpoint)
- output.kubeconfig (or instructions to retrieve via gcloud)
- output.gke_master_private_ip
- output.gke_node_pool_ids
- output.sql_instance_name
- output.sql_private_ip
- output.sql_connection_name
- output.oam_instance_id
- output.oam_internal_ip
- output.filestore_ip
- output.lb_ipv4_address
- output.dns_zone_name

18) How to initialize / plan / apply
- Prereqs:
  - Install Terraform 1.6+
  - Install gcloud and authenticate: gcloud auth application-default login
  - Set project: gcloud config set project ${PROJECT_ID}
  - Ensure APIs enabled: container.googleapis.com, sqladmin.googleapis.com, compute.googleapis.com, monitoring.googleapis.com, servicemanagement.googleapis.com, servicemanagement.googleapis.com, servicenetworking.googleapis.com, filestore.googleapis.com, dns.googleapis.com
- Example commands (Windows PowerShell / cmd)
  - cd c:\Users\Sathishkumar.KATHIRV\OneDrive - HR365\Desktop\tf\terraform\environments\test
  - terraform init
  - terraform plan -var-file="terraform.tfvars"
  - terraform apply -var-file="terraform.tfvars"
- Backend: configure environments/test/backend.tf with your tfstate bucket and prefix before terraform init
- Sensitive values (DB passwords) should be passed via environment variables or secret manager referenced by Terraform

19) Security & Operational Notes
- No public IPs: GKE control plane & nodes are private, Cloud SQL is private, OAM VM has no external IP.
- SSH access: use Bastion or Cloud IAP; restricted only to var.oam_ssh_source_cidrs.
- RHEL images may require license acceptance and subscription—confirm with your subscription and GCP marketplace usage.
- Workload Identity is mandatory for Cloud SQL access from GKE — do NOT embed DB credentials in pods; use IAM + Cloud SQL Auth Proxy where needed.
- Backups: you must test point-in-time recovery (PITR) periodically.
- Snapshot retention: 7 days; modify as per policy.
- Filestore performance and tier should be chosen after workload profiling.

20) Architecture diagram (Mermaid)
```mermaid
flowchart LR
  subgraph VPC[ VPC: test-vpc (10.0.0.0/16) ]
    subgraph GKE_SUBNET[ GKE Subnet 10.0.2.0/22 ]
      GKE[GKE Regional Cluster (private)]
      FIL[Filestore (10.0.2.10)]
    end
    subgraph COMPUTE_SUBNET[ Compute Subnet 10.0.1.0/24 ]
      OAM[OAM Server VM (n2-std-16, 1.5TB data)]
    end
    subgraph DB_SUBNET[ DB Subnet 10.0.3.0/28 ]
      SQL[Cloud SQL Postgres (private IP)]
    end
  end

  Internet --> LB[Global HTTP(S) Load Balancer (managed cert)]
  LB -->|NEG| GKE
  DNS((Cloud DNS)) --> LB
  GKE --> SQL
  OAM --> SQL
  GKE --> FIL
  OAM --> FIL
  Monitoring[Cloud Operations] --> GKE
  Monitoring --> OAM
  Monitoring --> SQL
```

21) Change log & next steps
- This README provides concrete defaults. Before apply:
  - Replace placeholder domain names and IPs (oam_ssh_source_cidrs, lb_domains).
  - Confirm RHEL licensing & image names in your GCP account.
  - Ensure APIs are enabled and service account for Terraform has required roles (project IAM).
  - Review subnet CIDRs against global IP plan to avoid collisions.

---

If you want, I can now:
- Generate the full terraform code for all modules and environment files in the requested folder structure (terraform/modules/* and terraform/environments/test/*).
- Or produce just the environments/test/backend.tf, main.tf and variables.tf wiring the modules.

Please confirm whether to:
1) Generate full module implementations now (this will be lengthy, I will create all files under the folder), or
2) Only generate environment wiring and backend (you will implement modules), or
3) Make any change to IP ranges / machine sizes / region defaults before code generation.
