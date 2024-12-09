// backend/src/interface/controllers/pilotoController.js
const inserirNovoPiloto = require('../../domain/usecase/useCaseNovoPiloto');

async function criarPiloto(req, res) {
  const { nome, pais_id, equipe_id } = req.body;

  try {
    const novoPiloto = await inserirNovoPiloto(nome, pais_id, equipe_id);
    res.status(201).json(novoPiloto);
  } catch (error) {
    res.status(500).json({ mensagem: 'Erro ao criar piloto.' });
  }
}

module.exports = { criarPiloto };