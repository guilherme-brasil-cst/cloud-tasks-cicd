FROM python:3.12-slim
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 DB_PATH=/data/tasks.db
# SHA do commit injetado pela CI; exposto em GET /version.
ARG GIT_SHA=dev
ENV APP_VERSION=${GIT_SHA}
WORKDIR /srv/app
RUN groupadd --system appuser && useradd --system --gid appuser appuser && mkdir -p /data && chown appuser:appuser /data
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
USER appuser
EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "app.wsgi:app"]
