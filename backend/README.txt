FIREBASE SETUP
cd project/backend/
npx firebase-tools login
npx firebase-tools init
select "functions" and "emulators"

FIREBASE UPDATE
cd project/backend/
npx firebase-tools emulators:start
or
npx firebase-tools deploy --only functions

EXPRESS SETUP
cd project/backend/functions/
npm install express cors
npm install -D @types/express

EXPRESS UPDATE
cd project/backend/functions/
npm run build

DATABASE
projetos:
- id
- titulo
- descricao
- textoOriginalUrl
- resumoIa
- status (emDiscussao|aprovado|reprovado)
- dataPublicacao
- autores (id list)
- feedbacks (id list)
- createdAt
- updatedAt
vereadores:
- id
- nome
- partidoId
- fotoUrl
- biografia
- contato
- ativo (?)
- projetos (id list)
- createdAt
- updatedAt
partidos:
- id
- nome
- sigla
- createdAt
- updatedAt
feedbacks:
- id
- projetoId
- tipo (positivo|negativo)