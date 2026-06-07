# HOW TO USE

cd backend
npx firebase-tools login
{go to firebase console, select project > firestore > create database}
{edit .firebaserc and put firestore project_id}
npx firebase-tools init functions
{select overwrites; pythons; don't overwrite filess; install dependencies}


npx firebase-tools emulators:start
or
npx firebase-tools deploy --only functions