# Dockerfile Best Practices 🐳

> A practical reference for writing production-grade Dockerfiles.  
> Used in the [lemmy-devops](https://github.com/mahmoud755/lemmy-devops) portfolio project.

---

## Table of Contents

1. [The Golden Template](#the-golden-template)
2. [The 10 Rules](#the-10-rules)
3. [Layer Caching Strategy](#layer-caching-strategy)
4. [Multi-stage Builds](#multi-stage-builds)
5. [.dockerignore](#dockerignore)
6. [Quick Reference](#quick-reference)

---

## The Golden Template

```dockerfile
# 1. Pinned base image — never use latest
FROM python:3.11-slim

# 2. Metadata
LABEL maintainer="mahmoud755"
LABEL version="1.0"

# 3. Working directory first
WORKDIR /app

# 4. Copy requirements BEFORE source code (cache optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy source code after dependencies
COPY . .

# 6. Run as non-root user
RUN useradd -m appuser
USER appuser

# 7. Document the port (does not actually publish it)
EXPOSE 5000

# 8. Health check inside the image
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

# 9. Use exec form for CMD
CMD ["python", "-m", "gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
```

---

## The 10 Rules

### 1. Never use `latest`

```dockerfile
# ❌ Unpredictable — breaks on new releases
FROM python:latest

# ✅ Pinned and reproducible
FROM python:3.11-slim
```

### 2. Use slim or alpine — not full images

```dockerfile
# ❌ ~1.2 GB
FROM python:3.11

# ✅ ~150 MB
FROM python:3.11-slim

# ✅ ~50 MB (may require extra effort)
FROM python:3.11-alpine
```

### 3. Copy requirements before source code

```dockerfile
# ❌ Any code change = full pip reinstall
COPY . .
RUN pip install -r requirements.txt

# ✅ pip layer is cached unless requirements.txt changes
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
```

> **Why?** Docker caches each layer. If the layer inputs haven't changed, Docker reuses the cache. Putting `COPY . .` last means only code changes invalidate that layer — not dependencies.

### 4. Merge RUN commands to reduce layers

```dockerfile
# ❌ Creates 3 separate layers
RUN apt update
RUN apt install -y curl
RUN apt clean

# ✅ Single layer + cleanup in same step
RUN apt update && \
    apt install -y curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
```

### 5. Never run as root

```dockerfile
# ❌ Default is root — security risk
USER root

# ✅ Create and use a non-root user
RUN useradd -m appuser
USER appuser
```

### 6. Always use .dockerignore

```
# .dockerignore
__pycache__/
*.pyc
.env
.git/
volumes/
*.log
tests/
node_modules/
```

### 7. Use --no-cache-dir with pip

```dockerfile
# ❌ Stores pip cache inside the image (wasted space)
RUN pip install -r requirements.txt

# ✅ No cache = smaller image
RUN pip install --no-cache-dir -r requirements.txt
```

### 8. Use COPY not ADD

```dockerfile
# ❌ ADD does extra things (URL fetching, auto-extraction)
ADD . .

# ✅ COPY is explicit and predictable
COPY . .

# Only use ADD when you need tar auto-extraction:
ADD app.tar.gz /app/
```

### 9. Use ENV for configuration

```dockerfile
# ✅ Improves runtime behavior and debugging
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=5000
```

### 10. Use exec form for CMD

```dockerfile
# ❌ Shell form — signals don't reach the process (graceful shutdown fails)
CMD "python app.py"

# ✅ Exec form — signals delivered directly to process
CMD ["python", "app.py"]
```

---

## Layer Caching Strategy

Order layers from **least frequently changed** to **most frequently changed**:

```
FROM            ← almost never changes
RUN apt install ← rarely changes
COPY req.txt    ← changes occasionally
RUN pip install ← changes when req.txt changes
COPY . .        ← changes on every code edit   ← put LAST
CMD             ← rarely changes
```

**Rule:** What changes most often goes at the bottom.

---

## Multi-stage Builds

Use when you need build tools that shouldn't exist in the final image.

```dockerfile
# Stage 1 — Builder (has all build tools)
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2 — Production (clean, minimal)
FROM python:3.11-slim AS production
WORKDIR /app

# Copy only what's needed from builder
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY . .

RUN useradd -m appuser
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

**Benefits:**
- Final image has no build tools → smaller & more secure
- Build cache is still used between stages
- Common pattern for Go, Java, Node.js, Rust apps

---

## .dockerignore

Always create this file next to your Dockerfile:

```
# Version control
.git/
.gitignore

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.egg-info/
dist/
build/

# Environment
.env
.env.*
venv/
.venv/

# Logs & data
*.log
volumes/

# Tests & docs
tests/
docs/
*.md

# OS
.DS_Store
Thumbs.db
```

---

## Quick Reference

| Rule | Bad | Good |
|---|---|---|
| Base image | `FROM python:latest` | `FROM python:3.11-slim` |
| Dependencies | `COPY . . → RUN pip` | `COPY req.txt → RUN pip → COPY . .` |
| RUN commands | Multiple `RUN` lines | Chained with `&&` |
| User | `root` (default) | `useradd -m appuser` |
| pip cache | `pip install` | `pip install --no-cache-dir` |
| File copy | `ADD . .` | `COPY . .` |
| CMD format | `CMD "python app.py"` | `CMD ["python", "app.py"]` |
| Image size | Full image | `slim` or `alpine` |

---

## Common Image Size Comparison

| Base Image | Size |
|---|---|
| `python:3.11` | ~1.2 GB |
| `python:3.11-slim` | ~150 MB |
| `python:3.11-alpine` | ~50 MB |
| Multi-stage final | ~80–120 MB |

---

*Part of the [lemmy-devops](https://github.com/mahmoud755/lemmy-devops) DevOps portfolio — Sprint 1*
