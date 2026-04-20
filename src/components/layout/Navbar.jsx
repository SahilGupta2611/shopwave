import { Link, useNavigate } from 'react-router-dom'
import { ShoppingCart, Store } from 'lucide-react'
import useCartStore from '../../store/useCartStore'

export default function Navbar() {
  const navigate = useNavigate()
  const items = useCartStore((s) => s.items)
  const itemCount = items.reduce((sum, i) => sum + i.quantity, 0)

  return (
    <nav className="sticky top-0 z-50 bg-white border-b border-gray-200 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 text-indigo-600 font-bold text-xl">
            <Store className="w-6 h-6" />
            ShopWave
          </Link>

          {/* Nav links */}
          <div className="hidden sm:flex items-center gap-6 text-sm text-gray-600">
            <Link to="/" className="hover:text-indigo-600 transition-colors">Home</Link>
            <Link to="/cart" className="hover:text-indigo-600 transition-colors">Cart</Link>
          </div>

          {/* Cart button */}
          <button
            onClick={() => navigate('/cart')}
            className="relative p-2 text-gray-600 hover:text-indigo-600 transition-colors cursor-pointer"
            aria-label="Shopping cart"
          >
            <ShoppingCart className="w-6 h-6" />
            {itemCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-indigo-600 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center animate-bounce">
                {itemCount > 99 ? '99+' : itemCount}
              </span>
            )}
          </button>
        </div>
      </div>
    </nav>
  )
}
