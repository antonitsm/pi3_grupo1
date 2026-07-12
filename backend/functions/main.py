from firebase_functions import https_fn, scheduler_fn

from firebase_functions.options import set_global_options

from firebase_functions import firestore_fn
from firebase_admin import messaging

from google.cloud.firestore_v1 import Query
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

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
#GOOGLE_API_KEY = ""


def get_db():
    return firestore.client()


# =====================
# HELPERS
# =====================

FIRST_NAMES = [
    "João", "Maria", "José", "Ana", "Pedro", "Lucas", "Gabriel",
    "Rafael", "Bruno", "Carlos", "Fernando", "Ricardo", "Marcos",
    "Paulo", "Roberto", "Eduardo", "André", "Felipe", "Gustavo",
    "Thiago", "Juliana", "Fernanda", "Camila", "Patrícia", "Amanda",
    "Beatriz", "Larissa", "Mariana", "Carolina", "Renata", "Vanessa",
    "Aline", "Natália", "Isabela", "Letícia", "Sofia", "Helena",
    "Vinícius", "Matheus", "Diego"
]

LAST_NAMES = [
    "Silva", "Souza", "Oliveira", "Santos", "Pereira", "Lima",
    "Ferreira", "Almeida", "Costa", "Gomes", "Rodrigues", "Martins",
    "Araújo", "Barbosa", "Rocha", "Cardoso", "Dias", "Teixeira",
    "Correia", "Mendes", "Ribeiro", "Monteiro", "Carvalho", "Moreira",
    "Nunes", "Castro", "Freitas", "Moura", "Machado", "Batista",
    "Vieira", "Campos", "Rezende", "Farias", "Tavares", "Cavalcante",
    "Peixoto", "Assis", "Borges", "Moraes"
]


ADJECTIVES = [
    "Democrático", "Popular", "Nacional", "Liberal", "Progressista",
    "Conservador", "Social", "Trabalhista", "Republicano", "Federal",
    "Cidadão", "Solidário", "Renovador", "Independente", "Unido",
    "Sustentável", "Patriótico", "Humanista", "Cristão", "Reformista",
    "Verde", "Livre"
]

NOUNS = [
    "Movimento", "Partido", "Frente", "Aliança", "União",
    "Coalizão", "Liga", "Bloco"
]

CAUSES = [
    "Brasil", "Trabalho", "Justiça", "Liberdade", "Democracia",
    "Desenvolvimento", "Progresso", "Família", "Educação",
    "Saúde", "Economia", "Cidadania", "Inovação", "Sustentabilidade",
    "Futuro", "Igualdade", "Esperança", "Ordem", "Reforma",
    "Direitos", "Povo", "Juventude"
]


def gerar_nome():
    primeiro = random.choice(FIRST_NAMES)

    # 70% chance of having two surnames
    if random.random() < 0.7:
        sobrenomes = random.sample(LAST_NAMES, 2)
        return f"{primeiro} {' '.join(sobrenomes)}"

    return f"{primeiro} {random.choice(LAST_NAMES)}"


def gerar_nome_partido():
    estrutura = random.randint(0, 3)

    if estrutura == 0:
        # Partido Democrático Nacional
        palavras = [
            random.choice(NOUNS),
            random.choice(ADJECTIVES),
            random.choice(CAUSES)
        ]

    elif estrutura == 1:
        # Movimento pela Justiça
        palavras = [
            random.choice(NOUNS),
            "pela",
            random.choice(CAUSES)
        ]

    elif estrutura == 2:
        # União Popular Democrática
        palavras = [
            random.choice(NOUNS),
            random.choice(ADJECTIVES),
            random.choice(ADJECTIVES)
        ]

    else:
        # Partido Nacional do Trabalho
        palavras = [
            random.choice(NOUNS),
            random.choice(ADJECTIVES),
            "do",
            random.choice(CAUSES)
        ]

    return " ".join(palavras)


def gerar_sigla(nome):
    ignorar = {
        "da", "de", "do", "dos", "das",
        "e", "pela", "pelo", "por", "para"
    }

    letras = [
        palavra[0].upper()
        for palavra in nome.split()
        if palavra.lower() not in ignorar
    ]

    return "".join(letras)


def gerar_partido_unico(db):
    nomes_existentes = {
        doc.get("nome")
        for doc in db.collection("partidos").stream()
    }

    siglas_existentes = {
        doc.get("sigla")
        for doc in db.collection("partidos").stream()
    }

    while True:
        nome = gerar_nome_partido()
        sigla = gerar_sigla(nome)

        if nome in nomes_existentes:
            continue

        if sigla in siglas_existentes:
            continue

        return {
            "nome": nome,
            "sigla": sigla,
            "ano_criacao": random.randint(1945, 2026),
            "createdAt": SERVER_TIMESTAMP,
            "updatedAt": SERVER_TIMESTAMP
        }


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
Gerencia um projeto específico.
"""
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
Cria um novo vereador (POST) ou retorna todos os vereadores cadastrados (GET).
"""
@https_fn.on_request()
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
# POST /mock_projeto
# ==================================================

