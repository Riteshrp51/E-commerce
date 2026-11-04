require('dotenv').config();
const http = require('http');
const app = require('./src/app');
const { connectDB, disconnectDB } = require('./src/config/db');

// Lightweight test runner using native Node.js fetch / http
async function runTests() {
  console.log('\n======================================================');
  console.log('   RUNNING DAILYMART REST API AUTOMATED TEST SUITE    ');
  console.log('======================================================\n');

  await connectDB();

  const Product = require('./src/models/Product');
  const { sampleProducts } = require('./src/seeders/seedProducts');
  const pCount = await Product.countDocuments();
  if (pCount === 0) {
    await Product.insertMany(sampleProducts);
  }

  const server = http.createServer(app);
  await new Promise((resolve) => server.listen(5001, resolve));
  const baseUrl = 'http://127.0.0.1:5001';

  let passed = 0;
  let failed = 0;
  let token = null;
  let testProductId = null;
  let testOrderId = null;
  let initialStock = null;

  async function test(name, fn) {
    try {
      await fn();
      console.log(`  \x1b[32m✔ PASS\x1b[0m - ${name}`);
      passed++;
    } catch (err) {
      console.error(`  \x1b[31m✖ FAIL\x1b[0m - ${name}`);
      console.error(`         Error: ${err.message}`);
      failed++;
    }
  }

  try {
    // 1. Health check
    await test('GET / - API health & status check', async () => {
      const res = await fetch(`${baseUrl}/`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.success || json.status !== 'online') throw new Error('Unhealthy status');
    });

    // 2. Static Assets
    await test('GET /assets/logo.svg - Static asset serving check', async () => {
      const res = await fetch(`${baseUrl}/assets/logo.svg`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
    });

    // 3. Register a new user
    const uniqueEmail = `test_${Date.now()}@example.com`;
    await test('POST /api/auth/register - Register customer', async () => {
      const res = await fetch(`${baseUrl}/api/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: 'Jane Tester',
          email: uniqueEmail,
          password: 'securePassword123',
        }),
      });
      if (res.status !== 201) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.token || !json.user) throw new Error('No token or user returned');
      token = json.token;
    });

    // 4. Login existing user
    await test('POST /api/auth/login - Authenticate registered customer', async () => {
      const res = await fetch(`${baseUrl}/api/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: uniqueEmail,
          password: 'securePassword123',
        }),
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.token) throw new Error('No token returned');
      token = json.token; // Use fresh token
    });

    // 5. Auth Me
    await test('GET /api/auth/me - Protected session check', async () => {
      const res = await fetch(`${baseUrl}/api/auth/me`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.user.email !== uniqueEmail) throw new Error('User email mismatch');
    });

    // 6. List products
    await test('GET /api/products - List all products catalog', async () => {
      const res = await fetch(`${baseUrl}/api/products`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.data || json.data.length === 0) throw new Error('Empty product list');
      testProductId = json.data[0]._id;
      initialStock = json.data[0].stock;
    });

    // 7. Get categories
    await test('GET /api/products/categories - Fetch distinct categories', async () => {
      const res = await fetch(`${baseUrl}/api/products/categories`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.categories || json.categories.length < 5) throw new Error('Fewer than 5 categories found');
    });

    // 8. Filter by category
    await test('GET /api/products?category=Vegetables - Category filter', async () => {
      const res = await fetch(`${baseUrl}/api/products?category=Vegetables`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      const allVeggies = json.data.every((p) => p.category === 'Vegetables');
      if (!allVeggies || json.data.length === 0) throw new Error('Non-vegetable items returned');
    });

    // 9. Search by name
    await test('GET /api/products?search=Rice - Keyword search', async () => {
      const res = await fetch(`${baseUrl}/api/products?search=Rice`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.data.length === 0) throw new Error('No search results found');
      const matches = json.data.some((p) => p.name.toLowerCase().includes('rice'));
      if (!matches) throw new Error('Results do not match search query');
    });

    // 10. Product details by ID
    await test(`GET /api/products/:id - Single product details`, async () => {
      const res = await fetch(`${baseUrl}/api/products/${testProductId}`);
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.data._id !== testProductId) throw new Error('ID mismatch');
    });

    // 11. Get Cart (initial empty)
    await test('GET /api/cart - Fetch current user cart', async () => {
      const res = await fetch(`${baseUrl}/api/cart`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!Array.isArray(json.data.items)) throw new Error('Invalid cart format');
    });

    // 12. Add item to Cart
    await test('POST /api/cart/items - Add product to cart', async () => {
      const res = await fetch(`${baseUrl}/api/cart/items`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          productId: testProductId,
          quantity: 2,
        }),
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      const found = json.data.items.find((i) => i.productId === testProductId);
      if (!found || found.quantity !== 2) throw new Error('Cart item quantity mismatch');
    });

    // 13. Update item quantity in Cart
    await test('PATCH /api/cart/items/:id - Update cart item quantity to 3', async () => {
      const res = await fetch(`${baseUrl}/api/cart/items/${testProductId}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ quantity: 3 }),
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      const found = json.data.items.find((i) => i.productId === testProductId);
      if (!found || found.quantity !== 3) throw new Error('Cart item update failed');
    });

    // 14. Place Order (Checkout)
    await test('POST /api/orders - Place order and calculate totals on backend', async () => {
      const res = await fetch(`${baseUrl}/api/orders`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          deliveryAddress: {
            fullName: 'Jane Tester',
            phone: '+91 9123456789',
            street: '42 Garden View',
            city: 'Bengaluru',
            state: 'Karnataka',
            postalCode: '560001',
          },
          paymentType: 'COD',
        }),
      });
      if (res.status !== 201) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (!json.data || !json.data._id) throw new Error('Order creation failed');
      testOrderId = json.data._id;
      if (json.data.status !== 'Pending') throw new Error(`Expected Pending status, got ${json.data.status}`);
      if (json.data.totalAmount <= 0) throw new Error('Total amount must be greater than 0');
    });

    // 15. Verify stock reduction
    await test('Stock Reduction Check - Verify inventory decremented by 3', async () => {
      const res = await fetch(`${baseUrl}/api/products/${testProductId}`);
      const json = await res.json();
      const expectedStock = initialStock - 3;
      if (json.data.stock !== expectedStock) {
        throw new Error(`Expected stock ${expectedStock}, got ${json.data.stock}`);
      }
    });

    // 16. Verify cart cleared after checkout
    await test('Cart Cleared Check - Verify cart emptied post-order', async () => {
      const res = await fetch(`${baseUrl}/api/cart`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const json = await res.json();
      if (json.data.items.length !== 0) throw new Error('Cart should be empty after placing order');
    });

    // 17. Get user orders
    await test('GET /api/orders - List user order history', async () => {
      const res = await fetch(`${baseUrl}/api/orders`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.data.length === 0) throw new Error('Expected at least 1 order');
    });

    // 18. Get order details by ID
    await test('GET /api/orders/:id - Fetch single order details', async () => {
      const res = await fetch(`${baseUrl}/api/orders/${testOrderId}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.data._id !== testOrderId) throw new Error('Order ID mismatch');
      if (json.data.items.length === 0) throw new Error('No items in order snapshot');
    });

    // 19. Check order status (GET)
    await test('GET /api/orders/:id/status - Fetch order status directly', async () => {
      const res = await fetch(`${baseUrl}/api/orders/${testOrderId}/status`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.status !== 'Pending') throw new Error(`Expected Pending, got ${json.status}`);
    });

    // 20. Update order status (supports lowercase 'shipped')
    await test('PATCH /api/orders/:id/status - Update order status to Shipped', async () => {
      const res = await fetch(`${baseUrl}/api/orders/${testOrderId}/status`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ status: 'shipped' }),
      });
      if (res.status !== 200) throw new Error(`Status ${res.status}`);
      const json = await res.json();
      if (json.status !== 'Shipped') throw new Error(`Expected Shipped, got ${json.status}`);
    });

  } finally {
    server.close();
    await disconnectDB();
  }

  console.log('\n------------------------------------------------------');
  console.log(` Results: ${passed} PASSED, ${failed} FAILED`);
  console.log('------------------------------------------------------\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error('Fatal test error:', err);
  process.exit(1);
});

