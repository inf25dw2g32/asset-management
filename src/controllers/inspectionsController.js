const pool = require('../config/database');

// GET /inspections
const getAll = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.*, a.name AS asset_name, u.name AS inspector_name
      FROM inspections i
      JOIN assets a ON i.asset_id = a.id
      JOIN users u ON i.inspector_id = u.id
      ORDER BY i.inspected_at DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /inspections/:id
const getById = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.*, a.name AS asset_name, u.name AS inspector_name
      FROM inspections i
      JOIN assets a ON i.asset_id = a.id
      JOIN users u ON i.inspector_id = u.id
      WHERE i.id = ?
    `, [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Inspeção não encontrada.' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /inspections/my — apenas as inspeções do utilizador autenticado
const getMine = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.*, a.name AS asset_name
      FROM inspections i
      JOIN assets a ON i.asset_id = a.id
      WHERE i.inspector_id = ?
      ORDER BY i.inspected_at DESC
    `, [req.user.id]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// GET /assets/:assetId/inspections — inspeções de um asset específico
const getByAsset = async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT i.*, u.name AS inspector_name
      FROM inspections i
      JOIN users u ON i.inspector_id = u.id
      WHERE i.asset_id = ?
      ORDER BY i.inspected_at DESC
    `, [req.params.assetId]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// POST /inspections
const create = async (req, res) => {
  const { asset_id, type, result, score, findings, recommendations, next_review } = req.body;
  if (!asset_id) {
    return res.status(400).json({ error: 'Asset é obrigatório.' });
  }
  try {
    const [res2] = await pool.query(
      `INSERT INTO inspections (asset_id, inspector_id, type, result, score, findings, recommendations, next_review)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [asset_id, req.user.id, type || 'audit', result || 'pending', score, findings, recommendations, next_review]
    );
    res.status(201).json({ message: 'Inspeção criada com sucesso.', id: res2.insertId });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// PUT /inspections/:id
const update = async (req, res) => {
  const { type, result, score, findings, recommendations, next_review } = req.body;
  try {
    // Se não for admin, só pode editar as suas próprias inspeções
    if (req.user.role !== 'admin') {
      const [rows] = await pool.query('SELECT inspector_id FROM inspections WHERE id = ?', [req.params.id]);
      if (rows.length === 0) return res.status(404).json({ error: 'Inspeção não encontrada.' });
      if (rows[0].inspector_id !== req.user.id) return res.status(403).json({ error: 'Sem permissão para editar esta inspeção.' });
    }
    const [result2] = await pool.query(
      `UPDATE inspections SET type=?, result=?, score=?, findings=?, recommendations=?, next_review=? WHERE id=?`,
      [type, result, score, findings, recommendations, next_review, req.params.id]
    );
    if (result2.affectedRows === 0) return res.status(404).json({ error: 'Inspeção não encontrada.' });
    res.json({ message: 'Inspeção atualizada com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

// DELETE /inspections/:id
const remove = async (req, res) => {
  try {
    if (req.user.role !== 'admin') {
      const [rows] = await pool.query('SELECT inspector_id FROM inspections WHERE id = ?', [req.params.id]);
      if (rows.length === 0) return res.status(404).json({ error: 'Inspeção não encontrada.' });
      if (rows[0].inspector_id !== req.user.id) return res.status(403).json({ error: 'Sem permissão para apagar esta inspeção.' });
    }
    const [result] = await pool.query('DELETE FROM inspections WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Inspeção não encontrada.' });
    res.json({ message: 'Inspeção eliminada com sucesso.' });
  } catch (err) {
    res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

module.exports = { getAll, getById, getMine, getByAsset, create, update, remove };
