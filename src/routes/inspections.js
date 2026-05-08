const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getAll, getById, getMine, getByAsset, create, update, remove } = require('../controllers/inspectionsController');

router.get('/', auth, getAll);
router.get('/my', auth, getMine);
router.get('/:id', auth, getById);
router.get('/asset/:assetId', auth, getByAsset);
router.post('/', auth, create);
router.put('/:id', auth, update);
router.delete('/:id', auth, remove);

module.exports = router;
