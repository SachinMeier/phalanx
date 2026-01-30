---
name: good-infrastructure
description: Write DRY, reliable infrastructure using Pulumi + GCP + Kubernetes. Use when creating cloud resources, reviewing infra PRs, or debugging deployments.
---

# Good Infrastructure

DRY, reliable infrastructure with Pulumi + GCP + Kubernetes.

## When to Use

- Creating cloud resources (GKE, CloudSQL, buckets, secrets)
- Writing GitHub Actions for deployment
- Reviewing infrastructure PRs
- Debugging deployment failures
- Setting up environments (staging, production)

## When NOT to Use

- Local development (use docker-compose)
- Application code (use `good-effect` skill)
- One-off manual operations (use gcloud CLI directly)

---

## Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| IaC | Pulumi (TypeScript) | Define cloud resources |
| Cloud | GCP | Provider |
| Compute | GKE Autopilot | Kubernetes cluster |
| Database | CloudSQL (Postgres) | Managed PostgreSQL |
| CI/CD | GitHub Actions | Build, test, deploy |
| Secrets | GCP Secret Manager | Runtime secrets |
| DNS/TLS | Cloud Load Balancing | Ingress + managed certs |

---

## Directory Structure

```
apps/infra/
├── Pulumi.yaml
├── Pulumi.staging.yaml
├── Pulumi.production.yaml
├── index.ts
└── src/
    ├── cluster.ts
    ├── database.ts
    ├── networking.ts
    ├── storage.ts
    ├── secrets.ts
    ├── iam.ts
    └── k8s/
        ├── namespace.ts
        ├── deployments.ts
        ├── services.ts
        └── config.ts
```

---

## Core Rules

### 1. One Resource per Function

```typescript
// WRONG
function createInfra() {
  const cluster = new gcp.container.Cluster(...);
  const db = new gcp.sql.DatabaseInstance(...);
  // 200 more lines...
}

// CORRECT
export function createCluster(name: string, opts: ClusterOpts) {
  return new gcp.container.Cluster(name, { ... });
}
```

### 2. Explicit Dependencies

```typescript
// WRONG
const cluster = createCluster("main");
const nodePool = createNodePool("main"); // Race condition?

// CORRECT
const nodePool = createNodePool("main", {
  dependsOn: [cluster],
});
```

### 3. No Hardcoded Values

```typescript
// WRONG
const db = new gcp.sql.DatabaseInstance("db", {
  region: "us-central1",
  settings: { tier: "db-f1-micro" },
});

// CORRECT
const config = new pulumi.Config();
const db = new gcp.sql.DatabaseInstance("db", {
  region: gcpConfig.require("region"),
  settings: { tier: config.require("dbTier") },
});
```

### 4. Name Resources with Stack Prefix

```typescript
// WRONG - collisions across environments
const bucket = new gcp.storage.Bucket("uploads");

// CORRECT
const stack = pulumi.getStack();
const bucket = new gcp.storage.Bucket(`${stack}-uploads`);
```

### 5. Export Outputs

```typescript
// WRONG
function main() {
  createCluster("main");
  createDatabase("main");
}

// CORRECT
export const clusterEndpoint = cluster.endpoint;
export const dbConnectionName = db.connectionName;
```

### 6. Use Autopilot for GKE

```typescript
// WRONG - managing node pools manually
const cluster = new gcp.container.Cluster("main", {
  initialNodeCount: 3,
  nodeConfig: { machineType: "e2-medium" },
});

// CORRECT
const cluster = new gcp.container.Cluster("main", {
  enableAutopilot: true,
  location: region,
});
```

### 7. Private Networking by Default

```typescript
// WRONG - public DB
settings: {
  ipConfiguration: { ipv4Enabled: true },
}

// CORRECT
settings: {
  ipConfiguration: {
    ipv4Enabled: false,
    privateNetwork: vpc.id,
  },
}
```

### 8. Least-Privilege IAM

```typescript
// WRONG
new gcp.projects.IAMMember("api-admin", {
  role: "roles/owner",
  member: sa.email.apply(e => `serviceAccount:${e}`),
});

// CORRECT
const roles = ["roles/cloudsql.client", "roles/secretmanager.secretAccessor"];
roles.forEach((role, i) => {
  new gcp.projects.IAMMember(`api-role-${i}`, {
    role,
    member: sa.email.apply(e => `serviceAccount:${e}`),
  });
});
```

### 9. Use IAMMember, Never IAMBinding

IAMBinding is **authoritative**—replaces ALL members for a role, destroying bindings managed elsewhere.

```typescript
// WRONG - destroys other members with this role
new gcp.serviceaccount.IAMBinding("workload-identity", {
  serviceAccountId: gcpSa.name,
  role: "roles/iam.workloadIdentityUser",
  members: [myMember], // Overwrites ALL existing members
});

// CORRECT - additive, safe
new gcp.serviceaccount.IAMMember("workload-identity", {
  serviceAccountId: gcpSa.name,
  role: "roles/iam.workloadIdentityUser",
  member: myMember,
});
```

| Resource | Behavior | Use When |
|----------|----------|----------|
| `IAMMember` | Additive | Always (default) |
| `IAMBinding` | Authoritative per role | Never |
| `IAMPolicy` | Authoritative for all | Never |

