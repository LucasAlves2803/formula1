// backend/src/domain/usecase/useCaseNovoPiloto.js
const client = require('../../infrastructure/database');

/**
 * Insere um novo piloto no banco de dados.
 * @param {string} nome - Nome do piloto.
 * @param {number} pais_id - ID do país do piloto.
 * @param {number} equipe_id - ID da equipe do piloto.
 * @returns {Promise<Object>} - Retorna os dados do piloto inserido.
 */
async function inserirNovoPiloto(nome, pais_id, equipe_id) {
  const query = `
    INSERT INTO piloto (nome, pais_id, equipe_id)
    VALUES ('${nome}', ${pais_id}, ${equipe_id})
    RETURNING *;
  `;
  const values = [nome, pais_id, equipe_id];

  try {
    const res = await client.query(query, values);
    return res.rows[0];
  } catch (err) {
    console.error('Erro ao inserir novo piloto:', err);
    throw err;
  }
}

module.exports = inserirNovoPiloto;