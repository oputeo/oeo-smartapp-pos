// src/models/tenant.ts
import mongoose from 'mongoose';

// Reusable tenant field
export const tenantField = {
  tenantId: {
    type: String,
    required: true,
    enum: ['oeo', 'supermart', 'equiplease'], // Add more later
    index: true
  }
};