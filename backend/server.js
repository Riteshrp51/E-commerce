require('dotenv').config();
const app = require('./src/app');
const { connectDB } = require('./src/config/db');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    await connectDB();

    // Auto-seed if database is empty (e.g. fresh in-memory or new local DB)
    const Product = require('./src/models/Product');
    const { sampleProducts } = require('./src/seeders/seedProducts');
    const count = await Product.countDocuments();
    if (count === 0) {
      console.log('Database is empty. Auto-seeding 34 GreenCart products...');
      await Product.insertMany(sampleProducts);
      console.log('Auto-seeding complete! Products are ready in database.');
    } else {
      console.log(`Database has ${count} products ready.`);
    }

    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`=========================================`);
      console.log(` GreenCart Server is running on port ${PORT}`);
      console.log(` Bound to    : 0.0.0.0 (Accepts LAN & Wi-Fi connections)`);
      console.log(` Environment : ${process.env.NODE_ENV || 'development'}`);
      console.log(` Local URL   : http://localhost:${PORT}/api`);
      console.log(` Network URL : http://192.168.1.14:${PORT}/api`);
      console.log(` Assets URL  : http://192.168.1.14:${PORT}/assets`);
      console.log(`=========================================`);
    });

    const shutdown = async (signal) => {
      console.log(`\nReceived ${signal}. Gracefully shutting down...`);
      server.close(async () => {
        const { disconnectDB } = require('./src/config/db');
        await disconnectDB();
        console.log('Server and database connections terminated.');
        process.exit(0);
      });
    };

    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
};

startServer();

