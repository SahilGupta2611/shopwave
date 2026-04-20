import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'
import Button from '../ui/Button'

export default function OrderReview({ shipping, onBack, onContinue }) {
  const items = useCartStore((s) => s.items)
  const { getSubtotal, getTax, getShippingCost, getTotal } = useCartStore()

  return (
    <div className="space-y-6">
      {/* Shipping address */}
      <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <h3 className="font-semibold text-gray-900 mb-2">Shipping To</h3>
        <p className="text-sm text-gray-600">
          {shipping.firstName} {shipping.lastName}<br />
          {shipping.address}<br />
          {shipping.city}, {shipping.state} {shipping.zip}<br />
          {shipping.email}
        </p>
      </div>

      {/* Items */}
      <div>
        <h3 className="font-semibold text-gray-900 mb-3">Order Items</h3>
        <div className="space-y-3">
          {items.map((item) => (
            <div key={item.productId} className="flex items-center gap-3">
              <img src={item.image} alt={item.name} className="w-12 h-12 object-cover rounded-lg bg-gray-100 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 line-clamp-1">{item.name}</p>
                <p className="text-xs text-gray-500">Qty: {item.quantity}</p>
              </div>
              <p className="text-sm font-semibold text-gray-900">{formatCurrency(item.price * item.quantity)}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Totals */}
      <div className="border-t border-gray-200 pt-4 space-y-1 text-sm">
        <div className="flex justify-between text-gray-600"><span>Subtotal</span><span>{formatCurrency(getSubtotal())}</span></div>
        <div className="flex justify-between text-gray-600"><span>Tax (8%)</span><span>{formatCurrency(getTax())}</span></div>
        <div className="flex justify-between text-gray-600">
          <span>Shipping</span>
          <span className={getShippingCost() === 0 ? 'text-green-600' : ''}>{getShippingCost() === 0 ? 'Free' : formatCurrency(getShippingCost())}</span>
        </div>
        <div className="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-200">
          <span>Total</span><span>{formatCurrency(getTotal())}</span>
        </div>
      </div>

      <div className="flex gap-3">
        <Button variant="secondary" onClick={onBack} className="flex-1 py-3">Back</Button>
        <Button onClick={onContinue} className="flex-1 py-3">Continue to Payment</Button>
      </div>
    </div>
  )
}
