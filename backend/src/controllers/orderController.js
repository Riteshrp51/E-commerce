const Order = require('../models/Order');
const Product = require('../models/Product');
const Cart = require('../models/Cart');

// @desc    Place a new order
// @route   POST /api/orders
// @access  Private
const createOrder = async (req, res, next) => {
  try {
    const { deliveryAddress, paymentType = 'COD', items: rawItems } = req.body;

    // Validate delivery address
    if (!deliveryAddress) {
      return res.status(400).json({
        success: false,
        message: 'deliveryAddress is required to place an order.',
      });
    }

    const { fullName, phone, street, city, state, postalCode } = deliveryAddress;
    if (!fullName || !phone || !street || !city || !state || !postalCode) {
      return res.status(400).json({
        success: false,
        message:
          'Please provide all required delivery address fields: fullName, phone, street, city, state, postalCode.',
      });
    }

    // Determine items to order: from body or from user's current cart
    let itemsToProcess = [];
    let cartToClear = null;

    if (rawItems && Array.isArray(rawItems) && rawItems.length > 0) {
      itemsToProcess = rawItems;
    } else {
      cartToClear = await Cart.findOne({ userId: req.user.id });
      if (!cartToClear || cartToClear.items.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Your cart is empty. Please add items before placing an order.',
        });
      }
      itemsToProcess = cartToClear.items.map((item) => ({
        productId: item.productId,
        quantity: item.quantity,
      }));
    }

    // Step 1: Validate stock & compute canonical prices on backend
    let subtotal = 0;
    const itemSnapshots = [];
    const productUpdates = [];

    for (const item of itemsToProcess) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(404).json({
          success: false,
          message: `Product with ID '${item.productId}' was not found.`,
        });
      }

      if (product.stock < item.quantity) {
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for "${product.name}". Only ${product.stock} units available, but ${item.quantity} requested.`,
        });
      }

      // Canonical unit price calculated server-side
      const unitPrice =
        product.offerPrice && product.offerPrice > 0
          ? product.offerPrice
          : product.price;

      subtotal += unitPrice * item.quantity;

      itemSnapshots.push({
        productId: product._id,
        name: product.name,
        price: unitPrice,
        quantity: item.quantity,
        imageUrl: product.imageUrl || (product.images && product.images[0]) || '',
      });

      productUpdates.push({
        productId: product._id,
        quantity: item.quantity,
      });
    }

    const roundedSubtotal = Math.round(subtotal * 100) / 100;
    const shippingFee = roundedSubtotal >= 500 ? 0 : 40;
    const calculatedTotal = Math.round((roundedSubtotal + shippingFee) * 100) / 100;

    // Step 2: Permanently decrement product stock & update inStock status in database
    for (const update of productUpdates) {
      const product = await Product.findById(update.productId);
      if (product) {
        product.stock = Math.max(0, product.stock - update.quantity);
        product.inStock = product.stock > 0;
        await product.save();
      }
    }

    // Step 3: Create and persist the Order
    const order = await Order.create({
      userId: req.user.id,
      items: itemSnapshots,
      deliveryAddress: {
        fullName,
        phone,
        street,
        city,
        state,
        postalCode,
      },
      totalAmount: calculatedTotal,
      status: 'Pending',
      paymentType,
      isPaid: paymentType === 'Online', // Simulated online payment
    });

    // Step 4: Clear user cart if order was placed from cart
    if (cartToClear) {
      cartToClear.items = [];
      await cartToClear.save();
    } else {
      await Cart.findOneAndUpdate({ userId: req.user.id }, { items: [] });
    }

    res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      data: order,
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get all orders for the current user
// @route   GET /api/orders
// @access  Private
const getUserOrders = async (req, res, next) => {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({
      createdAt: -1,
    });

    res.status(200).json({
      success: true,
      count: orders.length,
      data: orders,
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get order details by ID
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = async (req, res, next) => {
  try {
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: `Order with ID '${req.params.id}' not found.`,
      });
    }

    // Guard: Ensure user owns this order (or is admin)
    if (
      order.userId.toString() !== req.user.id &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'Forbidden. You are not authorized to view this order.',
      });
    }

    res.status(200).json({
      success: true,
      data: order,
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get order status
// @route   GET /api/orders/:id/status
// @access  Private
  const getOrderStatus = async (req, res, next) => {
    try {
      const order = await Order.findById(req.params.id);

          if(!order) {
            return res.status(404).json({
              success: false,
              message: `Order with ID '${req.params.id}' not found.`,
            });
          }

    res.status(200).json({
            success: true,
            status: order.status || 'Pending',
            orderId: order._id,
            data: order,
          });
        } catch (err) {
          next(err);
        }
      };

      // @desc    Update order status (Supports Pending, Processing, Shipped, Delivered)
      // @route   PATCH /api/orders/:id/status or POST /api/orders/:id/status
      // @access  Private
      const updateOrderStatus = async (req, res, next) => {
        try {
          const validStatuses = ['Pending', 'Processing', 'Shipped', 'Delivered'];
          const order = await Order.findById(req.params.id);

          if (!order) {
            return res.status(404).json({
              success: false,
              message: `Order with ID '${req.params.id}' not found.`,
            });
          }

          let targetStatus = order.status || 'Pending';
          const rawStatus = req.body && req.body.status;

          if (rawStatus && typeof rawStatus === 'string' && rawStatus.trim() !== '') {
            const trimmed = rawStatus.trim();
            const normalized = trimmed.charAt(0).toUpperCase() + trimmed.slice(1).toLowerCase();

            if (validStatuses.includes(normalized)) {
              targetStatus = normalized;
            } else {
              return res.status(400).json({
                success: false,
                message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`,
              });
            }
          }

          order.status = targetStatus;
          await order.save();

          res.status(200).json({
            success: true,
            status: order.status,
            message: `Order status is '${order.status}'`,
            data: order,
          });
        } catch (err) {
          next(err);
        }
      };

      module.exports = {
        createOrder,
        getUserOrders,
        getOrderById,
        getOrderStatus,
        updateOrderStatus,
      };
