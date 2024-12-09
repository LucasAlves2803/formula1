// backend/src/interface/routes/pilotoRoutes.js
const express = require('express');
const { criarPiloto } = require('../controllers/pilotoController');

const router = express.Router();

router.post('/pilotos', criarPiloto);

module.exports = router;