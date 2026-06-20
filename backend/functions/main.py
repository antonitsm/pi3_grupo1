from firebase_functions import https_fn
from firebase_functions.options import set_global_options

from firebase_admin import initialize_app
from firebase_admin import firestore

from google.cloud.firestore_v1 import SERVER_TIMESTAMP
from google.cloud.exceptions import Conflict

import requests
import random
import json
import re
import os
import base64

set_global_options(max_instances=10)

initialize_app()

# =========================
# FIX: Firestore lazy init
# =========================
def get_db():
    return firestore.client()


GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")


# =====================
# PROJETOS
# =====================

@https_fn.on_request()
def projetos(req):
    db = get_db()

    if req.method == "POST":
        data = req.get_json()

        doc_ref = db.collection("projetos").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({"id": doc_ref.id, **data}),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("projetos").stream()

        data = [
            {"id": doc.id, **doc.to_dict()}
            for doc in docs
        ]

        return https_fn.Response(
            json.dumps(data, default=str),
            content_type="application/json"
        )


@https_fn.on_request()
def projeto(req):
    db = get_db()

    projeto_id = req.args.get("id")
    if not projeto_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    doc_ref = db.collection("projetos").document(projeto_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Projeto não encontrado"}),
                status=404,
                content_type="application/json"
            )

        return https_fn.Response(
            json.dumps({"id": doc.id, **doc.to_dict()}, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        data = req.get_json()
        doc_ref.update(data)

        updated = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Projeto atualizado",
                "data": {"id": updated.id, **updated.to_dict()}
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc_ref.delete()

        return https_fn.Response(
            json.dumps({"message": "Projeto removido"}),
            content_type="application/json"
        )


# =====================
# VEREADORES
# =====================

@https_fn.on_request()
def vereadores(req):
    db = get_db()

    if req.method == "POST":
        data = req.get_json()

        doc_ref = db.collection("vereadores").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({"id": doc_ref.id, **data}),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("vereadores").stream()

        return https_fn.Response(
            json.dumps(
                [{"id": d.id, **d.to_dict()} for d in docs],
                default=str
            ),
            content_type="application/json"
        )


@https_fn.on_request()
def vereador(req):
    db = get_db()

    vereador_id = req.args.get("id")
    if not vereador_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    doc_ref = db.collection("vereadores").document(vereador_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Vereador não encontrado"}),
                status=404,
                content_type="application/json"
            )

        return https_fn.Response(
            json.dumps({"id": doc.id, **doc.to_dict()}, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        data = req.get_json()
        doc_ref.update(data)

        updated = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Vereador atualizado",
                "data": {"id": updated.id, **updated.to_dict()}
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc_ref.delete()

        return https_fn.Response(
            json.dumps({"message": "Vereador removido"}),
            content_type="application/json"
        )


# =====================
# PARTIDOS
# =====================

@https_fn.on_request()
def partidos(req):
    db = get_db()

    if req.method == "POST":
        data = req.get_json()

        doc_ref = db.collection("partidos").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({"id": doc_ref.id, **data}),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("partidos").stream()

        return https_fn.Response(
            json.dumps(
                [{"id": d.id, **d.to_dict()} for d in docs],
                default=str
            ),
            content_type="application/json"
        )


@https_fn.on_request()
def partido(req):
    db = get_db()

    partido_id = req.args.get("id")
    if not partido_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    doc_ref = db.collection("partidos").document(partido_id)

    if req.method == "GET":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Partido não encontrado"}),
                status=404,
                content_type="application/json"
            )

        return https_fn.Response(
            json.dumps({"id": doc.id, **doc.to_dict()}, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        data = req.get_json()
        doc_ref.update(data)

        updated = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Partido atualizado",
                "data": {"id": updated.id, **updated.to_dict()}
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc_ref.delete()

        return https_fn.Response(
            json.dumps({"message": "Partido removido"}),
            content_type="application/json"
        )


# =====================
# CONSULTAS RELACIONADAS
# =====================

@https_fn.on_request()
def partido_vereadores(req):
    db = get_db()

    partido_id = req.args.get("id")
    if not partido_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    docs = db.collection("vereadores").where("partidoId", "==", partido_id).stream()

    return https_fn.Response(
        json.dumps([{"id": d.id, **d.to_dict()} for d in docs], default=str),
        content_type="application/json"
    )


@https_fn.on_request()
def partido_projetos(req):
    db = get_db()

    partido_id = req.args.get("id")
    if not partido_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    partido_doc = db.collection("partidos").document(partido_id).get()

    if not partido_doc.exists:
        return https_fn.Response(
            json.dumps({"error": "Partido não encontrado"}),
            status=404,
            content_type="application/json"
        )

    sigla = partido_doc.to_dict()["sigla"]

    vereadores = db.collection("vereadores").where("partido", "==", sigla).stream()
    vereadores_ids = {v.id for v in vereadores}

    projetos = db.collection("projetos").stream()

    result = []

    for p in projetos:
        data = p.to_dict()
        if any(v in vereadores_ids for v in data.get("autoriaIds", [])):
            result.append({"id": p.id, **data})

    return https_fn.Response(
        json.dumps(result, default=str),
        content_type="application/json"
    )


# =====================
# MOCKS + ARCHIVE (mesma lógica, só adiciona db local)
# =====================

@https_fn.on_request()
def mock_projeto(req):
    db = get_db()

    novo = {
        "titulo": f"Projeto {random.randint(1,1000)}",
        "status": "Em discussão",
        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP
    }

    _, ref = db.collection("projetos").add(novo)

    return https_fn.Response(
        json.dumps({"id": ref.id}),
        content_type="application/json"
    )