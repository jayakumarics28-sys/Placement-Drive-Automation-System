require('dotenv').config();
if(!process.env.SESSION_SECRET||!process.env.DB_NAME)console.warn('Set SESSION_SECRET and MySQL values in .env before use.');
const app=require('./app');const port=Number(process.env.PORT||3000);app.listen(port,'0.0.0.0',()=>console.log(`Placement system listening on http://0.0.0.0:${port}`));
