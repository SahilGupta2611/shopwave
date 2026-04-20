import { useState } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import { Star, ShoppingCart, Check, ChevronLeft, Package } from 'lucide-react'
import toast from 'react-hot-toast'
import { getProductBySlug } from '../data/products'
import useCartStore from '../store/useCartStore'
import { formatCurrency } from '../utils/formatCurrency'
import Button from '../components/ui/Button'
import Badge from '../components/ui/Badge'

function StarRating({ rating }) {
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          className={`w-4 h-4 ${
            star <= Math.round(rating) ? 'fill-amber-400 text-amber-400' : 'text-gray-300'
          }`}
        />
      ))}
    </div>
  )
}

export default function ProductDetailPage() {
  const { slug } = useParams()
  const navigate = useNavigate()
  const addItem = useCartStore((s) => s.addItem)
  const [added, setAdded] = useState(false)

  const product = getProductBySlug(slug)

  if (!product) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center">
        <h2 className="text-xl font-semibold text-gray-700">Product not found</h2>
        <Link to="/" className="mt-4 inline-block text-indigo-600 hover:underline">
          Back to shop
        </Link>
      </div>
    )
  }

  const discount = product.originalPrice
    ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100)
    : null

  const handleAddToCart = () => {
    addItem(product)
    toast.success(`${product.name} added to cart!`)
    setAdded(true)
    setTimeout(() => setAdded(false), 1500)
  }

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <button
        onClick={() => navigate(-1)}
        className="flex items-center gap-1 text-sm text-gray-500 hover:text-indigo-600 mb-6 cursor-pointer"
      >
        <ChevronLeft className="w-4 h-4" /> Back
      </button>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
        {/* Image */}
        <div className="relative rounded-xl overflow-hidden bg-gray-100 aspect-square">
          <img
            src={product.images[0]}
            alt={product.name}
            className="w-full h-full object-cover"
          />
          {discount && (
            <Badge className="absolute top-3 right-3 bg-red-500 text-white text-sm px-3 py-1">
              -{discount}% OFF
            </Badge>
          )}
        </div>

        {/* Details */}
        <div className="flex flex-col gap-4">
          <Badge className="w-fit bg-indigo-100 text-indigo-700">{product.category}</Badge>
          <h1 className="text-2xl font-bold text-gray-900">{product.name}</h1>

          <div className="flex items-center gap-2">
            <StarRating rating={product.rating} />
            <span className="text-sm text-gray-500">
              {product.rating} ({product.reviewCount} reviews)
            </span>
          </div>

          <div className="flex items-baseline gap-3">
            <span className="text-3xl font-bold text-gray-900">{formatCurrency(product.price)}</span>
            {product.originalPrice && (
              <span className="text-lg text-gray-400 line-through">{formatCurrency(product.originalPrice)}</span>
            )}
          </div>

          <p className="text-gray-600 leading-relaxed">{product.description}</p>

          <div className="flex items-center gap-2 text-sm text-green-600">
            <Package className="w-4 h-4" />
            {product.stock > 5
              ? `In stock (${product.stock} available)`
              : product.stock > 0
              ? `Only ${product.stock} left!`
              : 'Out of stock'}
          </div>

          <div className="flex gap-3 pt-2">
            <Button
              onClick={handleAddToCart}
              disabled={product.stock === 0}
              className="flex-1 py-3"
            >
              {added ? (
                <><Check className="w-5 h-5" /> Added!</>
              ) : (
                <><ShoppingCart className="w-5 h-5" /> Add to Cart</>
              )}
            </Button>
            <Button
              variant="outline"
              onClick={() => { addItem(product); navigate('/cart') }}
              disabled={product.stock === 0}
              className="flex-1 py-3"
            >
              Buy Now
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
