import mongoose from 'mongoose';
import { tenantField } from './tenant';

const branchSchema = new mongoose.Schema({
  ...tenantField,
  name: String,
  business: { type: mongoose.Schema.Types.ObjectId, ref: 'Business' }
});

export const Branch = mongoose.model('Branch', branchSchema);