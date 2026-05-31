//página para listas falsas - excluir após integração com back
final projetosMock = [
  {
    "id": "1",
    "titulo": "Ampliação do atendimento nas UBS",
    "data_publicacao": "2026-03-15",
    "status": "Em discussão",

    "ideia_central":
        "Expandir o horário de funcionamento das unidades básicas de saúde.",

    "localidades_afetadas":
        "Todas as UBS do município.",

    "quando_sera_executado":
        "Janeiro de 2027.",

    "como_sera_executado":
        "Contratação de profissionais e ampliação dos turnos.",

    "autoria": [
      "João Silva",
      "Maria Souza"
    ],

    "relevancia": "Alta",

    "justificativa_relevancia":
        "Aumenta o acesso da população aos serviços de saúde.",

    "likes": 128,
    "dislikes": 15,

    "tags": [
      "saúde"
    ],

    "textoOriginalUrl":
    "https://camara.gov.br/projeto123"
  },

  {
    "id": "2",
    "titulo": "Programa Municipal de Educação Digital",
    "data_publicacao": "2026-04-02",
    "status": "Aprovado",

    "ideia_central":
        "Inserir conteúdos de programação e tecnologia nas escolas municipais.",

    "localidades_afetadas":
        "Rede municipal de ensino.",

    "quando_sera_executado":
        "Ano letivo de 2027.",

    "como_sera_executado":
        "Capacitação de professores e compra de equipamentos.",

    "autoria": [
      "Ana Pereira"
    ],

    "relevancia": "Alta",

    "justificativa_relevancia":
        "Contribui para a formação tecnológica dos estudantes.",

    "likes": 214,
    "dislikes": 11,

    "tags": [
      "educação",
      "tecnologia"
    ],

    "textoOriginalUrl":
    "https://camara.gov.br/projeto123"
  },

  {
    "id": "3",
    "titulo": "Revitalização das Praças Públicas",
    "data_publicacao": "2026-05-10",
    "status": "Em discussão",

    "ideia_central":
        "Modernizar áreas de lazer e convivência do município.",

    "localidades_afetadas":
        "Praças centrais e bairros periféricos.",

    "quando_sera_executado":
        "Durante o ano de 2027.",

    "como_sera_executado":
        "Execução de obras e instalação de novos equipamentos.",

    "autoria": [
      "Carlos Mendes"
    ],

    "relevancia": "Média",

    "justificativa_relevancia":
        "Melhora os espaços públicos e incentiva o convívio social.",

    "likes": 97,
    "dislikes": 23,

    "tags": [
      "lazer",
      "urbanismo",
      "obras"
    ],

    "textoOriginalUrl":
    "https://camara.gov.br/projeto123"
  },

  {
    "id": "4",
    "titulo": "Monitoramento Inteligente do Trânsito",
    "data_publicacao": "2026-05-20",
    "status": "Em discussão",

    "ideia_central":
        "Instalar sensores e câmeras para melhorar o fluxo viário.",

    "localidades_afetadas":
        "Principais avenidas da cidade.",

    "quando_sera_executado":
        "Segundo semestre de 2026.",

    "como_sera_executado":
        "Integração dos equipamentos a uma central de monitoramento.",

    "autoria": [
      "Roberto Lima"
    ],

    "relevancia": "Alta",

    "justificativa_relevancia":
        "Pode reduzir congestionamentos e aumentar a segurança.",

    "likes": 173,
    "dislikes": 42,

    "tags": [
      "trânsito",
      "mobilidade",
      "segurança"
    ],

    "textoOriginalUrl":
    "https://camara.gov.br/projeto123"
  },

  {
    "id": "5",
    "titulo": "Portal de Transparência em Tempo Real",
    "data_publicacao": "2026-06-01",
    "status": "Aprovado",

    "ideia_central":
        "Disponibilizar informações públicas atualizadas automaticamente.",

    "localidades_afetadas":
        "Todo o município.",

    "quando_sera_executado":
        "Até dezembro de 2026.",

    "como_sera_executado":
        "Integração entre sistemas administrativos e portal público.",

    "autoria": [
      "Fernanda Costa"
    ],

    "relevancia": "Alta",

    "justificativa_relevancia":
        "Facilita a fiscalização e amplia o acesso à informação.",

    "likes": 256,
    "dislikes": 18,

    "tags": [
      "transparência",
      "participação",
      "tecnologia"
    ],

    "textoOriginalUrl":
    "https://camara.gov.br/projeto123"
  }
];

final vereadoresMock = [
  {
    "id": "1",
    "nome": "João Silva",
    "partido": "PDT",
    "foto": "",
    "biografia":
        "Vereador atuante nas áreas de saúde pública e assistência social.",
    "projetos": ["1", "3"],
    "projetos_aprovados": 5,
    "contato": "joao@camara.gov.br",
  },

  {
    "id": "2",
    "nome": "Maria Souza",
    "partido": "PSB",
    "foto": "",
    "biografia":
        "Atua em pautas relacionadas à educação e tecnologia.",
    "projetos": ["1", "2"],
    "projetos_aprovados": 8,
    "contato": "maria@camara.gov.br",
  },

  {
    "id": "3",
    "nome": "Carlos Mendes",
    "partido": "MDB",
    "foto": "",
    "biografia":
        "Foco em urbanismo, infraestrutura e mobilidade urbana.",
    "projetos": ["3"],
    "projetos_aprovados": 4,
    "contato": "carlos@camara.gov.br",
  },

  {
    "id": "4",
    "nome": "Roberto Lima",
    "partido": "PL",
    "foto": "",
    "biografia":
        "Defensor de projetos ligados à segurança pública.",
    "projetos": ["4"],
    "projetos_aprovados": 6,
    "contato": "roberto@camara.gov.br",
  },

  {
    "id": "5",
    "nome": "Fernanda Costa",
    "partido": "PT",
    "foto": "",
    "biografia":
        "Atuação voltada para transparência e participação popular.",
    "projetos": ["5"],
    "projetos_aprovados": 9,
    "contato": "fernanda@camara.gov.br",
  }
];

final partidosMock = [
  {
    "id": "1",
    "nome": "Partido Democrático Trabalhista",
    "sigla": "PDT",
    "ano_criacao": 1979,
  },

  {
    "id": "2",
    "nome": "Partido Socialista Brasileiro",
    "sigla": "PSB",
    "ano_criacao": 1947,
  },

  {
    "id": "3",
    "nome": "Movimento Democrático Brasileiro",
    "sigla": "MDB",
    "ano_criacao": 1966,
  },

  {
    "id": "4",
    "nome": "Partido Liberal",
    "sigla": "PL",
    "ano_criacao": 2006,
  },

  {
    "id": "5",
    "nome": "Partido dos Trabalhadores",
    "sigla": "PT",
    "ano_criacao": 1980,
  }
];