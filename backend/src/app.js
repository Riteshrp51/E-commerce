const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/authRoutes');
const productRoutes = require('./routes/productRoutes');
const cartRoutes = require('./routes/cartRoutes');
const orderRoutes = require('./routes/orderRoutes');
const { notFound, errorHandler } = require('./middlewares/errorHandler');

const app = express();

// Standard middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static assets (images and icons from greencart_assets)
const assetsPath = path.join(__dirname, '..', '..', 'greencart_assets');
app.use('/assets', express.static(assetsPath));

// Health / Welcome route
app.get('/', (req, res) => {
  res.json({
    success: true,
    name: 'GreenCart E-Commerce REST API',
    version: '1.0.0',
    status: 'online',
    endpoints: {
      auth: '/api/auth',
      products: '/api/products',
      categories: '/api/products/categories',
      cart: '/api/cart',
      orders: '/api/orders',
    },
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);

// Fallback error handlers
app.use(notFound);
app.use(errorHandler);

module.exports = app;

