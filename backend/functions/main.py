from firebase_functions import https_fn
from firebase_functions.options import set_global_options

from firebase_admin import initialize_app
from firebase_admin import firestore

from google.cloud.firestore_v1 import SERVER_TIMESTAMP

import json
import random
from datetime import datetime

set_global_options(max_instances=10)

initialize_app()


# =========================
# DB
# =========================
def get_db():
    return firestore.client()


# =========================
# CORS
# =========================
CORS_HEADERS = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
}


def options_response():
    return https_fn.Response(
        "",
        status=204,
        headers=CORS_HEADERS
    )


def cors_response(body="", status=200, content_type="application/json"):
    return https_fn.Response(
        body,
        status=status,
        content_type=content_type,
        headers=CORS_HEADERS
    )


# =====================
# PROJETOS
# =====================
@https_fn.on_request()
def projetos(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    if req.method == "POST":
        data = req.get_json()

        doc_ref = db.collection("projetos").document()
        doc_ref.set(data)

        return cors_response(
            json.dumps({"id": doc_ref.id, **data}),
            status=201
        )

    if req.method == "GET":
        docs = db.collection("projetos").stream()
        data = [{"id": d.id, **d.to_dict()} for d in docs]

        return cors_response(json.dumps(data, default=str))


# =====================
# PROJETO
# =====================
@https_fn.on_request()
def projeto(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    projeto_id = req.args.get("id")
    if not projeto_id:
        return cors_response(json.dumps({"error": "Missing id"}), status=400)

    doc_ref = db.collection("projetos").document(projeto_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return cors_response(json.dumps({"error": "Not found"}), status=404)

        return cors_response(json.dumps({"id": doc.id, **doc.to_dict()}, default=str))

    if req.method in ["PUT", "PATCH"]:
        data = req.get_json()
        doc_ref.update(data)

        updated = doc_ref.get()

        return cors_response(json.dumps({
            "message": "Updated",
            "data": {"id": updated.id, **updated.to_dict()}
        }, default=str))

    if req.method == "DELETE":
        doc_ref.delete()
        return cors_response(json.dumps({"message": "Deleted"}))


# =====================
# MOCK PROJETOS COMPLETO 🔥
# =====================
@https_fn.on_request()
def projetos_mock_full(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    if req.method == "POST":

        tags_pool = ["teste", "urbano", "saúde", "educação", "infra", "digital"]

        projeto = {
            "titulo": f"Projeto {random.randint(1, 1000)}",
            "tags": random.sample(tags_pool, k=1),
            "quando_sera_executado": str(random.randint(2026, 2030)),
            "createdAt": str(datetime.utcnow()),
            "updatedAt": str(datetime.utcnow()),

            "localidades_afetadas": random.choice([
                "Todo o município",
                "Zona urbana",
                "Zona rural",
                "Centro"
            ]),

            "data_publicacao": f"2026-06-{random.randint(1,28):02d}",

            "como_sera_executado": "Execução automática para testes",
            "relevancia": random.choice(["Alta", "Média", "Baixa"]),
            "autoria": [],

            "ideia_central": "Ideia central gerada automaticamente",
            "likes": random.randint(0, 500),
            "dislikes": random.randint(0, 100),

            "justificativa_relevancia": "Projeto relevante para a população",
            "textoOriginalUrl": "https://example.com/projeto",
            "status": random.choice(["Em discussão", "Aprovado", "Em análise"])
        }

        doc_ref = db.collection("projetos").document()
        doc_ref.set(projeto)

        return cors_response(json.dumps({
            "id": doc_ref.id,
            **projeto
        }, default=str))

    return cors_response(json.dumps({"error": "Method not allowed"}), status=405)


# =====================
# VEREADORES
# =====================
@https_fn.on_request()
def vereadores(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    if req.method == "GET":
        docs = db.collection("vereadores").stream()
        return cors_response(json.dumps([{"id": d.id, **d.to_dict()} for d in docs], default=str))

    if req.method == "POST":
        data = req.get_json()
        doc_ref = db.collection("vereadores").document()
        doc_ref.set(data)

        return cors_response(json.dumps({"id": doc_ref.id, **data}), status=201)


# =====================
# VEREADOR
# =====================
@https_fn.on_request()
def vereador(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    vereador_id = req.args.get("id")
    if not vereador_id:
        return cors_response(json.dumps({"error": "Missing id"}), status=400)

    doc_ref = db.collection("vereadores").document(vereador_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return cors_response(json.dumps({"error": "Not found"}), status=404)

        return cors_response(json.dumps({"id": doc.id, **doc.to_dict()}, default=str))


# =====================
# PARTIDOS
# =====================
@https_fn.on_request()
def partidos(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    if req.method == "GET":
        docs = db.collection("partidos").stream()
        return cors_response(json.dumps([{"id": d.id, **d.to_dict()} for d in docs], default=str))

    if req.method == "POST":
        data = req.get_json()
        doc_ref = db.collection("partidos").document()
        doc_ref.set(data)

        return cors_response(json.dumps({"id": doc_ref.id, **data}), status=201)


# =====================
# PARTIDO
# =====================
@https_fn.on_request()
def partido(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    partido_id = req.args.get("id")
    if not partido_id:
        return cors_response(json.dumps({"error": "Missing id"}), status=400)

    doc_ref = db.collection("partidos").document(partido_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return cors_response(json.dumps({"error": "Not found"}), status=404)

        return cors_response(json.dumps({"id": doc.id, **doc.to_dict()}, default=str))


# =====================
# RELAÇÕES
# =====================
@https_fn.on_request()
def partido_vereadores(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    partido_id = req.args.get("id")
    docs = db.collection("vereadores").where("partidoId", "==", partido_id).stream()

    return cors_response(json.dumps([{"id": d.id, **d.to_dict()} for d in docs], default=str))


@https_fn.on_request()
def partido_projetos(req):
    db = get_db()

    if req.method == "OPTIONS":
        return options_response()

    partido_id = req.args.get("id")

    partido_doc = db.collection("partidos").document(partido_id).get()
    if not partido_doc.exists:
        return cors_response(json.dumps({"error": "Not found"}), status=404)

    sigla = partido_doc.to_dict().get("sigla")

    vereadores = db.collection("vereadores").where("partido", "==", sigla).stream()
    vereadores_ids = {v.id for v in vereadores}

    projetos = db.collection("projetos").stream()

    result = []
    for p in projetos:
        data = p.to_dict()
        if any(v in vereadores_ids for v in data.get("autoriaIds", [])):
            result.append({"id": p.id, **data})

    return cors_response(json.dumps(result, default=str))