use axum::{Json, Router, routing::get};
use serde::Serialize;
use std::net::SocketAddr;

#[derive(Serialize)]
struct Health {
    status: &'static str,
    service: &'static str,
}

#[derive(Serialize)]
struct Contoh {
    pesan: &'static str,
    status_fasad: &'static str,
    rujukan_auth: &'static str,
}

async fn healthz() -> Json<Health> {
    Json(Health {
        status: "ok",
        service: "titipo-backend-service",
    })
}

async fn contoh() -> Json<Contoh> {
    Json(Contoh {
        pesan: "Contoh GET TitipO — STATUS stub, belum data produksi.",
        status_fasad: "stub — facade ke lumbung",
        rujukan_auth: "docs/auth.md (JWT aud=titipo + service key titipo->lumbung)",
    })
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter("titipo_backend_service=debug,tower_http=debug")
        .init();

    let app = Router::new().route("/healthz", get(healthz)).route("/v1/contoh", get(contoh));

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    tracing::info!("titipo-backend-service (stub) mendengar di {}", addr);
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
