require('dotenv').config({ path: require('path').join(__dirname, '..', '..', '.env') });
const mongoose = require('mongoose');
const { connectDB, disconnectDB } = require('../config/db');
const Product = require('../models/Product');
const User = require('../models/User');
const Cart = require('../models/Cart');

const sampleProducts = [
  // 1. Vegetables
  {
    name: 'Potato 500g',
    category: 'Vegetables',
    price: 25,
    offerPrice: 20,
    imageUrl: '/assets/potato_image_1.png',
    images: [
      '/assets/potato_image_1.png',
      '/assets/potato_image_2.png',
      '/assets/potato_image_3.png',
      '/assets/potato_image_4.png',
    ],
    description: 'Fresh and organic potatoes. Rich in carbohydrates and dietary fiber. Ideal for curries, baking, and fries.',
    stock: 60,
    inStock: true,
  },
  {
    name: 'Tomato 1 kg',
    category: 'Vegetables',
    price: 40,
    offerPrice: 35,
    imageUrl: '/assets/tomato_image.png',
    images: ['/assets/tomato_image.png'],
    description: 'Juicy and ripe farm-fresh tomatoes. Rich in Vitamin C and lycopene. Perfect for fresh salads and rich sauces.',
    stock: 50,
    inStock: true,
  },
  {
    name: 'Carrot 500g',
    category: 'Vegetables',
    price: 30,
    offerPrice: 28,
    imageUrl: '/assets/carrot_image.png',
    images: ['/assets/carrot_image.png'],
    description: 'Sweet and crunchy orange carrots. Great for eyesight, rich in beta-carotene. Ideal for juices, stir-fries and salads.',
    stock: 45,
    inStock: true,
  },
  {
    name: 'Spinach 500g',
    category: 'Vegetables',
    price: 18,
    offerPrice: 15,
    imageUrl: '/assets/spinach_image_1.png',
    images: ['/assets/spinach_image_1.png'],
    description: 'Crisp leafy greens rich in iron and essential minerals. High in vitamins A, C, and K. Perfect for soups and smoothies.',
    stock: 40,
    inStock: true,
  },
  {
    name: 'Onion 500g',
    category: 'Vegetables',
    price: 22,
    offerPrice: 19,
    imageUrl: '/assets/onion_image_1.png',
    images: ['/assets/onion_image_1.png'],
    description: 'Fresh, pungent red onions. Essential kitchen staple that adds depth and rich flavor to any savoury recipe.',
    stock: 55,
    inStock: true,
  },

  // 2. Fruits
  {
    name: 'Apple 1 kg',
    category: 'Fruits',
    price: 120,
    offerPrice: 110,
    imageUrl: '/assets/apple_image.png',
    images: ['/assets/apple_image.png'],
    description: 'Crisp and juicy sweet red apples. Rich in antioxidants and dietary fiber. Boosts immunity and perfect for snacking.',
    stock: 50,
    inStock: true,
  },
  {
    name: 'Orange 1 kg',
    category: 'Fruits',
    price: 80,
    offerPrice: 75,
    imageUrl: '/assets/orange_image.png',
    images: ['/assets/orange_image.png'],
    description: 'Juicy, tangy citrus oranges loaded with Vitamin C and natural sweetness. Perfect for refreshing morning juices.',
    stock: 40,
    inStock: true,
  },
  {
    name: 'Banana 1 kg',
    category: 'Fruits',
    price: 50,
    offerPrice: 45,
    imageUrl: '/assets/banana_image_1.png',
    images: ['/assets/banana_image_1.png'],
    description: 'Naturally sweet and ripe golden bananas. High in potassium and sustained energy. Ideal for smoothies and breakfast.',
    stock: 65,
    inStock: true,
  },
  {
    name: 'Mango 1 kg',
    category: 'Fruits',
    price: 150,
    offerPrice: 140,
    imageUrl: '/assets/mango_image_1.png',
    images: ['/assets/mango_image_1.png'],
    description: 'Luscious, fragrant and succulent tropical mangoes. Bursting with sweet flavor and rich in Vitamin A.',
    stock: 30,
    inStock: true,
  },
  {
    name: 'Grapes 500g',
    category: 'Fruits',
    price: 70,
    offerPrice: 65,
    imageUrl: '/assets/grapes_image_1.png',
    images: ['/assets/grapes_image_1.png'],
    description: 'Crisp, seedless fresh grapes bursting with sweetness. Packed with natural antioxidants and vitamins.',
    stock: 35,
    inStock: true,
  },

  // 3. Dairy
  {
    name: 'Amul Milk 1L',
    category: 'Dairy',
    price: 60,
    offerPrice: 55,
    imageUrl: '/assets/amul_milk_image.png',
    images: ['/assets/amul_milk_image.png'],
    description: 'Pure, pasteurized fresh toned milk. Rich in calcium and wholesome proteins. Perfect for tea, coffee, and cereal.',
    stock: 80,
    inStock: true,
  },
  {
    name: 'Fresh Paneer 200g',
    category: 'Dairy',
    price: 90,
    offerPrice: 85,
    imageUrl: '/assets/paneer_image.png',
    images: ['/assets/paneer_image.png', '/assets/paneer_image_2.png'],
    description: 'Soft, creamy, fresh cottage cheese. High-protein dairy choice ideal for curries, grilling, and paneer tikka.',
    stock: 45,
    inStock: true,
  },
  {
    name: 'Eggs 12 pcs',
    category: 'Dairy',
    price: 90,
    offerPrice: 85,
    imageUrl: '/assets/eggs_image.png',
    images: ['/assets/eggs_image.png'],
    description: 'Farm fresh brown eggs with rich golden yolks. Superb source of complete proteins and healthy nutrients.',
    stock: 50,
    inStock: true,
  },
  {
    name: 'Cheese Block 200g',
    category: 'Dairy',
    price: 140,
    offerPrice: 130,
    imageUrl: '/assets/cheese_image.png',
    images: ['/assets/cheese_image.png'],
    description: 'Deliciously creamy processed cheese. Melts smoothly over pizzas, burgers, toast, and gourmet sandwiches.',
    stock: 40,
    inStock: true,
  },

  // 4. Drinks
  {
    name: 'Coca-Cola 1.5L',
    category: 'Drinks',
    price: 80,
    offerPrice: 75,
    imageUrl: '/assets/coca_cola_image.png',
    images: ['/assets/coca_cola_image.png'],
    description: 'Classic effervescent and refreshing cola taste. Best enjoyed chilled during parties, lunches, and gatherings.',
    stock: 70,
    inStock: true,
  },
  {
    name: 'Pepsi 1.5L',
    category: 'Drinks',
    price: 78,
    offerPrice: 73,
    imageUrl: '/assets/pepsi_image.png',
    images: ['/assets/pepsi_image.png'],
    description: 'Bold, crisp, refreshing carbonated soft drink. Perfectly chilled thirst quencher for celebrations.',
    stock: 60,
    inStock: true,
  },
  {
    name: 'Sprite 1.5L',
    category: 'Drinks',
    price: 79,
    offerPrice: 74,
    imageUrl: '/assets/sprite_image_1.png',
    images: ['/assets/sprite_image_1.png'],
    description: 'Crisp lemon-lime sparkling beverage with a clean, light, and invigorating taste.',
    stock: 50,
    inStock: true,
  },
  {
    name: 'Fanta 1.5L',
    category: 'Drinks',
    price: 77,
    offerPrice: 72,
    imageUrl: '/assets/fanta_image_1.png',
    images: ['/assets/fanta_image_1.png'],
    description: 'Fruity, vibrant, bright orange sparkling drink that brings playful refreshment to any occasion.',
    stock: 45,
    inStock: true,
  },
  {
    name: '7 Up 1.5L',
    category: 'Drinks',
    price: 76,
    offerPrice: 71,
    imageUrl: '/assets/seven_up_image_1.png',
    images: ['/assets/seven_up_image_1.png'],
    description: 'Clear, crisp lemon-lime beverage offering a refreshing surge of bubbles and taste.',
    stock: 50,
    inStock: true,
  },

  // 5. Grains
  {
    name: 'Basmati Rice 5kg',
    category: 'Grains',
    price: 550,
    offerPrice: 520,
    imageUrl: '/assets/basmati_rice_image.png',
    images: ['/assets/basmati_rice_image.png'],
    description: 'Extra long grain royal aromatic basmati rice. Fluffy, non-sticky texture perfect for festive biryanis and pulaos.',
    stock: 35,
    inStock: true,
  },
  {
    name: 'Wheat Flour 5kg',
    category: 'Grains',
    price: 250,
    offerPrice: 230,
    imageUrl: '/assets/wheat_flour_image.png',
    images: ['/assets/wheat_flour_image.png'],
    description: '100% whole grain chakki fresh atta. Produces delightfully soft, fluffy, and wholesome rotis every time.',
    stock: 40,
    inStock: true,
  },
  {
    name: 'Organic Quinoa 500g',
    category: 'Grains',
    price: 450,
    offerPrice: 420,
    imageUrl: '/assets/quinoa_image.png',
    images: ['/assets/quinoa_image.png'],
    description: 'Certified organic, gluten-free superfood quinoa. High in plant protein, dietary fiber, and essential amino acids.',
    stock: 25,
    inStock: true,
  },
  {
    name: 'Brown Rice 1kg',
    category: 'Grains',
    price: 120,
    offerPrice: 110,
    imageUrl: '/assets/brown_rice_image.png',
    images: ['/assets/brown_rice_image.png'],
    description: 'Nutritious unpolished whole grain brown rice with a pleasant nutty flavor. Supports digestive wellness.',
    stock: 30,
    inStock: true,
  },
  {
    name: 'Pearl Barley 1kg',
    category: 'Grains',
    price: 150,
    offerPrice: 140,
    imageUrl: '/assets/barley_image.png',
    images: ['/assets/barley_image.png'],
    description: 'Wholesome pearl barley grains rich in soluble fiber. Excellent for hearty soups, broths, and healthy bowls.',
    stock: 25,
    inStock: true,
  },

  // 6. Bakery
  {
    name: 'Brown Bread 400g',
    category: 'Bakery',
    price: 40,
    offerPrice: 35,
    imageUrl: '/assets/brown_bread_image.png',
    images: ['/assets/brown_bread_image.png'],
    description: 'Freshly baked whole wheat brown bread. Soft slices fortified with wheat bran and fiber for wholesome sandwiches.',
    stock: 40,
    inStock: true,
  },
  {
    name: 'Butter Croissant 100g',
    category: 'Bakery',
    price: 50,
    offerPrice: 45,
    imageUrl: '/assets/butter_croissant_image.png',
    images: ['/assets/butter_croissant_image.png'],
    description: 'Flaky, golden-brown artisanal pastry baked with real European butter. Warm, delicate, and deeply flavorful.',
    stock: 30,
    inStock: true,
  },
  {
    name: 'Chocolate Cake 500g',
    category: 'Bakery',
    price: 350,
    offerPrice: 325,
    imageUrl: '/assets/chocolate_cake_image.png',
    images: ['/assets/chocolate_cake_image.png'],
    description: 'Decadent, rich dark chocolate fudge cake layered with smooth chocolate ganache. Ideal for celebrations.',
    stock: 20,
    inStock: true,
  },
  {
    name: 'Whole Wheat Bread 400g',
    category: 'Bakery',
    price: 45,
    offerPrice: 40,
    imageUrl: '/assets/whole_wheat_bread_image.png',
    images: ['/assets/whole_wheat_bread_image.png'],
    description: 'Hearty whole wheat sandwich bread. No refined flour, perfectly soft crumb for morning toast and toasties.',
    stock: 35,
    inStock: true,
  },
  {
    name: 'Vanilla Muffins 6 pcs',
    category: 'Bakery',
    price: 100,
    offerPrice: 90,
    imageUrl: '/assets/vanilla_muffins_image.png',
    images: ['/assets/vanilla_muffins_image.png'],
    description: 'Soft, fluffy bakery-style muffins flavored with pure Madagascar vanilla extract. Great with tea or coffee.',
    stock: 30,
    inStock: true,
  },

  // 7. Instant
  {
    name: 'Maggi Noodles 280g',
    category: 'Instant',
    price: 55,
    offerPrice: 50,
    imageUrl: '/assets/maggi_image.png',
    images: ['/assets/maggi_image.png'],
    description: 'Beloved instant 2-minute masala noodles made with authentic roasted spices. Quick, nostalgic comfort food.',
    stock: 80,
    inStock: true,
  },
  {
    name: 'Top Ramen Curry 270g',
    category: 'Instant',
    price: 45,
    offerPrice: 40,
    imageUrl: '/assets/top_ramen_image.png',
    images: ['/assets/top_ramen_image.png'],
    description: 'Flat instant ramen noodles with a tangy and spicy curry seasoning that will satisfy sudden hunger cravings.',
    stock: 60,
    inStock: true,
  },
  {
    name: 'Knorr Cup Soup 70g',
    category: 'Instant',
    price: 35,
    offerPrice: 30,
    imageUrl: '/assets/knorr_soup_image.png',
    images: ['/assets/knorr_soup_image.png'],
    description: 'Ready-in-minutes rich tomato herb soup with crunchy croutons. Warming, comforting, and tasty.',
    stock: 50,
    inStock: true,
  },
  {
    name: 'Yippee Magic Masala 260g',
    category: 'Instant',
    price: 50,
    offerPrice: 45,
    imageUrl: '/assets/yippee_image.png',
    images: ['/assets/yippee_image.png'],
    description: 'Round non-sticky noodle blocks that give long slurpy noodles, infused with delectable veggies and aromatic spice mix.',
    stock: 60,
    inStock: true,
  },
  {
    name: 'Maggi Oats Noodles 72g',
    category: 'Instant',
    price: 40,
    offerPrice: 35,
    imageUrl: '/assets/maggi_oats_image.png',
    images: ['/assets/maggi_oats_image.png'],
    description: 'Wholesome oats noodles seasoned with appetizing Indian spices. Good source of dietary fiber and quick energy.',
    stock: 45,
    inStock: true,
  },
];

