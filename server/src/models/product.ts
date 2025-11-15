 import mongoose from 'mongoose';

const productSchema = new mongoose.Schema({
  tenantId: { type: String, required: true, index: true },
  name: { type: String, required: true },
  barcode: { type: String, unique: true, sparse: true },
  price: { type: Number, required: true },
  category: String,
  stock: { type: Number, default: 0 },
  expiryDate: Date,
  image: String
}, { timestamps: true });

export const Product = mongoose.model('Product', productSchema);
