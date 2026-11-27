require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./db');
const mangasRoutes = require('./routes/mangas.routes');

const app = express();

app.use(cors());
app.use(express.json());

// Rota de saúde: testa se a API e o banco estão de pé
app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', banco: 'conectado' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: 'erro', banco: 'desconectado' });
  }
});

app.use('/api/mangas', mangasRoutes);

// 404 para rotas que não existem
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

// Tratamento de erro geral
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ erro: 'Erro interno do servidor' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API rodando em http://localhost:${PORT}`);
});