import pytest
from app.main import create_app


@pytest.fixture
def client(tmp_path):
    app = create_app({"TESTING": True, "DATABASE": str(tmp_path / "test.db")})
    return app.test_client()


def test_health(client):
    result = client.get("/health")
    assert result.status_code == 200
    assert result.json["status"] == "ok"


def test_create_and_list(client):
    result = client.post("/tasks", json={"title": "Estudar GitHub Actions"})
    assert result.status_code == 201
    assert result.json["id"] == 1
    listed = client.get("/tasks")
    assert listed.status_code == 200
    assert len(listed.json) == 1
    assert listed.json[0]["title"] == "Estudar GitHub Actions"


def test_invalid_title(client):
    assert client.post("/tasks", json={"title": "  "}).status_code == 400


def test_mark_done(client):
    item = client.post("/tasks", json={"title": "Deploy"}).json
    result = client.patch(f'/tasks/{item["id"]}', json={"done": True})
    assert result.status_code == 200
    assert client.get("/tasks").json[0]["done"] is True


def test_not_found(client):
    assert client.patch("/tasks/999", json={"done": True}).status_code == 404


# --- DELETE /tasks/<id> ---

def test_delete_existing_task_returns_204(client):
    item = client.post("/tasks", json={"title": "Remover"}).json
    result = client.delete(f'/tasks/{item["id"]}')
    assert result.status_code == 204
    assert result.data == b""
    assert client.get("/tasks").json == []


def test_delete_missing_task_returns_404(client):
    assert client.delete("/tasks/999").status_code == 404


def test_delete_twice_returns_404_second_time(client):
    item = client.post("/tasks", json={"title": "Uma vez"}).json
    assert client.delete(f'/tasks/{item["id"]}').status_code == 204
    assert client.delete(f'/tasks/{item["id"]}').status_code == 404


# --- Melhorias: /version e filtro por situacao ---

def test_version_reports_configured_value(tmp_path):
    app = create_app({"TESTING": True, "DATABASE": str(tmp_path / "v.db"), "APP_VERSION": "abc123"})
    result = app.test_client().get("/version")
    assert result.status_code == 200
    assert result.json == {"service": "cloud-tasks-api", "version": "abc123"}


def test_filter_tasks_by_status(client):
    first = client.post("/tasks", json={"title": "Feita"}).json
    client.post("/tasks", json={"title": "Pendente"})
    client.patch(f'/tasks/{first["id"]}', json={"done": True})
    done = client.get("/tasks?done=true").json
    pending = client.get("/tasks?done=false").json
    assert [t["title"] for t in done] == ["Feita"]
    assert [t["title"] for t in pending] == ["Pendente"]
    assert len(client.get("/tasks").json) == 2


def test_filter_rejects_invalid_value(client):
    assert client.get("/tasks?done=talvez").status_code == 400
