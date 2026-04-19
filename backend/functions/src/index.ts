import { setGlobalOptions } from "firebase-functions";
import { onRequest } from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

import express, { Request, Response } from "express";
import cors from "cors";

import * as admin from "firebase-admin";

import { FieldValue } from "firebase-admin/firestore";

setGlobalOptions({ maxInstances: 10 });

admin.initializeApp();
const db = admin.firestore();

const app = express();

app.use(cors({ origin: true }));
app.use(express.json());

/**
 * LISTAR PROJETOS
 */
app.get("/projetos", async (_req: Request, res: Response) => {
  const snapshot = await db.collection("projetos").get();

  const projetos = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return res.json(projetos);
});

/**
 * BUSCAR PROJETO POR ID
 */
app.get(
  "/projetos/:id",
  async (req: Request<{ id: string }>, res: Response) => {
    const { id } = req.params;

    const doc = await db.collection("projetos").doc(id).get();

    if (!doc.exists) {
      return res.status(404).json({ error: "Projeto não encontrado" });
    }

    return res.json({ id: doc.id, ...doc.data() });
  }
);

/**
 * CRIAR PROJETO ALEATÓRIO (MOCK)
 */
app.get("/mock/projeto", async (_req: Request, res: Response) => {
  const randomStatus = ["emDiscussao", "aprovado", "reprovado"];
  const randomIndex = Math.floor(Math.random() * randomStatus.length);

  const novoProjeto = {
    titulo: `Projeto ${Math.floor(Math.random() * 1000)}`,
    descricao: "Descrição gerada automaticamente para teste",
    textoOriginalUrl: "https://example.com/projeto",
    resumoIa: "Resumo gerado automaticamente por IA (mock)",
    status: randomStatus[randomIndex],
    dataPublicacao: new Date(),
    autores: [], // pode popular depois com IDs reais
    feedbacks: [],
		createdAt: FieldValue.serverTimestamp(),
		updatedAt: FieldValue.serverTimestamp(),
  };

  const docRef = await db.collection("projetos").add(novoProjeto);

  return res.json({
    message: "Projeto mock criado com sucesso",
    id: docRef.id,
    data: novoProjeto,
  });
});

/**
 * MOCK DE COLETA (SCRAPING)
 */
app.post("/coleta", async (_req: Request, res: Response) => {
  logger.info("Iniciando scraping...");

  const novoProjeto = {
    texto: "Projeto de lei exemplo",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const docRef = await db.collection("projetos").add(novoProjeto);

  return res.json({
    message: "Projeto criado (mock)",
    id: docRef.id,
  });
});

/**
 * PROCESSAR PROJETO (IA MOCK)
 */
app.post(
  "/processar/:id",
  async (req: Request<{ id: string }>, res: Response) => {
    const { id } = req.params;

    const ref = db.collection("projetos").doc(id);
    const doc = await ref.get();

    if (!doc.exists) {
      return res.status(404).json({ error: "Projeto não encontrado" });
    }

    await ref.update({
      resumo: "Resumo gerado por IA (mock)",
    });

    return res.json({ message: "Projeto processado" });
  }
);

/**
 * LISTAR VEREADORES
 */
app.get("/vereadores", async (_req: Request, res: Response) => {
  const snapshot = await db.collection("vereadores").get();

  const vereadores = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return res.json(vereadores);
});

/**
 * LISTAR PARTIDOS
 */
app.get("/partidos", async (_req: Request, res: Response) => {
  const snapshot = await db.collection("partidos").get();

  const partidos = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return res.json(partidos);
});

/**
 * ENVIAR FEEDBACK
 */
app.post("/feedback", async (req: Request, res: Response) => {
  const { projetoId, opiniao } = req.body;

  if (!projetoId || !opiniao) {
    return res.status(400).json({ error: "Dados inválidos" });
  }

  await db.collection("feedbacks").add({
    projetoId,
    opiniao,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return res.json({ message: "Feedback registrado" });
});

/**
 * RESUMO DE FEEDBACK
 */
app.get(
  "/feedback/:projetoId",
  async (req: Request<{ projetoId: string }>, res: Response) => {
    const { projetoId } = req.params;

    const snapshot = await db
      .collection("feedbacks")
      .where("projetoId", "==", projetoId)
      .get();

    const data = snapshot.docs.map((doc) => doc.data());

    const total = data.length;
    const positivos = data.filter((f) => f.opiniao === "positivo").length;
    const negativos = data.filter((f) => f.opiniao === "negativo").length;

    return res.json({
      total,
      positivos,
      negativos,
    });
  }
);

export const api = onRequest(app);