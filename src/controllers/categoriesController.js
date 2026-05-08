const pool = require('../config/database');

// GET /categories
const getAll = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM categories ORDER BY name');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /categories/:id
const getById = async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM categories WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Categoria não encontrada.' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// POST /categories
const create = async (req, res) => {
  const { name, description } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'Nome é obrigatório.' });
  }
  try {
    const [result] = await pool.query(
      'INSERT INTO categories (name, description) VALUES (?, ?)',
      [name, description || null]
    );
    res.status(201).json({ message: 'Categoria criada com sucesso.', id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// PUT /categories/:id
const update = async (req, res) => {
  const { name, description } = req.body;
  try {
    const [result] = await pool.query(
      'UPDATE categories SET name = ?, description = ? WHERE id = ?',
      [name, description, req.params.id]
    );
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Categoria não encontrada.' });
    }
    res.json({ message: 'Categoria atualizada com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// DELETE /categories/:id
const remove = async (req, res) => {
  try {
    const [result] = await pool.query('DELETE FROM categories WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Categoria não encontrada.' });
    }
    res.json({ message: 'Categoria eliminada com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

module.exports = { getAll, getById, create, update, remove };
