const pool = require('../db');

// Subconsulta que junta os nomes dos gêneros de um mangá numa string só
const SQL_GENEROS = `
  (SELECT GROUP_CONCAT(g.nome ORDER BY g.nome SEPARATOR ',')
     FROM manga_generos mg
     JOIN generos g ON g.id = mg.genero_id
    WHERE mg.manga_id = m.id) AS generos
`;

const paraArray = (texto) => (texto ? texto.split(',') : []);

// GET /api/mangas?q=espada&genero=Ação&page=1&limit=12
async function listar(req, res, next) {
  try {
    const pagina = Math.max(parseInt(req.query.page) || 1, 1);
    const limite = Math.min(Math.max(parseInt(req.query.limit) || 12, 1), 50);
    const offset = (pagina - 1) * limite;

    const filtros = [];
    const params = [];

    if (req.query.q) {
      filtros.push('(m.titulo LIKE ? OR m.titulo_alternativo LIKE ?)');
      params.push(`%${req.query.q}%`, `%${req.query.q}%`);
    }

    if (req.query.genero) {
      filtros.push(`EXISTS (
        SELECT 1 FROM manga_generos mg
        JOIN generos g ON g.id = mg.genero_id
        WHERE mg.manga_id = m.id AND g.nome = ?
      )`);
      params.push(req.query.genero);
    }

    const where = filtros.length ? `WHERE ${filtros.join(' AND ')}` : '';

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM mangas m ${where}`,
      params
    );

    const [linhas] = await pool.query(
      `SELECT m.id, m.titulo, m.capa_url, m.status, m.tipo, m.ano_publicacao,
              ${SQL_GENEROS}
         FROM mangas m
         ${where}
        ORDER BY m.atualizado_em DESC
        LIMIT ? OFFSET ?`,
      [...params, limite, offset]
    );

    res.json({
      dados: linhas.map((l) => ({ ...l, generos: paraArray(l.generos) })),
      paginacao: {
        pagina,
        limite,
        total,
        totalPaginas: Math.ceil(total / limite),
      },
    });
  } catch (err) {
    next(err);
  }
}

// GET /api/mangas/:id
async function buscarPorId(req, res, next) {
  try {
    const id = parseInt(req.params.id);
    if (!id) return res.status(400).json({ erro: 'ID inválido' });

    const [linhas] = await pool.query(
      `SELECT m.*, ${SQL_GENEROS} FROM mangas m WHERE m.id = ?`,
      [id]
    );

    if (linhas.length === 0) {
      return res.status(404).json({ erro: 'Mangá não encontrado' });
    }

    const manga = linhas[0];
    res.json({ ...manga, generos: paraArray(manga.generos) });
  } catch (err) {
    next(err);
  }
}

// GET /api/mangas/:id/capitulos
async function listarCapitulos(req, res, next) {
  try {
    const id = parseInt(req.params.id);
    if (!id) return res.status(400).json({ erro: 'ID inválido' });

    const [capitulos] = await pool.query(
      `SELECT id, numero, titulo, publicado_em
         FROM capitulos
        WHERE manga_id = ?
        ORDER BY numero DESC`,
      [id]
    );

    res.json(capitulos);
  } catch (err) {
    next(err);
  }
}

module.exports = { listar, buscarPorId, listarCapitulos };
