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

set_global_options(max_instances=10)

initialize_app()

db = firestore.client()


# =====================
# PROJETOS
# =====================

# ==================================================
# POST /projetos
# GET /projetos
# ==================================================
"""
Create a new project (POST) or return a list of all
projects stored in Firestore (GET).
"""
@https_fn.on_request()
def projetos(req):
    if req.method == "POST":
        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        if not data:
            return https_fn.Response(
                json.dumps({"error": "Request body is required"}),
                status=400,
                content_type="application/json"
            )

        doc_ref = db.collection("projetos").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({
                "id": doc_ref.id,
                **data
            }),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("projetos").stream()

        data = [
            {
                "id": doc.id,
                **doc.to_dict()
            }
            for doc in docs
        ]

        return https_fn.Response(
            json.dumps(data, default=str),
            content_type="application/json"
        )

# ==================================================
# GET /projeto?id=<project_id>
# PUT /projeto?id=<project_id>
# PATCH /projeto?id=<project_id>
# DELETE /projeto?id=<project_id>
# ==================================================
"""
Manage a single project.
"""
@https_fn.on_request()
def projeto(req):
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
            json.dumps({
                "id": doc.id,
                **doc.to_dict()
            }, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Projeto não encontrado"}),
                status=404,
                content_type="application/json"
            )

        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        doc_ref.update(data)

        updated_doc = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Projeto atualizado com sucesso",
                "data": {
                    "id": updated_doc.id,
                    **updated_doc.to_dict()
                }
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Projeto não encontrado"}),
                status=404,
                content_type="application/json"
            )

        doc_ref.delete()

        return https_fn.Response(
            json.dumps({
                "message": "Projeto removido com sucesso"
            }),
            content_type="application/json"
        )

    return https_fn.Response(
        json.dumps({"error": "Method not allowed"}),
        status=405,
        content_type="application/json"
    )




# =====================
# VEREADORES
# =====================

# ==================================================
# GET /vereadores
# POST /vereadores
# ==================================================
"""
Create a new council member (POST) or return a list
of all council members stored in Firestore (GET).
"""
@https_fn.on_request()
def vereadores(req):
    if req.method == "POST":
        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        if not data:
            return https_fn.Response(
                json.dumps({"error": "Request body is required"}),
                status=400,
                content_type="application/json"
            )

        doc_ref = db.collection("vereadores").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({
                "id": doc_ref.id,
                **data
            }),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("vereadores").stream()

        data = [
            {
                "id": doc.id,
                **doc.to_dict()
            }
            for doc in docs
        ]

        return https_fn.Response(
            json.dumps(data, default=str),
            content_type="application/json"
        )

    return https_fn.Response(
        json.dumps({"error": "Method not allowed"}),
        status=405,
        content_type="application/json"
    )


# ==================================================
# GET /vereador?id=<vereador_id>
# PUT /vereador?id=<vereador_id>
# PATCH /vereador?id=<vereador_id>
# DELETE /vereador?id=<vereador_id>
# ==================================================
"""
Manage a single council member.
"""
@https_fn.on_request()
def vereador(req):
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
            json.dumps({
                "id": doc.id,
                **doc.to_dict()
            }, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Vereador não encontrado"}),
                status=404,
                content_type="application/json"
            )

        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        doc_ref.update(data)

        updated_doc = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Vereador atualizado com sucesso",
                "data": {
                    "id": updated_doc.id,
                    **updated_doc.to_dict()
                }
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Vereador não encontrado"}),
                status=404,
                content_type="application/json"
            )

        doc_ref.delete()

        return https_fn.Response(
            json.dumps({
                "message": "Vereador removido com sucesso"
            }),
            content_type="application/json"
        )

    return https_fn.Response(
        json.dumps({"error": "Method not allowed"}),
        status=405,
        content_type="application/json"
    )


# =====================
# PARTIDOS
# =====================

# ==================================================
# GET /partidos
# POST /partidos
# ==================================================
"""
Create a new political party (POST) or return a list
of all political parties (GET).
"""
@https_fn.on_request()
def partidos(req):
    if req.method == "POST":
        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        if not data:
            return https_fn.Response(
                json.dumps({"error": "Request body is required"}),
                status=400,
                content_type="application/json"
            )

        doc_ref = db.collection("partidos").document()
        doc_ref.set(data)

        return https_fn.Response(
            json.dumps({
                "id": doc_ref.id,
                **data
            }),
            status=201,
            content_type="application/json"
        )

    elif req.method == "GET":
        docs = db.collection("partidos").stream()

        data = [
            {
                "id": doc.id,
                **doc.to_dict()
            }
            for doc in docs
        ]

        return https_fn.Response(
            json.dumps(data, default=str),
            content_type="application/json"
        )

    return https_fn.Response(
        json.dumps({"error": "Method not allowed"}),
        status=405,
        content_type="application/json"
    )