"""
Cria um projeto fictício para testes.
"""
@https_fn.on_request()
def mock_projeto(req):
    db = get_db()
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )


    vereadores_docs = list(db.collection("vereadores").stream())

    autoria = []
    autoria_ids = []

    if vereadores_docs:
        quantidade = random.randint(1, min(3, len(vereadores_docs)))
        escolhidos = random.sample(vereadores_docs, quantidade)

        autoria = [v.to_dict().get("nome", "") for v in escolhidos]
        autoria_ids = [v.id for v in escolhidos]

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
        "autoria": autoria,
        "autoriaIds": autoria_ids,
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
Cria um vereador fictício para testes.
"""
@https_fn.on_request()
def mock_vereador(req):
    db = get_db()
    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )


    # Buscar partidos existentes
    partidos_docs = list(db.collection("partidos").stream())

    partido = ""
    partido_id = ""

    if partidos_docs:
        partido_doc = random.choice(partidos_docs)
        partido_data = partido_doc.to_dict()

        partido = partido_data.get("sigla") or partido_data.get("nome", "")
        partido_id = partido_doc.id

    # Buscar projetos existentes
    projetos_docs = list(db.collection("projetos").stream())

    projetos = []

    if projetos_docs:
        quantidade = random.randint(0, min(5, len(projetos_docs)))
        escolhidos = random.sample(projetos_docs, quantidade)
        projetos = [p.id for p in escolhidos]

    novo_vereador = {
        "nome": gerar_nome(),
        "partido": partido,
        "partidoId": partido_id,
        "foto": "",
        "biografia": "Biografia gerada automaticamente",
        "projetos": projetos,
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
Cria um partido fictício para testes.
"""
@https_fn.on_request()
def mock_partido(req):
    db = get_db()

    if req.method != "POST":
        return https_fn.Response(
            json.dumps({"error": "Method not allowed"}),
            status=405,
            content_type="application/json"
        )

    novo_partido = gerar_partido_unico(db)

    _, doc_ref = db.collection("partidos").add(novo_partido)

    return https_fn.Response(
        json.dumps({
            "message": "Partido mock criado",
            "id": doc_ref.id
        }),
        content_type="application/json"
    )

# ==================================================
# POST /mock_dados_iniciais
# ==================================================

"""
Cria dados iniciais fictícios para testes, incluindo partidos e vereadores.
"""
@https_fn.on_request()
def mock_dados_iniciais(req):
    db = get_db()

    if req.method != "POST":
        return https_fn.Response(
            "Método não permitido",
            status=405
        )

    # Cria 4 partidos únicos
    partidos = []

    for _ in range(4):
        partido = gerar_partido_unico(db)

        ref = db.collection("partidos").document()
        ref.set(partido)

        partidos.append({
            "ref": ref,
            "data": partido
        })

    vereadores = set()
    while len(vereadores) < 10:
        vereadores.add(gerar_nome())

    # Distribui vereadores aleatoriamente entre os partidos
    for nome in list(vereadores):
        partido = random.choice(partidos)

        db.collection("vereadores").document().set({
            "nome": nome,
            "partido": partido["data"]["sigla"],
            "partidoId": partido["ref"].id,
            "createdAt": SERVER_TIMESTAMP,
            "updatedAt": SERVER_TIMESTAMP
        })

    return https_fn.Response(
        json.dumps({
            "message": "Dados criados com sucesso",
            "partidos": [
                {
                    "id": p["ref"].id,
                    "nome": p["data"]["nome"],
                    "sigla": p["data"]["sigla"]
                }
                for p in partidos
            ]
        }),
        content_type="application/json"
    )


# ==================================================
# POST /mock_clear
# ==================================================

"""
Remove todos os registros de teste.
"""
@https_fn.on_request()
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
@https_fn.on_request()
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

        projeto_id = extract_project_with_ai(
            archive_id,
            archive_data
        )

        doc_ref.update({
            "processed": True,
            "projetoId": projeto_id,
            "updatedAt": SERVER_TIMESTAMP
        })

        return https_fn.Response(
            json.dumps({
                "success": True,
                "archiveId": archive_id,
                "projetoId": projeto_id
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

def extract_project_with_ai(archive_id, archive_data):
    db = get_db()
    response = requests.get(
        archive_data["url"],
        timeout=30,
        headers={"User-Agent": "Mozilla/5.0"}
    )
    response.raise_for_status()

    pdf_urls = re.findall(
        r'https://[^"\'> ]+\.pdf',
        response.text
    )

    original_pdf = next(
        (url for url in pdf_urls if "_extrato" not in url),
        None
    )

    if not original_pdf:
        raise Exception("PDF original não encontrado")

    pdf_response = requests.get(original_pdf, timeout=30)
    pdf_response.raise_for_status()

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
                    Analyze this municipal act. autoria are names.

                    Return ONLY JSON:
                    {
                      "titulo": "",
                      "ideia_central": "",
                      "localidades_afetadas": "",
                      "status": "",
                      "tags": [],
                      "autoria": []
                    }
                    """
                }
            ]
        }]
    }

    ai_response = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key={GOOGLE_API_KEY}",
        json=payload,
        timeout=60
    )

    if not ai_response.ok:
        print(ai_response.status_code)
        print(ai_response.text)
        ai_response.raise_for_status()

    result = ai_response.json()

    if not result.get("candidates"):
        raise Exception("Gemini retornou resposta vazia")

    text = result["candidates"][0]["content"]["parts"][0]["text"]

    # remove markdown fences if Gemini adds them
    text = text.replace("```json", "").replace("```", "").strip()

    projeto_data = json.loads(text)

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

    projeto_ref = db.collection("projetos").document()
    projeto_ref.set(projeto_data)

    return projeto_ref.id




# =====================
# SCHEDULERS
# =====================


class FakeRequest:
    method = "POST"

    def __init__(self, **args):
        self.args = args

@scheduler_fn.on_schedule(schedule="every 24 hours")
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
        .where("processed", "!=", True)
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
            title="New project available",
            body=projeto.get("titulo", "A new project has been published")
        ),
        topic="projects",
        data={
            "projectId": event.params["projectId"]
        }
    )

    messaging.send(message)