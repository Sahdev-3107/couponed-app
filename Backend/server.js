const express = require('express');
const cors = require('cors');

const app = express();
const port = 3000;

// Use CORS middleware to allow cross-origin requests
app.use(cors());

// Dummy coupon data as required by the assessment
const dummyCoupons = [
  {
    "id": 1,
    "title": "Flat 25% OFF on Pizza",
    "description": "Valid on orders above ₹600. T&C apply.",
    "category": "Food",
    "discount": "25%",
    "brand": "Pizza Hut",
  },
  {
    "id": 2,
    "title": "Buy One Get One Free",
    "description": "On all movie tickets this weekend.",
    "category": "Entertainment",
    "discount": "BOGO",
    "brand": "CinemaMax",
  },
  {
    "id": 3,
    "title": "₹150 Cashback on Recharge",
    "description": "Minimum recharge of ₹299.",
    "category": "Recharge",
    "discount": "₹150",
    "brand": "PayNow",
  },
  {
    "id": 4,
    "title": "Save up to 60% on Flights",
    "description": "On international and domestic flights.",
    "category": "Travel",
    "discount": "60%",
    "brand": "FlyHigh",
  },
  {
    "id": 5,
    "title": "Extra 35% OFF on Apparel",
    "description": "On all fashion and lifestyle products.",
    "category": "Fashion",
    "discount": "35%",
    "brand": "StyleUp",
  }
];

// Define the /api/coupons endpoint
app.get('/api/coupons', (req, res) => {
  console.log('GET /api/coupons - Returning dummy coupon data.');
  res.json(dummyCoupons);
});

// Start the server
app.listen(port, () => {
  console.log(`Coupon API server listening at http://localhost:${port}`);
});