import mongoose from 'mongoose';
import { tenantField } from './tenant';

const driverSchema = new mongoose.Schema({
  ...tenantField,
  name: String,
  phone: String,
  qrCode: String
});

export const Driver = mongoose.model('Driver', driverSchema);