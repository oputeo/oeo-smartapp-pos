import mongoose from 'mongoose';
import { tenantField } from './tenant';

const equipmentSchema = new mongoose.Schema({
  ...tenantField,
  name: String,
  serial: String,
  leasePrice: Number,
  status: { type: String, enum: ['available', 'leased', 'servicing'] }
});

export const Equipment = mongoose.model('Equipment', equipmentSchema);