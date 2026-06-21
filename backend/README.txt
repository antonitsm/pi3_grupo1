# COMO CONFIGURAR O BACKEND

cd backend
npx firebase-tools login

{https://console.firebase.google.com/u/0/}
{em "firebase console" > selecione o projeto > firestore > create database}

{modifique o arquivo local ".firebaserc" e coloque seu project_id da firestore}

npx firebase-tools init functions
{selecione "overwrite", "python", "don't overwrite files", "install dependencies"}


# CHAVE DA IA (ou coloca direto no codigo)

{https://console.cloud.google.com/apis/credentials}
{voce precisa da "Gemini API Key}

## macOS/Linux
export GOOGLE_API_KEY=""

## Windows
$env:GOOGLE_API_KEY=""


# RODAR PRA TESTE OU SUBIR NA NUVEM

npx firebase-tools emulators:start
or
npx firebase-tools deploy --only functions