const seedData = async () => {
  try {
    console.log('Seeding GreenCart database...');
    await connectDB();

    // 1. Clean existing products and carts
    await Product.deleteMany({});
    console.log('Cleared existing product catalog.');

    // 2. Insert GreenCart products
    const insertedProducts = await Product.insertMany(sampleProducts);
    console.log(`Successfully seeded ${insertedProducts.length} GreenCart products across 7 categories.`);

    // 3. Ensure a demo customer user exists
    let demoUser = await User.findOne({ email: 'demo@greencart.com' });
    if (!demoUser) {
      const passwordHash = await User.hashPassword('password123');
      demoUser = await User.create({
        name: 'Demo Customer',
        email: 'demo@greencart.com',
        passwordHash,
        role: 'customer',
      });
      console.log('Created demo user: demo@greencart.com (password: password123)');
    }

    // Ensure cart exists for demo user
    let demoCart = await Cart.findOne({ userId: demoUser._id });
    if (!demoCart) {
      demoCart = await Cart.create({
        userId: demoUser._id,
        items: [
          { productId: insertedProducts[0]._id, quantity: 2 },
          { productId: insertedProducts[5]._id, quantity: 1 },
        ],
      });
      console.log('Preloaded demo cart with sample items.');
    }

    console.log('Database seeding complete!');
    await disconnectDB();
    process.exit(0);
  } catch (err) {
    console.error('Error during database seeding:', err);
    process.exit(1);
  }
};

if (require.main === module) {
  seedData();
}

module.exports = { sampleProducts, seedData };

