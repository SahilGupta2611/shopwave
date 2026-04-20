import { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { CheckCircle, Package } from 'lucide-react'
import { formatCurrency } from '../utils/formatCurrency'
import Button from '../components/ui/Button'

export default function OrderConfirmationPage() {
  const { orderId } = useParams()
  const [order, setOrder] = useState(null)

  useEffect(() => {
    const stored = sessionStorage.getItem('last-order')
    if (stored) setOrder(JSON.parse(stored))
  }, [])

  const estimatedDelivery = new Date()
  estimatedDelivery.setDate(estimatedDelivery.getDate() + 5)
  const deliveryStr = estimatedDelivery.toLocaleDateString('en-US', {
    weekday: 'long', month: 'long', day: 'numeric',
  })

  return (
    <div className="max-w-lg mx-auto px-4 sm:px-6 py-12">
      {/* Success header */}
      <div className="text-center mb-8">
        <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
        <h1 className="text-2xl font-bold text-gray-900">Order Confirmed!</h1>
        <p className="text-gray-500 mt-1">Thank you for your purchase.</p>
        <p className="text-sm font-mono bg-gray-100 rounded-lg px-4 py-2 mt-3 inline-block text-gray-700">
          {orderId}
        </p>
      </div>

      {order ? (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 space-y-5">
          {/* Items */}
          <div>
            <h2 className="font-semibold text-gray-900 mb-3 flex items-center gap-2">
              <Package className="w-4 h-4" /> Items Ordered
            </h2>
            <div className="space-y-3">
              {order.items.map((item) => (
                <div key={item.productId} className="flex items-center gap-3">
                  <img src={item.image} alt={item.name} className="w-10 h-10 object-cover rounded bg-gray-100 flex-shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900 line-clamp-1">{item.name}</p>
                    <p className="text-xs text-gray-500">Qty: {item.quantity}</p>
                  </div>
                  <p className="text-sm font-semibold">{formatCurrency(item.price * item.quantity)}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Totals */}
          <div className="border-t border-gray-100 pt-4 space-y-1 text-sm">
            <div className="flex justify-between text-gray-600"><span>Subtotal</span><span>{formatCurrency(order.subtotal)}</span></div>
            <div className="flex justify-between text-gray-600"><span>Tax</span><span>{formatCurrency(order.tax)}</span></div>
            <div className="flex justify-between text-gray-600"><span>Shipping</span><span>{order.shippingCost === 0 ? 'Free' : formatCurrency(order.shippingCost)}</span></div>
            <div className="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-200">
              <span>Total</span><span>{formatCurrency(order.total)}</span>
            </div>
          </div>

          {/* Shipping info */}
          <div className="border-t border-gray-100 pt-4">
            <p className="text-sm text-gray-600">
              <span className="font-medium">Shipping to:</span>{' '}
              {order.shipping.firstName} {order.shipping.lastName},{' '}
              {order.shipping.address}, {order.shipping.city}, {order.shipping.state} {order.shipping.zip}
            </p>
            <p className="text-sm text-gray-600 mt-1">
              <span className="font-medium">Confirmation sent to:</span> {order.shipping.email}
            </p>
            <p className="text-sm text-green-600 font-medium mt-1">
              Estimated delivery: {deliveryStr}
            </p>
          </div>

          {/* Card */}
          <div className="border-t border-gray-100 pt-4 text-sm text-gray-500">
            Paid with card ending in <strong>{order.payment.last4}</strong>
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 text-center text-gray-500">
          Order details unavailable (session may have expired).
        </div>
      )}

      <Link to="/" className="block mt-6">
        <Button className="w-full py-3">Continue Shopping</Button>
      </Link>
    </div>
  )
}