---

## GKE Patterns

### Workload Identity (No Keys)

```typescript
const gcpSa = new gcp.serviceaccount.Account("api-sa", {
  accountId: `${stack}-api`,
});

const k8sSa = new k8s.core.v1.ServiceAccount("api-sa", {
  metadata: {
    namespace: "default",
    annotations: {
      "iam.gke.io/gcp-service-account": gcpSa.email,
    },
  },
});

new gcp.serviceaccount.IAMMember("workload-identity", {
  serviceAccountId: gcpSa.name,
  role: "roles/iam.workloadIdentityUser",
  member: pulumi.interpolate`serviceAccount:${project}.svc.id.goog[default/${k8sSa.metadata.name}]`,
});
```

### Deployment Template

```typescript
const deployment = new k8s.apps.v1.Deployment("api", {
  spec: {
    replicas: 2,
    template: {
      spec: {
        serviceAccountName: k8sSa.metadata.name,
        containers: [{
          name: "api",
          image: pulumi.interpolate`${region}-docker.pkg.dev/${project}/images/api:${imageTag}`,
          resources: {
            requests: { cpu: "250m", memory: "512Mi" },
            limits: { cpu: "1000m", memory: "1Gi" },
          },
          livenessProbe: { httpGet: { path: "/healthz", port: 3000 } },
          readinessProbe: { httpGet: { path: "/readyz", port: 3000 } },
        }],
      },
    },
  },
});
```

---

## CloudSQL Patterns

### High Availability

```typescript
const db = new gcp.sql.DatabaseInstance("main", {
  databaseVersion: "POSTGRES_15",
  settings: {
    availabilityType: "REGIONAL",
    backupConfiguration: {
      enabled: true,
      pointInTimeRecoveryEnabled: true,
    },
    ipConfiguration: {
      ipv4Enabled: false,
      privateNetwork: vpc.id,
    },
  },
  deletionProtection: stack === "production",
});
```

### Cloud SQL Proxy Sidecar

```typescript
containers: [
  { name: "api", /* connects to localhost:5432 */ },
  {
    name: "cloud-sql-proxy",
    image: "gcr.io/cloud-sql-connectors/cloud-sql-proxy:2",
    args: ["--structured-logs", "--private-ip", db.connectionName],
  },
],
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| `kubectl apply` in CI | Drift from IaC | Define in Pulumi |
| Manual secret creation | Unreproducible | Use Secret Manager + Pulumi |
| Public IPs on databases | Security risk | Private networking |
| Single-zone deployments | No HA | Regional resources |
| `roles/owner` for SAs | Over-permissioned | Specific roles only |
| `IAMBinding`/`IAMPolicy` | Destroys other members | Use `IAMMember` only |
| Hardcoded image tags | Breaks rollback | Use git SHA |
| No resource limits | Noisy neighbor | Always set limits |
| Shared namespaces | Blast radius | Namespace per service |

---

## Applying Changes

After editing infrastructure, provide the user with deployment instructions.

### Pulumi

```bash
# Preview changes
devbox run -- pulumi preview --stack staging --cwd apps/infra

# Apply changes
devbox run -- pulumi up --stack staging --cwd apps/infra

# Production (requires confirmation)
devbox run -- pulumi up --stack production --cwd apps/infra
```

### Kubernetes Manifests

```bash
# Preview diff
devbox run -- kubectl diff -f apps/infra/k8s/base/

# Apply manifests
devbox run -- kubectl apply -f apps/infra/k8s/base/

# Verify rollout
devbox run -- kubectl rollout status deployment/<name>
```

### GitHub Actions

Changes to `.github/workflows/` take effect on next push. Verify:
1. Push changes to branch
2. Check Actions tab for workflow runs
3. Review logs for errors

---

## Debugging Checklist

### Deployment Failing

1. `kubectl describe pod <name>` — check events
2. `kubectl logs <pod> -c <container>` — check logs
3. `gcloud artifacts docker images list` — verify image exists
4. `gcloud iam service-accounts get-iam-policy` — check bindings

### Database Connection Failing

1. `gcloud sql instances describe <instance>` — verify private IP
2. `gcloud compute networks peerings list` — check VPC peering
3. `kubectl describe sa <name>` — verify Workload Identity
4. `kubectl exec -it <pod> -- pg_isready -h <ip>` — test connectivity

### Pulumi Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `resource already exists` | Name collision | Add stack prefix |
| `permission denied` | Missing IAM role | Grant required role |
| `quota exceeded` | Hit GCP limits | Request quota increase |
| `dependency cycle` | Circular refs | Break with explicit outputs |

---

## Checklist

Before merging infrastructure changes:

- [ ] Resources prefixed with stack name
- [ ] No hardcoded values (use Config)
- [ ] Private networking for databases
- [ ] Workload Identity (no JSON keys)
- [ ] IAMMember only (no IAMBinding/IAMPolicy)
- [ ] Resource requests/limits set
- [ ] Health checks defined
- [ ] Deletion protection on production
- [ ] `pulumi preview` shows expected changes
- [ ] Outputs exported for downstream use
- [ ] Apply instructions provided to user