# ==================================================
# GET /partido?id=<partido_id>
# PUT /partido?id=<partido_id>
# PATCH /partido?id=<partido_id>
# DELETE /partido?id=<partido_id>
# ==================================================
"""
Manage a single political party.
"""
@https_fn.on_request()
def partido(req):
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
            json.dumps({
                "id": doc.id,
                **doc.to_dict()
            }, default=str),
            content_type="application/json"
        )

    elif req.method in ["PUT", "PATCH"]:
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Partido não encontrado"}),
                status=404,
                content_type="application/json"
            )

        try:
            data = req.get_json()
        except Exception:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON body"}),
                status=400,
                content_type="application/json"
            )

        doc_ref.update(data)

        updated_doc = doc_ref.get()

        return https_fn.Response(
            json.dumps({
                "message": "Partido atualizado com sucesso",
                "data": {
                    "id": updated_doc.id,
                    **updated_doc.to_dict()
                }
            }, default=str),
            content_type="application/json"
        )

    elif req.method == "DELETE":
        doc = doc_ref.get()

        if not doc.exists:
            return https_fn.Response(
                json.dumps({"error": "Partido não encontrado"}),
                status=404,
                content_type="application/json"
            )

        doc_ref.delete()

        return https_fn.Response(
            json.dumps({
                "message": "Partido removido com sucesso"
            }),
            content_type="application/json"
        )

    return https_fn.Response(
        json.dumps({"error": "Method not allowed"}),
        status=405,
        content_type="application/json"
    )


# =====================
# OUTRAS QUERIES
# =====================

# ==================================================
# GET /partido_vereadores?id=<partido_id>
# ==================================================
"""
Returns all council members belonging to a party.
"""
@https_fn.on_request()
def partido_vereadores(req):
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

    docs = (
        db.collection("vereadores")
        .where("partidoId", "==", partido_id)
        .stream()
    )

    vereadores = [
        {
            "id": doc.id,
            **doc.to_dict()
        }
        for doc in docs
    ]

    return https_fn.Response(
        json.dumps(vereadores, default=str),
        content_type="application/json"
    )

# ==================================================
# GET /partido_projetos?id=<partido_id>
# ==================================================
"""
Returns all projects authored by council members
associated with the given party.
"""
@https_fn.on_request()
def partido_projetos(req):
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

    vereadores_docs = (
        db.collection("vereadores")
        .where("partido", "==", sigla)
        .stream()
    )

    vereador_ids = {
        doc.id
        for doc in vereadores_docs
    }

    projetos_docs = db.collection("projetos").stream()

    projetos = []

    for doc in projetos_docs:
        projeto = doc.to_dict()

        autoria_ids = projeto.get(
            "autoriaIds",
            []
        )

        if any(
            vereador_id in vereador_ids
            for vereador_id in autoria_ids
        ):
            projetos.append({
                "id": doc.id,
                **projeto
            })

    return https_fn.Response(
        json.dumps(projetos, default=str),
        content_type="application/json"
    )


# =====================
# MOCKS
# =====================

