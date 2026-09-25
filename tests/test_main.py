from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_root_endpoint():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "DeployGuard",
        "message": "Deployment service is running",
    }

def test_health_endpoint():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_version_endpoint():
    response = client.get("/version")
    data = response.json()

    assert response.status_code == 200
    assert "version" in data
    assert isinstance(data["version"], str)
    assert data["version"] != ""

def test_health_endpoint_when_forced_unhealthy(monkeypatch):
    monkeypatch.setenv("FORCE_UNHEALTHY", "true")

    response = client.get("/health")

    assert response.status_code == 503
    assert response.json() == {
        "detail" : "Service intentionally unhealthy"
    }