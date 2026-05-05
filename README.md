<div align="center">

# 🐾 Lemmy DevOps Portfolio

**Production-grade deployment of a federated Reddit alternative**
built to demonstrate real-world DevOps practices.

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat&logo=nginx&logoColor=white)](https://nginx.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)](https://postgresql.org)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=githubactions&logoColor=white)](https://github.com/features/actions)

</div>

---

## 📌 Overview

This project deploys [Lemmy](https://github.com/LemmyNet/lemmy) — an open-source, federated social platform — using a fully containerized, production-ready stack. Every component is wired together with health checks, resource limits, and a reverse proxy, mirroring how real-world services are run in production.

---

## 🏗️ Architecture

```
                        ┌─────────────────────────────┐
                        │         Docker Network       │
                        │                              │
          HTTP :80      │   ┌──────────────────────┐   │
User ─────────────────► │   │    Nginx (Proxy)      │   │
                        │   └───────────┬──────────┘   │
                        │               │               │
                        │     ┌─────────┴─────────┐    │
                        │     ▼                   ▼    │
                        │ ┌──────────┐  ┌─────────────┐│
                        │ │ lemmy-ui │  │    lemmy    ││
                        │ │  :1234   │  │    :8536    ││
                        │ └──────────┘  └──────┬──────┘│
                        │                      │        │
                        │           ┌──────────┴──────┐ │
                        │           ▼                 ▼ │
                        │      ┌─────────┐  ┌────────┐  │
                        │      │postgres │  │pictrs  │  │
                        │      │  :5432  │  │  :8080 │  │
                        │      └─────────┘  └────────┘  │
                        └─────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Containerization | Docker + Compose | Service orchestration |
| Reverse Proxy | Nginx Alpine | Routing + load balancing |
| Backend | Lemmy (Rust) | API + federation |
| Frontend | Lemmy-UI (Node) | Web interface |
| Database | PostgreSQL 16 | Persistent storage |
| Media | pictrs | Image processing |

---

## 🚀 Quick Start

### Prerequisites
- Docker >= 24.0
- Docker Compose >= 2.0

### Run Locally

```bash
# 1. Clone
git clone https://github.com/YOUR_USERNAME/lemmy-devops.git
cd lemmy-devops

# 2. Set permissions
mkdir -p volumes/pictrs volumes/postgres
sudo chown -R 991:991 volumes/pictrs

# 3. Start
docker compose up -d

# 4. Verify
docker ps --format "{{.Names}}: {{.Status}}"
```

Open [http://localhost](http://localhost) in your browser.

---

## 📁 Project Structure

```
lemmy-devops/
├── 📄 docker-compose.yml      # Orchestration + health checks
├── 📄 nginx_internal.conf     # Reverse proxy routing rules
├── 📄 lemmy.hjson             # Lemmy backend configuration
├── 📁 volumes/
│   ├── postgres/              # Database persistent data
│   └── pictrs/                # Media storage
└── 📁 .github/
    └── workflows/             # CI/CD pipelines (Sprint 2)
```

---

## ✅ Health Checks

All services are configured with Docker health checks:

```bash
docker ps --format "{{.Names}}: {{.Status}}"
```

Expected output:
```
lemmy-proxy-1:     Up X minutes (healthy)
lemmy-lemmy-1:     Up X minutes (healthy)
lemmy-lemmy-ui-1:  Up X minutes (healthy)
lemmy-pictrs-1:    Up X minutes (healthy)
lemmy-postgres-1:  Up X minutes (healthy)
```

---

## 🗺️ Roadmap

| Sprint | Focus | Status |
|---|---|---|
| Sprint 1 | Docker + Compose + Nginx | ✅ Done |
| Sprint 2 | GitHub Actions CI/CD | 🔄 In Progress |
| Sprint 3 | Kubernetes + Helm | ⏳ Upcoming |
| Sprint 4 | Prometheus + Grafana | ⏳ Upcoming |

---

## 📚 Resources

- [Lemmy Documentation](https://join-lemmy.org/docs)
- [Docker Compose Reference](https://docs.docker.com/compose)
- [Nginx Reverse Proxy Guide](https://nginx.org/en/docs)

---

<div align="center">
Built with ❤️ as part of a DevOps learning journey
</div>
