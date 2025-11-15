import mongoose from 'mongoose';

const receiptItemSchema = new mongoose.Schema({
  name: String,
  qty: Number,
  price: Number,
  subtotal: Number
});

const receiptSchema = new mongoose.Schema({
  tenantId: { type: String, required: true },
  receiptId: { type: String, unique: true },
  items: [receiptItemSchema],
  total: Number,
  paymentMethod: { type: String, enum: ['cash', 'card', 'mobile'], required: true },
  customerName: String,
  customerPhone: String,
  cashier: String,
  date: { type: Date, default: Date.now }
}, { timestamps: true });

export const Receipt = mongoose.model('Receipt', receiptSchema);