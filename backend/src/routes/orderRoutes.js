const express = require('express');
const {
  createOrder,
  getUserOrders,
  getOrderById,
  getOrderStatus,
  updateOrderStatus,
} = require('../controllers/orderController');
const { protect } = require('../middlewares/auth');

const router = express.Router();

// All order operations require authentication
router.use(protect);

router.post('/', createOrder);
router.get('/', getUserOrders);
router.get('/:id/status', getOrderStatus);
router.patch('/:id/status', updateOrderStatus);
router.post('/:id/status', updateOrderStatus);
router.get('/:id', getOrderById);

module.exports = router;