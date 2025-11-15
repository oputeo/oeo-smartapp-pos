import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axios from 'axios';

const API_URL = 'http://localhost:5000/api/pos';

interface Product {
  _id: string;
  name: string;
  price: number;
  stock: number;
  barcode?: string;
}

interface CartItem {
  product: Product;
  qty: number;
  subtotal: number;
}

export const POS = () => {
  const [cart, setCart] = useState<CartItem[]>([]);
  const [barcode, setBarcode] = useState('');
  const [customerName, setCustomerName] = useState('');
  const [paymentMethod, setPaymentMethod] = useState('cash');
  const [showReceipt, setShowReceipt] = useState<any>(null);

  const queryClient = useQueryClient();

  // Fetch Products
  const { data: products = [] } = useQuery<Product[]>({
    queryKey: ['products'],
    queryFn: () => axios.get(`${API_URL}/products`).then(res => res.data),
  });

  // Add to Cart Mutation
  const addToCart = useMutation({
    mutationFn: (data: { productId: string; qty: number }) =>
      axios.post(`${API_URL}/cart/add`, data),
    onSuccess: (res) => {
      setCart(res.data.items.map((i: any) => ({
        product: i,
        qty: i.qty,
        subtotal: i.subtotal
      })));
    },
  });

  // Checkout Mutation
  const checkout = useMutation({
    mutationFn: () =>
      axios.post(`${API_URL}/checkout`, { paymentMethod, customerName }),
    onSuccess: (res) => {
      setShowReceipt(res.data);
      setCart([]);
      setBarcode('');
      setCustomerName('');
    },
  });

  // Barcode Scanner Simulation
  useEffect(() => {
    if (barcode.length === 13) {
      const product = products.find(p => p.barcode === barcode);
      if (product) {
        addToCart.mutate({ productId: product._id, qty: 1 });
      }
      setBarcode('');
    }
  }, [barcode, products]);

  const total = cart.reduce((sum, i) => sum + i.subtotal, 0);

  return (
    <div className="max-w-6xl mx-auto p-4">
      <h1 className="text-3xl font-bold text-center mb-6">OEO SUPERMARKET POS</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Products */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow p-4">
            <h2 className="text-xl font-semibold mb-4">Products</h2>
            <input
              type="text"
              placeholder="Scan barcode..."
              value={barcode}
              onChange={(e) => setBarcode(e.target.value)}
              className="w-full p-3 border rounded mb-4 text-lg"
              autoFocus
            />
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3 max-h-96 overflow-y-auto">
              {products.map((p) => (
                <button
                  key={p._id}
                  onClick={() => addToCart.mutate({ productId: p._id, qty: 1 })}
                  className="p-3 bg-blue-100 hover:bg-blue-200 rounded text-left transition"
                  disabled={p.stock === 0}
                >
                  <div className="font-medium">{p.name}</div>
                  <div className="text-sm text-gray-600">₦{p.price}</div>
                  <div className="text-xs text-red-600">{p.stock > 0 ? `${p.stock} left` : 'Out of stock'}</div>
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Cart */}
        <div>
          <div className="bg-white rounded-lg shadow p-4">
            <h2 className="text-xl font-semibold mb-4">Cart ({cart.length})</h2>
            <div className="space-y-2 max-h-64 overflow-y-auto">
              {cart.map((item, i) => (
                <div key={i} className="flex justify-between text-sm p-2 bg-gray-50 rounded">
                  <div>
                    <div className="font-medium">{item.product.name}</div>
                    <div className="text-xs text-gray-600">₦{item.product.price} × {item.qty}</div>
                  </div>
                  <div className="font-semibold">₦{item.subtotal}</div>
                </div>
              ))}
            </div>
            <div className="border-t mt-4 pt-4">
              <div className="flex justify-between text-xl font-bold">
                <span>Total</span>
                <span>₦{total.toFixed(2)}</span>
              </div>
            </div>

            <div className="mt-4 space-y-3">
              <input
                type="text"
                placeholder="Customer name (optional)"
                value={customerName}
                onChange={(e) => setCustomerName(e.target.value)}
                className="w-full p-2 border rounded"
              />
              <select
                value={paymentMethod}
                onChange={(e) => setPaymentMethod(e.target.value)}
                className="w-full p-2 border rounded"
              >
                <option value="cash">Cash</option>
                <option value="card">Card</option>
                <option value="mobile">Mobile Money</option>
              </select>
              <button
                onClick={() => checkout.mutate()}
                disabled={cart.length === 0 || checkout.isPending}
                className="w-full bg-green-600 text-white py-3 rounded font-semibold hover:bg-green-700 disabled:bg-gray-400"
              >
                {checkout.isPending ? 'Processing...' : 'Checkout & Print'}
              </button>
            </div>
          </div>

          {/* Receipt Modal */}
          {showReceipt && (
            <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
              <div className="bg-white rounded-lg p-6 max-w-md w-full">
                <h3 className="text-xl font-bold mb-4">Payment Successful!</h3>
                <p>Receipt ID: <strong>{showReceipt.receipt.receiptId}</strong></p>
                <p>Total: <strong>₦{showReceipt.receipt.total}</strong></p>
                <div className="mt-4 flex gap-2">
                  <a
                    href={`${API_URL}/receipt/${showReceipt.receipt._id}/pdf`}
                    target="_blank"
                    className="flex-1 bg-blue-600 text-white py-2 rounded text-center"
                  >
                    Download PDF
                  </a>
                  <button
                    onClick={() => setShowReceipt(null)}
                    className="flex-1 bg-gray-600 text-white py-2 rounded"
                  >
                    Close
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};