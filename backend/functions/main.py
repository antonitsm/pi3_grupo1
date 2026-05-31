from firebase_functions import https_fn
from firebase_functions.options import set_global_options

from firebase_admin import initialize_app
from firebase_admin import firestore

from google.cloud.firestore_v1 import SERVER_TIMESTAMP

from curl_cffi import requests
import random
import json

set_global_options(max_instances=10)

initialize_app()

db = firestore.client()


# =====================
# PROJETOS
# =====================

@https_fn.on_request()
def projetos(req):
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

    # GET - Fetch project
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

    # PUT/PATCH - Update project
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

    # DELETE - Delete project
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


@https_fn.on_request()
def mock_projeto(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    statuses = [
        "emDiscussao",
        "aprovado",
        "reprovado"
    ]

    novo_projeto = {
        "titulo": f"Projeto {random.randint(1, 1000)}",
        "descricao": "Descrição gerada automaticamente para teste",
        "textoOriginalUrl": "https://example.com/projeto",
        "resumoIa": "Resumo mock",
        "status": random.choice(statuses),
        "autores": [],
        "feedbacks": [],
        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP,
    }

    _, doc_ref = db.collection("projetos").add(novo_projeto)

    return https_fn.Response(
        json.dumps({
            "message": "Projeto mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )


# =====================
# VEREADORES
# =====================

@https_fn.on_request()
def vereadores(req):
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


@https_fn.on_request()
def mock_vereador(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    novo_vereador = {
        "nome": f"Vereador {random.randint(1, 1000)}",
        "partido": "PARTIDO TESTE",
        "fotoUrl": "https://example.com/foto.jpg",
        "biografia": "Biografia gerada automaticamente",
        "email": "vereador@example.com",
        "telefone": "(11) 99999-9999",
        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP,
    }

    _, doc_ref = db.collection("vereadores").add(novo_vereador)

    return https_fn.Response(
        json.dumps({
            "message": "Vereador mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )


# =====================
# PARTIDOS
# =====================


@https_fn.on_request()
def partidos(req):
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


@https_fn.on_request()
def mock_partido(req):
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    siglas = ["PT", "PL", "MDB", "PSD", "UNIÃO", "PSB", "PP"]

    novo_partido = {
        "nome": f"Partido {random.randint(1, 1000)}",
        "sigla": random.choice(siglas),
        "numero": random.randint(10, 99),
        "descricao": "Partido gerado automaticamente para testes",
        "logoUrl": "https://example.com/logo.png",
        "createdAt": SERVER_TIMESTAMP,
        "updatedAt": SERVER_TIMESTAMP,
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

@https_fn.on_request()
def extrair_pdf(req):
    doc_id = req.args.get("id")

    if not doc_id:
        return https_fn.Response(
            "Missing id parameter",
            status=400
        )

    try:
        doc_id = int(doc_id)
    except ValueError:
        return https_fn.Response(
            "id must be an integer",
            status=400
        )

    url = (
        f"https://www.camaraita.sc.gov.br/ciga/proposicao_print_pdf.php?item={doc_id}"
    )

    try:
        response = requests.get(
            url,
            impersonate="chrome136",
            timeout=30
        )

        return https_fn.Response(
            response.content,  # <- binary
            status=response.status_code,
            content_type="application/pdf"
        )

    except Exception as e:
        return https_fn.Response(
            f"Request failed: {str(e)}",
            status=500
        )

