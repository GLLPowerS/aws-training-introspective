FROM python:3.13-slim-bookworm

WORKDIR /app

# Send stdout/stderr directly to the terminal for clean container logs
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Install uv (fast Python package manager/runtime)
COPY --from=ghcr.io/astral-sh/uv:0.7.7 /uv /uvx /bin/

# Place project venv first on PATH and compile bytecode for faster startup
ENV PATH="/app/.venv/bin:$PATH"
ENV UV_COMPILE_BYTECODE=1

# Project metadata and sources
COPY pyproject.toml /app/
COPY src /app/src

# Install dependencies into the managed virtualenv
RUN uv sync --no-dev

EXPOSE 8000

# Run FastAPI via uv with multiple workers, bound to all interfaces
CMD ["uv", "run", "fastapi", "run", "--host", "0.0.0.0", "--port", "8000", "--workers", "4", "src/main.py"]
