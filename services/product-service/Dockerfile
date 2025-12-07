FROM python:3.13-slim-bookworm

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

COPY --from=ghcr.io/astral-sh/uv:0.7.7 /uv /uvx /bin/
ENV PATH="/app/.venv/bin:$PATH"
ENV UV_COMPILE_BYTECODE=1

COPY pyproject.toml /app/
COPY src /app/src

RUN uv sync --no-dev

EXPOSE 8000

CMD ["uv", "run", "fastapi", "run", "--host", "0.0.0.0", "--port", "8000", "--workers", "4", "src/main.py"]
