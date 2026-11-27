const { Router } = require('express');
const controller = require('../controllers/mangas.controller');

const router = Router();

router.get('/', controller.listar);                       // GET /api/mangas?q=&genero=&page=&limit=
router.get('/:id', controller.buscarPorId);               // GET /api/mangas/1
router.get('/:id/capitulos', controller.listarCapitulos); // GET /api/mangas/1/capitulos

module.exports = router;
