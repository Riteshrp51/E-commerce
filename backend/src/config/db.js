const fs = require('fs');
const path = require('path');
const mongoose = require('mongoose');

let memoryServer = null;

// Auto-detect local mongod.exe on Windows if installed
const possibleMongoBinaries = [
  'C:\\Program Files\\MongoDB\\Server\\8.3\\bin\\mongod.exe',
  'C:\\Program Files\\MongoDB\\Server\\8.0\\bin\\mongod.exe',
  'C:\\Program Files\\MongoDB\\Server\\7.0\\bin\\mongod.exe',
  'C:\\Program Files\\MongoDB\\Server\\6.0\\bin\\mongod.exe',
];

for (const binPath of possibleMongoBinaries) {
  if (fs.existsSync(binPath)) {
    process.env.MONGOMS_SYSTEM_BINARY = binPath;
    break;
  }
}

const connectDB = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/greencart';
  
  try {
    // Attempt standard connection first with a fast timeout
    console.log(`Connecting to MongoDB at: ${uri}...`);
    const conn = await mongoose.connect(uri, {
      serverSelectionTimeoutMS: 2500,
    });
    console.log(`MongoDB Connected successfully: ${conn.connection.host}`);
    return conn;
  } catch (primaryErr) {
    console.warn(`Standard MongoDB connection to ${uri} failed: ${primaryErr.message}`);

    if (process.env.USE_MEMORY_DB_IF_LOCAL_FAILS === 'true' || process.env.NODE_ENV !== 'production') {
      try {
        console.log('Spinning up embedded MongoDB Memory Server using local binary...');
        const { MongoMemoryServer } = require('mongodb-memory-server');
        
        memoryServer = await MongoMemoryServer.create({
          instance: {
            dbName: 'greencart',
          },
          binary: {
            systemBinary: process.env.MONGOMS_SYSTEM_BINARY,
          },
        });
        const memUri = memoryServer.getUri();
        
        const conn = await mongoose.connect(memUri);
        console.log(`Connected to in-memory MongoDB successfully at: ${memUri}`);
        return conn;
      } catch (memErr) {
        console.error(`Failed to launch in-memory MongoDB: ${memErr.message}`);
        throw memErr;
      }
    } else {
      throw primaryErr;
    }
  }
};

const disconnectDB = async () => {
  try {
    await mongoose.disconnect();
    if (memoryServer) {
      await memoryServer.stop();
    }
  } catch (err) {
    console.error('Error disconnecting MongoDB:', err);
  }
};

module.exports = { connectDB, disconnectDB };
