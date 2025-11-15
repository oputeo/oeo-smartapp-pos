import mongoose from 'mongoose';
import { tenantField } from './tenant';

const businessSchema = new mongoose.Schema({
  ...tenantField,
  name: { type: String, required: true },
  branches: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Branch' }]
});

export const Business = mongoose.model('Business', businessSchema);