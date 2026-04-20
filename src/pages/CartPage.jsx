import { Link } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'
import useCartStore from '../store/useCartStore'
import CartItem from '../components/cart/CartItem'
import CartSummary from '../components/cart/CartSummary'
import EmptyState from '../components/ui/EmptyState'
import Button from '../components/ui/Button'

export default function CartPage() {
  const items = useCartStore((s) => s.items)

  if (items.length === 0) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20">
        <EmptyState
          icon={<ShoppingCart className="w-16 h-16" />}
          title="Your cart is empty"
          description="Add some products to get started"
          action={
            <Link to="/">
              <Button>Continue Shopping</Button>
            </Link>
          }
        />
      </div>
    )
  }

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Shopping Cart</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Cart Items */}
        <div className="lg:col-span-2 bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
          {items.map((item) => (
            <CartItem key={item.productId} item={item} />
          ))}
        </div>

        {/* Summary */}
        <div>
          <CartSummary />
          <Link to="/" className="block mt-3">
            <Button variant="ghost" className="w-full">
              Continue Shopping
            </Button>
          </Link>
        </div>
      </div>
    </div>
  )
}
