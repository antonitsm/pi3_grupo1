from firebase_functions import https_fn, scheduler_fn

from firebase_functions.options import set_global_options

from firebase_functions import firestore_fn
from firebase_admin import messaging

from google.cloud.firestore_v1 import Query
from firebase_admin import initialize_app
from firebase_admin import firestore

from google.cloud.firestore_v1 import SERVER_TIMESTAMP
from google.cloud.exceptions import Conflict

from firebase_functions.options import SecretParam

import requests
import json
import re
import base64
import time
from functools import wraps


def enable_cors(func):

    @wraps(func)
    def wrapper(req, *args, **kwargs):

        if req.method == "OPTIONS":
            response = https_fn.Response(
                "",
                status=204
            )

        else:
            response = func(req, *args, **kwargs)


        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = (
            "GET, POST, PUT, PATCH, DELETE, OPTIONS"
        )
        response.headers["Access-Control-Allow-Headers"] = (
            "Content-Type"
        )

        return response

    return wrapper

set_global_options(max_instances=10)

initialize_app()

GOOGLE_API_KEY = SecretParam("GOOGLE_API_KEY")

def get_db():
    return firestore.client()

# =====================
# PROJETOS
# =====================

# ==================================================
# POST /projetos
# GET /projetos
# ==================================================

"""
Cria um novo projeto (POST) ou retorna todos os projetos cadastrados (GET).
"""
@https_fn.on_request()
@enable_cors
def projetos(req):
    db = get_db()
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
        docs = (
            db.collection("projetos")
            .order_by("createdAt", direction=Query.DESCENDING)
            .stream()
        )

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
Gerencia um projeto específico.
"""
@https_fn.on_request()
@enable_cors
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


# ==================================================
# PATCH /projeto_reacao?id=<project_id>
# ==================================================

@https_fn.on_request()
@enable_cors
def projeto_reacao(req):
    db = get_db()

    projeto_id = req.args.get("id")

    if not projeto_id:
        return https_fn.Response(
            json.dumps({"error": "Missing id"}),
            status=400,
            content_type="application/json"
        )

    if req.method != "PATCH":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    try:
        data = req.get_json()
    except Exception:
        return https_fn.Response(
            json.dumps({"error": "Invalid JSON"}),
            status=400,
            content_type="application/json"
        )

    tipo = data.get("tipo")

    if tipo not in ["like", "dislike"]:
        return https_fn.Response(
            json.dumps({"error": "Tipo inválido"}),
            status=400,
            content_type="application/json"
        )

    doc_ref = db.collection("projetos").document(projeto_id)

    doc = doc_ref.get()

    if not doc.exists:
        return https_fn.Response(
            json.dumps({"error": "Projeto não encontrado"}),
            status=404,
            content_type="application/json"
        )

    campo = "likes" if tipo == "like" else "dislikes"

    valor_atual = doc.to_dict().get(campo, 0)

    novo_valor = valor_atual + 1

    doc_ref.update({
        campo: novo_valor
    })

    return https_fn.Response(
        json.dumps({
            "success": True,
            campo: novo_valor
        }),
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
Cria um novo vereador (POST) ou retorna todos os vereadores cadastrados (GET).
"""
@https_fn.on_request()
@enable_cors
def vereadores(req):
    db = get_db()
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
Gerencia um vereador específico.
"""
@https_fn.on_request()
@enable_cors
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
Cria um novo partido (POST) ou retorna todos os partidos cadastrados (GET).
"""
@https_fn.on_request()
@enable_cors
def partidos(req):
    db = get_db()
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
Gerencia um partido específico.
"""
@https_fn.on_request()
@enable_cors
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
# CONSULTAS RELACIONADAS
# =====================

# ==================================================
# GET /partido_vereadores?id=<partido_id>
# ==================================================

"""
Retorna todos os vereadores que pertencem a um partido.
"""
@https_fn.on_request()
@enable_cors
def partido_vereadores(req):
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
Retorna todos os projetos criados por vereadores de um partido.
"""
@https_fn.on_request()
@enable_cors
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
# DADOS DE TESTE
# =====================

