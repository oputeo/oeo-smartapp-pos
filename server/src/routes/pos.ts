import express from 'express';
import { Product } from '../models/product';
import { Cart } from '../models/cart';
import { Receipt } from '../models/receipt';

const router = express.Router();

// GET: Load products
router.get('/products', async (req: any, res) => {
  const products = await Product.find({ tenantId: req.tenantId }).select('name barcode price stock');
  res.json(products);
});

// POST: Add to cart
router.post('/cart/add', async (req: any, res) => {
  const { productId, qty } = req.body;
  const product = await Product.findOne({ _id: productId, tenantId: req.tenantId });
  if (!product || product.stock < qty) return res.status(400).json({ msg: 'Out of stock' });

  let cart = await Cart.findOne({ tenantId: req.tenantId });
  if (!cart) cart = new Cart({ tenantId: req.tenantId, items: [] });

  const existing = cart.items.find(i => i.product.toString() === productId);
  if (existing) {
    existing.qty += qty;
    existing.subtotal = existing.price * existing.qty;
  } else {
    cart.items.push({
      product: product._id,
      name: product.name,
      price: product.price,
      qty,
      subtotal: product.price * qty
    });
  }

  cart.total = cart.items.reduce((sum, i) => sum + i.subtotal, 0);
  await cart.save();
  res.json(cart);
});

// POST: Checkout
router.post('/checkout', async (req: any, res) => {
  const { paymentMethod, customerName, customerPhone } = req.body;
  const cart = await Cart.findOne({ tenantId: req.tenantId }).populate('items.product');
  if (!cart || cart.items.length === 0) return res.status(400).json({ msg: 'Cart empty' });

  // Update stock
  for (const item of cart.items) {
    await Product.updateOne(
      { _id: item.product, tenantId: req.tenantId },
      { $inc: { stock: -item.qty } }
    );
  }

  // Generate receipt
  const receipt = new Receipt({
    tenantId: req.tenantId,
    receiptId: `REC-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    items: cart.items.map(i => ({
      name: i.name,
      qty: i.qty,
      price: i.price,
      subtotal: i.subtotal
    })),
    total: cart.total,
    paymentMethod,
    customerName,
    customerPhone,
    cashier: 'Cashier'
  });

  await receipt.save();
  await Cart.deleteOne({ _id: cart._id });

  res.json({ msg: 'Payment successful', receipt });
});

export default router; 
