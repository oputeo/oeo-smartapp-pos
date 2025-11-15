import mongoose from 'mongoose';
import { tenantField } from './tenant';

const invoiceSchema = new mongoose.Schema({
  ...tenantField,
  customer: String,
  items: [{ product: String, qty: Number, price: Number }],
  total: Number,
  date: { type: Date, default: Date.now }
});

export const Invoice = mongoose.model('Invoice', invoiceSchema);