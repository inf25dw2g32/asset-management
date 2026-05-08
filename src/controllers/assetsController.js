const pool = require('../config/database');

// GET /assets
const getAll = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT a.*, c.name AS category_name, u.name AS owner_name
      FROM assets a
      JOIN categories c ON a.category_id = c.id
      JOIN users u ON a.owner_id = u.id
      ORDER BY a.name
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /assets/:id
const getById = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT a.*, c.name AS category_name, u.name AS owner_name
      FROM assets a
      JOIN categories c ON a.category_id = c.id
      JOIN users u ON a.owner_id = u.id
      WHERE a.id = ?
    `, [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Asset não encontrado.' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /assets/my — apenas os assets do utilizador autenticado
const getMine = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT a.*, c.name AS category_name
      FROM assets a
      JOIN categories c ON a.category_id = c.id
      WHERE a.owner_id = ?
      ORDER BY a.name
    `, [req.user.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// POST /assets
const create = async (req, res) => {
  const { category_id, name, serial_number, brand, model, location, status, purchase_date, criticality, notes } = req.body;
  if (!category_id || !name) {
    return res.status(400).json({ error: 'Categoria e nome são obrigatórios.' });
  }
  try {
    const [result] = await pool.query(
      `INSERT INTO assets (category_id, owner_id, name, serial_number, brand, model, location, status, purchase_date, criticality, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [category_id, req.user.id, name, serial_number, brand, model, location, status || 'active', purchase_date, criticality || 'medium', notes]
    );
    res.status(201).json({ message: 'Asset criado com sucesso.', id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// PUT /assets/:id
const update = async (req, res) => {
  const { category_id, name, serial_number, brand, model, location, status, purchase_date, criticality, notes } = req.body;
  try {
    // Se não for admin, só pode editar os seus próprios assets
    if (req.user.role !== 'admin') {
      const [rows] = await pool.query('SELECT owner_id FROM assets WHERE id = ?', [req.params.id]);
      if (rows.length === 0) return res.status(404).json({ error: 'Asset não encontrado.' });
      if (rows[0].owner_id !== req.user.id) return res.status(403).json({ error: 'Sem permissão para editar este asset.' });
    }
    const [result] = await pool.query(
      `UPDATE assets SET category_id=?, name=?, serial_number=?, brand=?, model=?, location=?, status=?, purchase_date=?, criticality=?, notes=? WHERE id=?`,
      [category_id, name, serial_number, brand, model, location, status, purchase_date, criticality, notes, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Asset não encontrado.' });
    res.json({ message: 'Asset atualizado com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// DELETE /assets/:id
const remove = async (req, res) => {
  try {
    // Se não for admin, só pode apagar os seus próprios assets
    if (req.user.role !== 'admin') {
      const [rows] = await pool.query('SELECT owner_id FROM assets WHERE id = ?', [req.params.id]);
      if (rows.length === 0) return res.status(404).json({ error: 'Asset não encontrado.' });
      if (rows[0].owner_id !== req.user.id) return res.status(403).json({ error: 'Sem permissão para apagar este asset.' });
    }
    const [result] = await pool.query('DELETE FROM assets WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Asset não encontrado.' });
    res.json({ message: 'Asset eliminado com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

module.exports = { getAll, getById, getMine, create, update, remove };
