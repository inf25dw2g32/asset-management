const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
require('dotenv').config();

const authRoutes = require('./src/routes/auth');
const categoriesRoutes = require('./src/routes/categories');
const assetsRoutes = require('./src/routes/assets');
const inspectionsRoutes = require('./src/routes/inspections');

const app = express();

app.use(cors());
app.use(express.json());

// Swagger
const swaggerDocument = YAML.load('./swagger.yaml');
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

// Rotas
app.use('/auth', authRoutes);
app.use('/categories', categoriesRoutes);
app.use('/assets', assetsRoutes);
app.use('/inspections', inspectionsRoutes);

// Rota base
app.get('/', (req, res) => {
  res.json({ message: 'Asset Management API está a correr!' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor a correr na porta ${PORT}`);
  console.log(`Documentação disponível em http://localhost:${PORT}/docs`);
});