import { useNavigate } from 'react-router-dom'
import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'
import Button from '../ui/Button'

export default function CartSummary({ showCheckoutButton = true }) {
  const navigate = useNavigate()
  const { getSubtotal, getTax, getShippingCost, getTotal } = useCartStore()

  const subtotal = getSubtotal()
  const tax = getTax()
  const shipping = getShippingCost()
  const total = getTotal()

  return (
    <div className="bg-gray-50 rounded-xl p-6 border border-gray-200">
      <h2 className="font-semibold text-gray-900 text-lg mb-4">Order Summary</h2>

      <div className="space-y-2 text-sm">
        <div className="flex justify-between text-gray-600">
          <span>Subtotal</span>
          <span>{formatCurrency(subtotal)}</span>
        </div>
        <div className="flex justify-between text-gray-600">
          <span>Tax (8%)</span>
          <span>{formatCurrency(tax)}</span>
        </div>
        <div className="flex justify-between text-gray-600">
          <span>Shipping</span>
          <span className={shipping === 0 ? 'text-green-600 font-medium' : ''}>
            {shipping === 0 ? 'Free' : formatCurrency(shipping)}
          </span>
        </div>
        {shipping > 0 && (
          <p className="text-xs text-gray-400">Free shipping on orders over $50</p>
        )}
        <div className="border-t border-gray-300 pt-2 mt-2 flex justify-between font-bold text-gray-900 text-base">
          <span>Total</span>
          <span>{formatCurrency(total)}</span>
        </div>
      </div>

      {showCheckoutButton && (
        <Button
          onClick={() => navigate('/checkout')}
          className="w-full mt-5 py-3"
        >
          Proceed to Checkout
        </Button>
      )}
    </div>
  )
}