# ==================================================
# POST /mock_clear
# ==================================================

"""
Remove todos os registros de teste.
"""
@https_fn.on_request()
@enable_cors
def mock_clear(req):
    db = get_db()

    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    collections = [
        "projetos",
        "vereadores",
        "partidos",
        "archive",
    ]

    deleted = {}

    for collection_name in collections:
        count = 0
        batch = db.batch()

        for doc in db.collection(collection_name).stream():
            batch.delete(doc.reference)
            count += 1

            # Firestore batches are limited to 500 operations
            if count % 500 == 0:
                batch.commit()
                batch = db.batch()

        # Commit any remaining deletes
        if count % 500 != 0:
            batch.commit()

        deleted[collection_name] = count

    return https_fn.Response(
        json.dumps({
            "message": "Todos os dados de teste foram removidos.",
            "deleted": deleted
        }),
        content_type="application/json"
    )


# =====================
# PROCESSAMENTO DE ARQUIVOS
# =====================

# ==================================================
# GET /archive
# ==================================================

"""
Retorna todos os registros da coleção archive.
"""
@https_fn.on_request()
@enable_cors
def archive(req):
    db = get_db()
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
Importa atos municipais do Diário Municipal para a coleção archive.

Fluxo:
1. Acessa as páginas do Diário Municipal.
2. Coleta os IDs dos atos.
3. Salva novos registros.
4. Ignora registros já existentes.
"""
@https_fn.on_request()
@enable_cors
def populate_archive(req):
    db = get_db()
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
                timeout=90,
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
                r"/atos/(\d+)",
                response.text
            )
        )

        page_count = len(ids)

        print(f"Found {page_count} acts")

        if page_count == 0:
            break

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
                    "processed": False,
                    "createdAt": SERVER_TIMESTAMP,
                    "updatedAt": SERVER_TIMESTAMP
                })

                created += 1

            except Conflict:
                skipped += 1

        page += 1

        # Last page
        if page_count < 100:
            break

    return https_fn.Response(
        json.dumps({
            "success": True,
            "created": created,
            "skipped": skipped,
            "pages_processed": page - 1
        }),
        content_type="application/json"
    )

# ==================================================
# GET /archives_pending
# ==================================================

"""
Retorna todos os registros que ainda não foram processados.
"""
@https_fn.on_request()
@enable_cors
def archives_pending(req):
    db = get_db()
    docs = db.collection("archive").stream()

    data = [
        {
            "id": doc.id,
            **doc.to_dict()
        }
        for doc in docs
        if doc.to_dict().get("processed") != True
    ]

    return https_fn.Response(
        json.dumps(data, default=str),
        content_type="application/json"
    )

# ==================================================
# POST /process_archive?id=<archive_id>
# ==================================================

"""
Processa um registro específico da coleção archive.
"""
"""
Lê o PDF do ato municipal, usa IA para extrair informações
e cria um novo projeto automaticamente.
"""
@https_fn.on_request(
    secrets=[GOOGLE_API_KEY]
)
@enable_cors
def process_archive(req):
    db = get_db()
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
    
    print(f"[{archive_id}] Iniciando processamento")

    doc_ref = db.collection("archive").document(archive_id)
    doc = doc_ref.get()

    if not doc.exists:
        return https_fn.Response(
            json.dumps({"error": "Archive not found"}),
            status=404,
            content_type="application/json"
        )
        
    print(f"[{archive_id}] Documento encontrado no Firestore")

    try:
        archive_data = doc.to_dict()
        
        print(f"[{archive_id}] Chamando extract_project_with_ai")

        projeto_id = extract_project_with_ai(
            archive_id,
            archive_data
        )
        
        print(f"[{archive_id}] Projeto criado: {projeto_id}")

        doc_ref.update({
            "processed": True,
            "projetoId": projeto_id,
            "updatedAt": SERVER_TIMESTAMP
        })

        print(f"[{archive_id}] Archive atualizado como processado")
        
        return https_fn.Response(
            json.dumps({
                "success": True,
                "archiveId": archive_id,
                "projetoId": projeto_id
            }),
            content_type="application/json"
        )

    except Exception as e:
        import traceback

        print(f"[{archive_id}] ERRO durante o processamento")
        traceback.print_exc()

        return https_fn.Response(
            json.dumps({
                "error": str(e)
            }),
            status=500,
            content_type="application/json"
        )
    

def extract_project_with_ai(archive_id, archive_data):
    db = get_db()
    
    print(f"[{archive_id}] Iniciando extract_project_with_ai")
    
    for tentativa in range(3):
        try:
            response = requests.get(
                archive_data["url"],
                timeout=90,
                headers={"User-Agent": "Mozilla/5.0"}
            )
            response.raise_for_status()
            break

        except requests.exceptions.RequestException as e:
            print(f"[{archive_id}] Tentativa {tentativa + 1} falhou: {e}")

            if tentativa == 2:
                raise

            time.sleep(10)

    print(f"[{archive_id}] Página baixada com sucesso")
    
    pdf_urls = re.findall(
        r'https://[^"\'> ]+\.pdf',
        response.text
    )
    
    print(f"[{archive_id}] PDFs encontrados: {len(pdf_urls)}")

    original_pdf = next(
        (url for url in pdf_urls if "_extrato" not in url),
        None
    )
    
    if original_pdf is None:
        original_pdf = next(iter(pdf_urls), None)
    
    print(f"[{archive_id}] PDF escolhido: {original_pdf}")

    if not original_pdf:
        raise Exception("PDF original não encontrado")
    
    print(f"[{archive_id}] Baixando PDF")

    pdf_response = requests.get(original_pdf, timeout=90)
    pdf_response.raise_for_status()
    
    print(
    f"[{archive_id}] PDF baixado ({len(pdf_response.content)} bytes)"
)

    pdf_base64 = base64.b64encode(pdf_response.content).decode("utf-8")

    payload = {
        "contents": [{
            "parts": [
                {
                    "inline_data": {
                        "mime_type": "application/pdf",
                        "data": pdf_base64
                    }
                },
                {
                        "text": """
                    Você é um assistente especializado em simplificar projetos de lei e atos legislativos municipais para cidadãos comuns.

                    Analise cuidadosamente o PDF enviado.

                    Sua tarefa é extrair as informações mais importantes do documento utilizando linguagem simples, clara e objetiva.

                    Regras obrigatórias:

                    1. Não invente informações. Se algum dado não puder ser identificado, utilize "" para campos de texto ou [] para listas.

                    2. Não emita opiniões pessoais.

                    3. Mantenha o significado original do documento.

                    4. Utilize linguagem acessível, evitando termos jurídicos complexos.

                    5. Preencha os seguintes campos:

                    - titulo
                    - data_publicacao
                    - status
                    - ideia_central
                    - localidades_afetadas
                    - quando_sera_executado
                    - como_sera_executado
                    - autoria
                    - relevancia
                    - justificativa_relevancia
                    - tags

                    6. Para "relevancia", utilize apenas um dos valores:
                    - "Urgente/Importante"
                    - "Média relevância"
                    - "Baixa relevância"

                    7. A justificativa da relevância deve possuir apenas uma frase.

                    8. As tags devem conter entre 1 e 5 itens e utilizar apenas os seguintes valores:

                    [
                    "saúde",
                    "educação",
                    "segurança",
                    "mobilidade",
                    "transporte",
                    "trânsito",
                    "infraestrutura",
                    "obras",
                    "urbanismo",
                    "habitação",
                    "assistência_social",
                    "cultura",
                    "esporte",
                    "lazer",
                    "turismo",
                    "meio_ambiente",
                    "saneamento",
                    "economia",
                    "tributação",
                    "comércio",
                    "agricultura",
                    "tecnologia",
                    "acessibilidade",
                    "juventude",
                    "idosos",
                    "mulheres",
                    "crianças",
                    "animais",
                    "servidores",
                    "transparência",
                    "participação",
                    "política",
                    "legislação",
                    "orçamento"
                    ]

                    9. NÃO escreva explicações.

                    10. NÃO utilize Markdown.

                    11. NÃO utilize ```json.

                    12. Retorne APENAS um JSON válido exatamente neste formato:

                    {
                    "titulo": "",
                    "data_publicacao": "",
                    "status": "",
                    "ideia_central": "",
                    "localidades_afetadas": "",
                    "quando_sera_executado": "",
                    "como_sera_executado": "",
                    "autoria": [],
                    "relevancia": "",
                    "justificativa_relevancia": "",
                    "likes": 0,
                    "dislikes": 0,
                    "tags": []
                    }
                    """
                }
            ]
        }]
    }
    
    print(f"[{archive_id}] Enviando PDF para o Gemini")

    valor = GOOGLE_API_KEY.value

    print("repr:", repr(valor))
    print("tipo:", type(valor))
    print("len:", len(valor) if valor is not None else None)
    
    url = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    f"gemini-3.1-flash-lite:generateContent?key={valor}"
)

    print("URL termina com:", url[-25:])
    
    ai_response = requests.post(
    f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key={valor}",
    json=payload,
    timeout=60
)

    print("STATUS:", ai_response.status_code)
    print("HEADERS:", ai_response.headers)
    print(ai_response.json())

    ai_response.raise_for_status()
        
    print(
    f"[{archive_id}] Gemini respondeu {ai_response.status_code}"
)

    result = ai_response.json()
    
    print(f"[{archive_id}] Resposta JSON recebida do Gemini")

    if not result.get("candidates"):
        raise Exception("Gemini retornou resposta vazia")

    text = result["candidates"][0]["content"]["parts"][0]["text"]

    # remove markdown fences if Gemini adds them
    text = text.replace("```json", "").replace("```", "").strip()

    projeto_data = json.loads(text)
    
    projeto_data["textoOriginalUrl"] = original_pdf
    projeto_data["paginaOriginalUrl"] = archive_data["url"]
    
    print(f"[{archive_id}] Resposta do Gemini:")
    print(text[:500])
    print(f"[{archive_id}] JSON convertido com sucesso")

    projeto_data["archiveId"] = archive_id
    projeto_data["createdAt"] = SERVER_TIMESTAMP
    projeto_data["updatedAt"] = SERVER_TIMESTAMP

    defaults = {
        "titulo": "",
        "ideia_central": "",
        "localidades_afetadas": "",
        "status": "",
        "tags": [],
        "likes": 0,
        "dislikes": 0,
        "data_publicacao": "",

        "quando_sera_executado": "",
        "como_sera_executado": "",
        "autoria": [],
        "relevancia": "",
        "justificativa_relevancia": "",
        "textoOriginalUrl": "",
        "paginaOriginalUrl": "",
    }

    for key, default in defaults.items():
        if projeto_data.get(key) is None:
            projeto_data[key] = default

    if not isinstance(projeto_data["autoria"], list):
        projeto_data["autoria"] = []

    if not isinstance(projeto_data["titulo"], str):
        projeto_data["titulo"] = str(projeto_data["titulo"])

    if not isinstance(projeto_data["ideia_central"], str):
        projeto_data["ideia_central"] = str(projeto_data["ideia_central"])

    if not isinstance(projeto_data["localidades_afetadas"], str):
        projeto_data["localidades_afetadas"] = str(projeto_data["localidades_afetadas"])

    if not isinstance(projeto_data["status"], str):
        projeto_data["status"] = str(projeto_data["status"])

    if not isinstance(projeto_data["tags"], list):
        projeto_data["tags"] = []

    try:
        projeto_data["likes"] = int(projeto_data["likes"])
    except (TypeError, ValueError):
        projeto_data["likes"] = 0

    try:
        projeto_data["dislikes"] = int(projeto_data["dislikes"])
    except (TypeError, ValueError):
        projeto_data["dislikes"] = 0

    if not isinstance(projeto_data["data_publicacao"], str):
        projeto_data["data_publicacao"] = ""
        
    print(f"[{archive_id}] Salvando projeto no Firestore")

    projeto_ref = db.collection("projetos").document()
    projeto_ref.set(projeto_data)
    
    print(f"[{archive_id}] Projeto salvo")

    return projeto_ref.id


# ==================================================
# POST /test_archive?id=<archive_id>
# ==================================================

@https_fn.on_request(
    secrets=[GOOGLE_API_KEY]
)
@enable_cors
def test_archive(req):
    db = get_db()

    if req.method not in ["GET", "POST"]:
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

    print("=" * 60)
    print(f"[{archive_id}] TESTE INICIADO")

    doc = db.collection("archive").document(archive_id).get()

    if not doc.exists:
        print(f"[{archive_id}] Documento não encontrado")
        return https_fn.Response(
            json.dumps({"error": "Archive not found"}),
            status=404,
            content_type="application/json"
        )

    try:
        projeto_id = extract_project_with_ai(
            archive_id,
            doc.to_dict()
        )

        print(f"[{archive_id}] Projeto criado: {projeto_id}")

        return https_fn.Response(
            json.dumps({
                "success": True,
                "projectId": projeto_id
            }),
            content_type="application/json"
        )

    except Exception as e:
        print(f"[{archive_id}] ERRO:")
        print(type(e).__name__)
        print(str(e))

        return https_fn.Response(
            json.dumps({
                "success": False,
                "error": str(e)
            }),
            status=500,
            content_type="application/json"
        )


# =====================
# SCHEDULERS
# =====================


class FakeRequest:
    method = "POST"

    def __init__(self, **args):
        self.args = args

@scheduler_fn.on_schedule(
    schedule="every 24 hours",
    secrets=[GOOGLE_API_KEY]
    )
def hello_world(event: scheduler_fn.ScheduledEvent) -> None:
    print("Starting archive scheduler...")

    # Step 1: Populate archive with new acts
    try:
        response = populate_archive(FakeRequest())
        print("populate_archive finished")
        print(response.get_data(as_text=True))
    except Exception as e:
        print(f"populate_archive failed: {e}")

    # Step 2: Process at most 2 pending archives
    db = get_db()

    docs = (
        db.collection("archive")
        .where("processed", "==", False)
        .order_by("createdAt", direction=Query.DESCENDING)
        .limit(2)
        .stream()
    )

    for doc in docs:
        try:
            archive_id = doc.id
            print(f"Processing archive {archive_id}")

            response = process_archive(FakeRequest(id=archive_id))
            print(response.get_data(as_text=True))

        except Exception as e:
            print(f"Failed processing {doc.id}: {e}")
            continue

    print("Scheduler finished.")

# =====================
# NOTIFICATIONS
# =====================

@firestore_fn.on_document_created(document="projetos/{projectId}")
def notify_new_project(event):
    projeto = event.data.to_dict()

    message = messaging.Message(
        notification=messaging.Notification(
            title=f"Novo projeto: {projeto.get('titulo', '')}",
            body=projeto.get(
                "ideia_central",
                "Novo projeto publicado"
            )
        ),
        topic="projects",
        data={
            "projectId": event.params["projectId"],
            "titulo": projeto.get("titulo", "")
        }
    )

    messaging.send(message)