import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Star, ShoppingCart, Check } from 'lucide-react'
import toast from 'react-hot-toast'
import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'
import Badge from '../ui/Badge'

function StarRating({ rating }) {
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={`w-3.5 h-3.5 ${
            star <= Math.round(rating) ? 'fill-amber-400 text-amber-400' : 'text-gray-300'
          }`}
        />
      ))}
    </div>
  )
}

export default function ProductCard({ product }) {
  const navigate = useNavigate()
  const addItem = useCartStore((s) => s.addItem)
  const [added, setAdded] = useState(false)

  const handleAddToCart = (e) => {
    e.stopPropagation()
    addItem(product)
    toast.success(`${product.name} added to cart!`)
    setAdded(true)
    setTimeout(() => setAdded(false), 1500)
  }

  const discount = product.originalPrice
    ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)
    : null

  return (
    <div
      className="bg-white rounded-xl overflow-hidden border border-gray-200 shadow-sm hover:shadow-md transition-shadow cursor-pointer group"
      onClick={() => navigate(`/product/${product.slug}`)}
    >
      {/* Image */}
      <div className="relative overflow-hidden h-52 bg-gray-100">
        <img
          src={product.images[0]}
          alt={product.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
          onError={(e) => { e.target.src = 'https://via.placeholder.com/600x400?text=Product' }}
        />
        <Badge className="absolute top-2 left-2 bg-indigo-100 text-indigo-700">
          {product.category}
        </Badge>
        {discount && (
          <Badge className="absolute top-2 right-2 bg-red-500 text-white">
            -{discount}%
          </Badge>
        )}
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 text-sm line-clamp-2 leading-snug mb-2">
          {product.name}
        </h3>

        <div className="flex items-center gap-1.5 mb-3">
          <StarRating rating={product.rating} />
          <span className="text-xs text-gray-500">({product.reviewCount})</span>
        </div>

        <div className="flex items-center justify-between">
          <div>
            <span className="text-lg font-bold text-gray-900">{formatCurrency(product.price)}</span>
            {product.originalPrice && (
              <span className="ml-1.5 text-sm text-gray-400 line-through">
                {formatCurrency(product.originalPrice)}
              </span>
            )}
          </div>

          <button
            onClick={handleAddToCart}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-all cursor-pointer ${
              added
                ? 'bg-green-500 text-white'
                : 'bg-indigo-600 text-white hover:bg-indigo-700'
            }`}
          >
            {added ? <Check className="w-4 h-4" /> : <ShoppingCart className="w-4 h-4" />}
            {added ? 'Added!' : 'Add'}
          </button>
        </div>
      </div>
    </div>
  )
}
