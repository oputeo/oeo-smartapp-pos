import mongoose from 'mongoose';

const cartItemSchema = new mongoose.Schema({
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  name: String,
  price: Number,
  qty: { type: Number, required: true, min: 1 },
  subtotal: Number
});

const cartSchema = new mongoose.Schema({
  tenantId: { type: String, required: true },
  items: [cartItemSchema],
  total: { type: Number, default: 0 },
  customerName: String,
  customerPhone: String
}, { timestamps: true });

export const Cart = mongoose.model('Cart', cartSchema); 
