const express = require('express');
const {
  getCart,
  addToCart,
  updateCartItemQuantity,
  removeCartItem,
  clearCart,
} = require('../controllers/cartController');
const { protect } = require('../middlewares/auth');

const router = express.Router();

// All cart operations require authentication
router.use(protect);

router.get('/', getCart);
router.post('/items', addToCart);
router.patch('/items/:id', updateCartItemQuantity);
router.delete('/items/:id', removeCartItem);
router.delete('/', clearCart);

module.exports = router;

