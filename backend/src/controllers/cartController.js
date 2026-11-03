const Cart = require('../models/Cart');
const Product = require('../models/Product');

// Helper to compute prices, totals and format populated cart
const formatCart = (cart) => {
  let subtotal = 0;
  let totalItems = 0;

  const items = (cart.items || [])
    .filter((item) => item.productId) // Product exists
    .map((item) => {
      const p = item.productId;
      const unitPrice =
        p.offerPrice && p.offerPrice > 0 ? p.offerPrice : p.price;
      const itemTotal = unitPrice * item.quantity;
      subtotal += itemTotal;
      totalItems += item.quantity;

      return {
        _id: item._id,
        productId: p._id,
        name: p.name,
        price: p.price,
        offerPrice: p.offerPrice,
        unitPrice,
        imageUrl: p.imageUrl,
        category: p.category,
        stock: p.stock,
        inStock: p.inStock && p.stock >= item.quantity,
        quantity: item.quantity,
        itemTotal: Math.round(itemTotal * 100) / 100,
      };
    });

  const roundedSubtotal = Math.round(subtotal * 100) / 100;
  const shippingFee = roundedSubtotal > 0 ? (roundedSubtotal >= 500 ? 0 : 40) : 0;
  const total = Math.round((roundedSubtotal + shippingFee) * 100) / 100;

  return {
    _id: cart._id,
    userId: cart.userId,
    items,
    totalItems,
    subtotal: roundedSubtotal,
    shippingFee,
    total,
    updatedAt: cart.updatedAt,
  };
};

// @desc    Get current user's shopping cart
// @route   GET /api/cart
// @access  Private
const getCart = async (req, res, next) => {
  try {
    let cart = await Cart.findOne({ userId: req.user.id }).populate(
      'items.productId'
    );

    if (!cart) {
      cart = await Cart.create({ userId: req.user.id, items: [] });
    }

    res.status(200).json({
      success: true,
      data: formatCart(cart),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Add item to cart or increment quantity
// @route   POST /api/cart/items
// @access  Private
const addToCart = async (req, res, next) => {
  try {
    const { productId, quantity = 1 } = req.body;

    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'productId is required in request body.',
      });
    }

    const qty = parseInt(quantity, 10);
    if (isNaN(qty) || qty < 1) {
      return res.status(400).json({
        success: false,
        message: 'Quantity must be a positive integer greater than or equal to 1.',
      });
    }

    // Verify product exists and has sufficient stock
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: `Product with ID '${productId}' not found.`,
      });
    }

    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      cart = await Cart.create({ userId: req.user.id, items: [] });
    }

    // Check if item already exists in cart
    const existingItemIndex = cart.items.findIndex(
      (item) => item.productId.toString() === productId.toString()
    );

    if (existingItemIndex > -1) {
      const newQty = cart.items[existingItemIndex].quantity + qty;
      if (newQty > product.stock) {
        return res.status(400).json({
          success: false,
          message: `Cannot add more. Only ${product.stock} units available in stock.`,
        });
      }
      cart.items[existingItemIndex].quantity = newQty;
    } else {
      if (qty > product.stock) {
        return res.status(400).json({
          success: false,
          message: `Cannot add ${qty} units. Only ${product.stock} units available in stock.`,
        });
      }
      cart.items.push({ productId, quantity: qty });
    }

    await cart.save();
    cart = await Cart.findById(cart._id).populate('items.productId');

    res.status(200).json({
      success: true,
      message: 'Item added to cart',
      data: formatCart(cart),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update quantity of a cart item
// @route   PATCH /api/cart/items/:id
// @access  Private
const updateCartItemQuantity = async (req, res, next) => {
  try {
    const { id } = req.params; // Can be cart item _id or productId
    const { quantity } = req.body;

    if (quantity === undefined || isNaN(quantity)) {
      return res.status(400).json({
        success: false,
        message: 'quantity is required in request body.',
      });
    }

    const qty = parseInt(quantity, 10);
    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found for this user.',
      });
    }

    const itemIndex = cart.items.findIndex(
      (item) =>
        item._id.toString() === id || item.productId.toString() === id
    );

    if (itemIndex === -1) {
      return res.status(404).json({
        success: false,
        message: `Item '${id}' not found in cart.`,
      });
    }

    if (qty <= 0) {
      // Remove item if quantity is set to 0 or less
      cart.items.splice(itemIndex, 1);
    } else {
      // Check stock availability
      const product = await Product.findById(cart.items[itemIndex].productId);
      if (!product) {
        cart.items.splice(itemIndex, 1);
      } else if (qty > product.stock) {
        return res.status(400).json({
          success: false,
          message: `Cannot set quantity to ${qty}. Only ${product.stock} units available.`,
        });
      } else {
        cart.items[itemIndex].quantity = qty;
      }
    }

    await cart.save();
    cart = await Cart.findById(cart._id).populate('items.productId');

    res.status(200).json({
      success: true,
      message: 'Cart updated successfully',
      data: formatCart(cart),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Remove an item from cart
// @route   DELETE /api/cart/items/:id
// @access  Private
const removeCartItem = async (req, res, next) => {
  try {
    const { id } = req.params;

    let cart = await Cart.findOne({ userId: req.user.id });
    if (!cart) {
      return res.status(404).json({
        success: false,
        message: 'Cart not found.',
      });
    }

    const initialLength = cart.items.length;
    cart.items = cart.items.filter(
      (item) =>
        item._id.toString() !== id && item.productId.toString() !== id
    );

    if (cart.items.length === initialLength) {
      return res.status(404).json({
        success: false,
        message: `Item '${id}' not found in cart.`,
      });
    }

    await cart.save();
    cart = await Cart.findById(cart._id).populate('items.productId');

    res.status(200).json({
      success: true,
      message: 'Item removed from cart',
      data: formatCart(cart),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Clear entire cart
// @route   DELETE /api/cart
// @access  Private
const clearCart = async (req, res, next) => {
  try {
    let cart = await Cart.findOne({ userId: req.user.id });
    if (cart) {
      cart.items = [];
      await cart.save();
    }

    res.status(200).json({
      success: true,
      message: 'Cart cleared successfully',
      data: {
        userId: req.user.id,
        items: [],
        totalItems: 0,
        subtotal: 0,
        shippingFee: 0,
        total: 0,
      },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getCart,
  addToCart,
  updateCartItemQuantity,
  removeCartItem,
  clearCart,
};