# ==================================================
# POST /mock_projeto
# ==================================================
"""
Creates a randomly generated test project.
"""
@https_fn.on_request()
def mock_projeto(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    novo_projeto = {
        "titulo": f"Projeto {random.randint(1,1000)}",
        "data_publicacao": "2026-06-01",
        "status": random.choice([
            "Em discussão",
            "Aprovado",
            "Rejeitado"
        ]),
        "ideia_central": "Ideia central gerada automaticamente",
        "localidades_afetadas": "Todo o município",
        "quando_sera_executado": "2027",
        "como_sera_executado": "Execução automática para testes",
        "autoria": [],
        "relevancia": "Alta",
        "justificativa_relevancia":
            "Projeto relevante para a população",
        "likes": random.randint(0,300),
        "dislikes": random.randint(0,50),
        "tags": ["teste"],
        "textoOriginalUrl": "https://example.com/projeto",

        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP
    }

    _, doc_ref = db.collection("projetos").add(novo_projeto)

    return https_fn.Response(
        json.dumps({
            "message": "Projeto mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )

# ==================================================
# POST /mock_vereador
# ==================================================
"""
Creates a randomly generated test council member.
"""
@https_fn.on_request()
def mock_vereador(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    novo_vereador = {
        "nome": f"Vereador {random.randint(1,1000)}",
        "partido": random.choice([
            "PT",
            "PL",
            "MDB",
            "PDT",
            "PSB"
        ]),
        "foto": "",
        "biografia": "Biografia gerada automaticamente",
        "projetos": [],
        "projetos_aprovados": random.randint(0,20),
        "contato": "vereador@example.com",

        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP
    }

    _, doc_ref = db.collection("vereadores").add(novo_vereador)

    return https_fn.Response(
        json.dumps({
            "message": "Vereador mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )

# ==================================================
# POST /mock_partido
# ==================================================
"""
Creates a randomly generated political party.
"""
@https_fn.on_request()
def mock_partido(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    partidos = [
        ("Partido dos Trabalhadores", "PT", 1980),
        ("Partido Liberal", "PL", 2006),
        ("Movimento Democrático Brasileiro", "MDB", 1966),
        ("Partido Democrático Trabalhista", "PDT", 1979),
        ("Partido Socialista Brasileiro", "PSB", 1947)
    ]

    nome, sigla, ano = random.choice(partidos)

    novo_partido = {
        "nome": nome,
        "sigla": sigla,
        "ano_criacao": ano,

        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP
    }

    _, doc_ref = db.collection("partidos").add(novo_partido)

    return https_fn.Response(
        json.dumps({
            "message": "Partido mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )

# =====================
# PROCESSAR
# =====================

# ==================================================
# GET /archive
# ==================================================
"""
Returns all archive records currently stored.

Archive records represent municipal acts collected
from the Diário Municipal.
"""
@https_fn.on_request()
def archive(req):
    docs = db.collection("archive").stream()

    data = [
        {
            "id": doc.id,
            **doc.to_dict()
        }
        for doc in docs
    ]

    return https_fn.Response(
        json.dumps(data, default=str),
        content_type="application/json"
    )

# ==================================================
# POST /populate_archive
# ==================================================
"""
Imports municipal act references from the Diário Municipal
into the archive collection.

The function:
    1. Crawls the Diário Municipal pages.
    2. Extracts act IDs.
    3. Stores new archive records.
    4. Skips existing records.
"""
@https_fn.on_request()
def populate_archive(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    created = 0
    skipped = 0
    page = 1

    while True:
        url = (
            "https://diariomunicipal.sc.gov.br/"
            f"?AtoNormativoASolrDocument_page={page}"
            "&ajax=leis-municipio"
            "&id=24"
            "&pageSize=100"
            "&r=site%2FmunView"
        )

        print(f"Processing page {page}")

        try:
            response = requests.get(
                url,
                timeout=30,
                headers={
                    "User-Agent": "Mozilla/5.0"
                }
            )

            response.raise_for_status()

        except Exception as e:
            print(f"Failed page {page}: {e}")
            break

        ids = set(
            re.findall(
                r'/atos/(\d+)',
                response.text
            )
        )

        page_count = len(ids)

        print(f"Found {page_count} acts")

        # No results = end of pagination
        if page_count == 0:
            break

        page_created = 0

        for ato_id in ids:
            doc_ref = (
                db.collection("archive")
                .document(ato_id)
            )

        try:
            doc_ref.create({
                "id": ato_id,
                "url": f"https://diariomunicipal.sc.gov.br/atos/{ato_id}",
                "date": None,
                "createdAt": SERVER_TIMESTAMP,
                "updatedAt": SERVER_TIMESTAMP
            })

            created += 1

        except Conflict:
            skipped += 1

            doc_ref.set({
                "id": ato_id,
                "url": f"https://diariomunicipal.sc.gov.br/atos/{ato_id}",
                "date": None,
                "createdAt": SERVER_TIMESTAMP,
                "updatedAt": SERVER_TIMESTAMP
            })

            created += 1
            page_created += 1

        print(
            f"Page {page}: "
            f"created={page_created}"
        )

        # Optional optimization:
        # stop when an entire page is already imported
        if page_created == 0:
            print(
                "All records on this page already exist. Stopping."
            )
            break

        page += 1

        if page_count < 100:
            break

    return https_fn.Response(
        json.dumps({
            "success": True,
            "created": created,
            "skipped": skipped,
            "pages_processed": page
        }),
        content_type="application/json"
    )

# ==================================================
# POST /process_archive?id=<archive_id>
# ==================================================
"""
Processes a specific archive record.
TODO: integrate AI.
"""
@https_fn.on_request()
def process_archive(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    archive_id = req.args.get("id")

    if not archive_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    doc_ref = db.collection("archive").document(archive_id)
    doc = doc_ref.get()

    if not doc.exists:
        return https_fn.Response(
            json.dumps({"error": "Archive not found"}),
            status=404,
            content_type="application/json"
        )

    try:
        archive_data = doc.to_dict()

        # TODO:
        # Put your requests + AI processing here
        if True:

            doc_ref.update({
                "date": SERVER_TIMESTAMP,
                "updatedAt": SERVER_TIMESTAMP
            })

            return https_fn.Response(
                json.dumps({
                    "success": True,
                    "id": archive_id
                }),
                content_type="application/json"
            )

        return https_fn.Response(
            json.dumps({
                "success": False,
                "id": archive_id
            }),
            content_type="application/json"
        )

    except Exception as e:
        return https_fn.Response(
            json.dumps({
                "error": str(e)
            }),
            status=500,
            content_type="application/json"
        )