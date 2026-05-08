const jwt = require('jsonwebtoken');
require('dotenv').config();

module.exports = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Acesso negado. Token não fornecido.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    // Requisito do trabalho: mostrar utilizador autenticado na consola
    console.log('------------------------------------------');
    console.log('Utilizador autenticado:', decoded);
    console.log('Pedido:', req.method, req.originalUrl);
    console.log('------------------------------------------');

    next();
  } catch (err) {
    return res.status(403).json({ error: 'Token inválido ou expirado.' });
  }
};
