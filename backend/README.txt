cd backend
npx firebase-tools login
npx firebase-tools init functions
{select new project and python}
{go to firebase console, select project > firestore > create database}



npx firebase-tools emulators:start
or
npx firebase-tools deploy --only functions