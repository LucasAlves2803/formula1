const sequelize = require('./infrastructure/database');
const express = require('express');
const pilotoRoutes = require('./interface/routes/pilotoRoutes');

sequelize.sync().then(() => {
  console.log('Banco de dados sincronizado');
}).catch(error => {
  console.error('Erro ao sincronizar o banco de dados:', error);
});

const app = express();
app.use(express.json());

app.use('/api', pilotoRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});