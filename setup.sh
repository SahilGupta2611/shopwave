#!/usr/bin/env bash
# ============================================================
#  ShopWave — E-Commerce React App Setup Script
#  Usage: bash setup.sh [app-name]
#  Example: bash setup.sh my-store
# ============================================================

set -e  # Exit immediately if any command fails

APP_NAME="${1:-shopwave}"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log()  { echo -e "${BLUE}[setup]${NC} $1"; }
ok()   { echo -e "${GREEN}[done]${NC}  $1"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $1"; }

echo ""
echo "  ███████╗██╗  ██╗ ██████╗ ██████╗ ██╗    ██╗ █████╗ ██╗   ██╗███████╗"
echo "  ██╔════╝██║  ██║██╔═══██╗██╔══██╗██║    ██║██╔══██╗██║   ██║██╔════╝"
echo "  ███████╗███████║██║   ██║██████╔╝██║ █╗ ██║███████║██║   ██║█████╗  "
echo "  ╚════██║██╔══██║██║   ██║██╔═══╝ ██║███╗██║██╔══██║╚██╗ ██╔╝██╔══╝  "
echo "  ███████║██║  ██║╚██████╔╝██║     ╚███╔███╔╝██║  ██║ ╚████╔╝ ███████╗"
echo "  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝      ╚══╝╚══╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝"
echo ""
echo "  Setting up: ${APP_NAME}"
echo ""

# ── Prerequisites check ──────────────────────────────────────
log "Checking prerequisites..."

if ! command -v node &>/dev/null; then
  echo "Error: Node.js is not installed. Install from https://nodejs.org/" && exit 1
fi
if ! command -v npm &>/dev/null; then
  echo "Error: npm is not installed." && exit 1
fi

NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VER" -lt 18 ]; then
  echo "Error: Node.js 18+ required. Current: $(node -v)" && exit 1
fi
ok "Node $(node -v) / npm $(npm -v)"

# ── Scaffold Vite project ────────────────────────────────────
log "Creating Vite + React project..."
npm create vite@latest "$APP_NAME" -- --template react --yes 2>/dev/null || \
  npm create vite@latest "$APP_NAME" -- --template react
cd "$APP_NAME"
ok "Vite project created"

# ── Install dependencies ─────────────────────────────────────
log "Installing dependencies..."
npm install react-router-dom zustand react-hook-form react-hot-toast lucide-react nanoid
npm install -D @tailwindcss/vite
ok "Dependencies installed"

# ── Directory structure ──────────────────────────────────────
log "Creating directory structure..."
mkdir -p src/data src/store src/utils src/hooks \
         src/components/layout src/components/ui \
         src/components/product src/components/cart \
         src/components/checkout src/pages
ok "Directories created"

# ── vite.config.js ───────────────────────────────────────────
log "Configuring Vite..."
cat > vite.config.js << 'VITE_EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
VITE_EOF

# ── index.css ────────────────────────────────────────────────
cat > src/index.css << 'CSS_EOF'
@import "tailwindcss";

@theme {
  --animate-fade-in: fadeIn 0.3s ease-in-out;
  --animate-slide-up: slideUp 0.3s ease-out;

  @keyframes fadeIn {
    0% { opacity: 0; }
    100% { opacity: 1; }
  }

  @keyframes slideUp {
    0% { transform: translateY(20px); opacity: 0; }
    100% { transform: translateY(0); opacity: 1; }
  }
}

* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
}
CSS_EOF
ok "Tailwind CSS v4 configured"

# ── main.jsx ─────────────────────────────────────────────────
cat > src/main.jsx << 'MAIN_EOF'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { Toaster } from 'react-hot-toast'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <App />
      <Toaster position="top-right" toastOptions={{ duration: 3000 }} />
    </BrowserRouter>
  </StrictMode>,
)
MAIN_EOF

# ── App.jsx ──────────────────────────────────────────────────
cat > src/App.jsx << 'APP_EOF'
import { Routes, Route } from 'react-router-dom'
import Layout from './components/layout/Layout'
import HomePage from './pages/HomePage'
import ProductDetailPage from './pages/ProductDetailPage'
import CartPage from './pages/CartPage'
import CheckoutPage from './pages/CheckoutPage'
import OrderConfirmationPage from './pages/OrderConfirmationPage'

function NotFound() {
  return (
    <div className="max-w-7xl mx-auto px-4 py-20 text-center">
      <h2 className="text-2xl font-bold text-gray-700">404 — Page Not Found</h2>
    </div>
  )
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Layout />}>
        <Route index element={<HomePage />} />
        <Route path="product/:slug" element={<ProductDetailPage />} />
        <Route path="cart" element={<CartPage />} />
        <Route path="checkout" element={<CheckoutPage />} />
        <Route path="order-confirmation/:orderId" element={<OrderConfirmationPage />} />
        <Route path="*" element={<NotFound />} />
      </Route>
    </Routes>
  )
}
APP_EOF

# ── Data ─────────────────────────────────────────────────────
log "Writing data files..."
cat > src/data/products.js << 'DATA_EOF'
export const products = [
  // Electronics
  { id: 'prod_001', name: 'Wireless Noise-Cancelling Headphones', slug: 'wireless-noise-cancelling-headphones', description: 'Premium over-ear headphones with active noise cancellation, 30-hour battery life, and crystal-clear sound. Perfect for commuting, work, or relaxing at home.', price: 89.99, originalPrice: 129.99, category: 'Electronics', rating: 4.5, reviewCount: 128, stock: 12, images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80'], tags: ['wireless', 'audio', 'sale'], featured: true },
  { id: 'prod_002', name: 'Smart Watch Pro', slug: 'smart-watch-pro', description: 'Feature-packed smartwatch with health tracking, GPS, sleep monitoring, and 7-day battery. Compatible with iOS and Android.', price: 199.99, originalPrice: null, category: 'Electronics', rating: 4.7, reviewCount: 256, stock: 8, images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80'], tags: ['wearable', 'health', 'bestseller'], featured: true },
  { id: 'prod_003', name: 'Portable Bluetooth Speaker', slug: 'portable-bluetooth-speaker', description: 'Waterproof outdoor speaker with 360° surround sound, 20-hour playtime, and rugged design. Take your music anywhere.', price: 49.99, originalPrice: 69.99, category: 'Electronics', rating: 4.3, reviewCount: 89, stock: 20, images: ['https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&q=80'], tags: ['audio', 'outdoor', 'sale'], featured: false },
  { id: 'prod_004', name: 'Mechanical Gaming Keyboard', slug: 'mechanical-gaming-keyboard', description: 'RGB backlit mechanical keyboard with tactile switches, anti-ghosting, and aluminum frame. Engineered for competitive gaming.', price: 119.99, originalPrice: null, category: 'Electronics', rating: 4.6, reviewCount: 174, stock: 15, images: ['https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&q=80'], tags: ['gaming', 'keyboard', 'rgb'], featured: false },
  // Clothing
  { id: 'prod_005', name: 'Classic Denim Jacket', slug: 'classic-denim-jacket', description: 'Timeless denim jacket with a relaxed fit, button-front closure, and chest pockets. A wardrobe essential for every season.', price: 64.99, originalPrice: 89.99, category: 'Clothing', rating: 4.4, reviewCount: 62, stock: 25, images: ['https://images.unsplash.com/photo-1544441893-675973e31985?w=600&q=80'], tags: ['denim', 'jacket', 'sale'], featured: true },
  { id: 'prod_006', name: 'Premium Slim Fit Chinos', slug: 'premium-slim-fit-chinos', description: 'Versatile slim-fit chinos crafted from stretch cotton blend. Comfortable for the office or weekend outings.', price: 44.99, originalPrice: null, category: 'Clothing', rating: 4.2, reviewCount: 45, stock: 30, images: ['https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=600&q=80'], tags: ['pants', 'casual', 'office'], featured: false },
  { id: 'prod_007', name: 'Merino Wool Sweater', slug: 'merino-wool-sweater', description: 'Luxuriously soft merino wool sweater with a classic crew neck. Natural temperature regulation keeps you comfortable year-round.', price: 79.99, originalPrice: 109.99, category: 'Clothing', rating: 4.8, reviewCount: 103, stock: 18, images: ['https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80'], tags: ['sweater', 'wool', 'sale'], featured: false },
  { id: 'prod_008', name: 'Running Sneakers', slug: 'running-sneakers', description: 'Lightweight performance sneakers with responsive cushioning, breathable mesh upper, and durable rubber outsole. Built for speed and comfort.', price: 94.99, originalPrice: null, category: 'Clothing', rating: 4.5, reviewCount: 198, stock: 22, images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80'], tags: ['shoes', 'running', 'bestseller'], featured: true },
  // Home & Garden
  { id: 'prod_009', name: 'Ceramic Pour-Over Coffee Set', slug: 'ceramic-pour-over-coffee-set', description: 'Artisan ceramic pour-over dripper with matching carafe and filters. Brew café-quality coffee at home with precise control.', price: 39.99, originalPrice: 54.99, category: 'Home & Garden', rating: 4.6, reviewCount: 77, stock: 35, images: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&q=80'], tags: ['coffee', 'kitchen', 'sale'], featured: false },
  { id: 'prod_010', name: 'Indoor Succulent Collection', slug: 'indoor-succulent-collection', description: 'Set of 6 hand-picked succulents in ceramic pots. Low-maintenance and perfect for brightening up any indoor space.', price: 29.99, originalPrice: null, category: 'Home & Garden', rating: 4.3, reviewCount: 54, stock: 40, images: ['https://images.unsplash.com/photo-1459156212016-c812468e2115?w=600&q=80'], tags: ['plants', 'decor', 'garden'], featured: false },
  { id: 'prod_011', name: 'Scented Soy Candle Set', slug: 'scented-soy-candle-set', description: 'Set of 3 hand-poured soy wax candles in amber jars. Relaxing aromas of lavender, vanilla, and sandalwood. 45-hour burn time each.', price: 34.99, originalPrice: 44.99, category: 'Home & Garden', rating: 4.7, reviewCount: 92, stock: 28, images: ['https://images.unsplash.com/photo-1602928308408-8e5b8944e9f4?w=600&q=80'], tags: ['candles', 'home', 'sale'], featured: true },
  { id: 'prod_012', name: 'Bamboo Cutting Board Set', slug: 'bamboo-cutting-board-set', description: 'Set of 3 premium bamboo cutting boards in graduated sizes. Naturally antimicrobial, eco-friendly, and gentle on knife edges.', price: 27.99, originalPrice: null, category: 'Home & Garden', rating: 4.4, reviewCount: 66, stock: 50, images: ['https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80'], tags: ['kitchen', 'eco', 'cooking'], featured: false },
  // Sports
  { id: 'prod_013', name: 'Yoga Mat Premium', slug: 'yoga-mat-premium', description: 'Extra-thick non-slip yoga mat with alignment lines, carrying strap, and moisture-wicking surface. Ideal for yoga, pilates, and stretching.', price: 54.99, originalPrice: 74.99, category: 'Sports', rating: 4.6, reviewCount: 143, stock: 33, images: ['https://images.unsplash.com/photo-1601925228102-3bed700d9aea?w=600&q=80'], tags: ['yoga', 'fitness', 'sale'], featured: true },
  { id: 'prod_014', name: 'Adjustable Dumbbell Set', slug: 'adjustable-dumbbell-set', description: 'Space-saving adjustable dumbbells that replace 15 sets of weights. Quick-adjust dial from 5 to 52.5 lbs. Perfect for home gyms.', price: 299.99, originalPrice: 349.99, category: 'Sports', rating: 4.8, reviewCount: 211, stock: 6, images: ['https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&q=80'], tags: ['weights', 'gym', 'sale'], featured: false },
  { id: 'prod_015', name: 'Insulated Water Bottle', slug: 'insulated-water-bottle', description: 'Double-wall vacuum insulated stainless steel bottle. Keeps drinks cold 24 hours and hot 12 hours. Leak-proof lid, BPA-free.', price: 22.99, originalPrice: null, category: 'Sports', rating: 4.5, reviewCount: 317, stock: 60, images: ['https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600&q=80'], tags: ['hydration', 'outdoor', 'bestseller'], featured: false },
  { id: 'prod_016', name: 'Resistance Bands Set', slug: 'resistance-bands-set', description: 'Set of 5 resistance bands with varying tension levels. Includes door anchor, ankle straps, and handles. Great for full-body workouts.', price: 19.99, originalPrice: 29.99, category: 'Sports', rating: 4.3, reviewCount: 88, stock: 45, images: ['https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=600&q=80'], tags: ['fitness', 'bands', 'sale'], featured: false },
]

export const categories = ['All', 'Electronics', 'Clothing', 'Home & Garden', 'Sports']
export const getProductBySlug = (slug) => products.find((p) => p.slug === slug)
DATA_EOF

# ── Utils ─────────────────────────────────────────────────────
cat > src/utils/formatCurrency.js << 'EOF'
export const formatCurrency = (amount) =>
  new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount)
EOF

cat > src/utils/validatePayment.js << 'EOF'
export const mockProcessPayment = async (cardNumber) => {
  const digits = cardNumber.replace(/\s/g, '')
  await new Promise((resolve) => setTimeout(resolve, 1500))
  if (digits.startsWith('0000')) {
    throw new Error('Your card was declined. Please try a different card.')
  }
  return { success: true }
}
EOF

# ── Store ─────────────────────────────────────────────────────
log "Writing store..."
cat > src/store/useCartStore.js << 'EOF'
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

const useCartStore = create(
  persist(
    (set, get) => ({
      items: [],
      addItem: (product) => {
        const items = get().items
        const existing = items.find((i) => i.productId === product.id)
        if (existing) {
          set({ items: items.map((i) => i.productId === product.id ? { ...i, quantity: Math.min(i.quantity + 1, product.stock) } : i) })
        } else {
          set({ items: [...items, { productId: product.id, name: product.name, price: product.price, image: product.images[0], quantity: 1, stock: product.stock }] })
        }
      },
      removeItem: (productId) => set({ items: get().items.filter((i) => i.productId !== productId) }),
      updateQuantity: (productId, qty) => {
        const item = get().items.find((i) => i.productId === productId)
        if (!item) return
        set({ items: get().items.map((i) => i.productId === productId ? { ...i, quantity: Math.max(1, Math.min(qty, item.stock)) } : i) })
      },
      clearCart: () => set({ items: [] }),
      getItemCount: () => get().items.reduce((sum, i) => sum + i.quantity, 0),
      getSubtotal: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
      getTax: () => get().getSubtotal() * 0.08,
      getShippingCost: () => (get().getSubtotal() >= 50 ? 0 : 9.99),
      getTotal: () => get().getSubtotal() + get().getTax() + get().getShippingCost(),
    }),
    { name: 'ecommerce-cart' }
  )
)

export default useCartStore
EOF

# ── Hooks ─────────────────────────────────────────────────────
cat > src/hooks/useProducts.js << 'EOF'
import { useState, useMemo, useEffect } from 'react'
import { products } from '../data/products'

export default function useProducts() {
  const [search, setSearch] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [category, setCategory] = useState('All')
  const [sort, setSort] = useState('featured')

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 300)
    return () => clearTimeout(timer)
  }, [search])

  const filtered = useMemo(() => {
    let result = [...products]
    if (category !== 'All') result = result.filter((p) => p.category === category)
    if (debouncedSearch.trim()) {
      const q = debouncedSearch.toLowerCase()
      result = result.filter((p) => p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q) || p.tags.some((t) => t.toLowerCase().includes(q)))
    }
    switch (sort) {
      case 'price-asc': result.sort((a, b) => a.price - b.price); break
      case 'price-desc': result.sort((a, b) => b.price - a.price); break
      case 'rating': result.sort((a, b) => b.rating - a.rating); break
      default: result.sort((a, b) => (b.featured ? 1 : 0) - (a.featured ? 1 : 0))
    }
    return result
  }, [debouncedSearch, category, sort])

  return { filtered, search, setSearch, category, setCategory, sort, setSort }
}
EOF

ok "Data, store, and hooks created"

# ── UI Components ─────────────────────────────────────────────
log "Writing UI components..."

cat > src/components/ui/Button.jsx << 'EOF'
const variants = {
  primary: 'bg-indigo-600 text-white hover:bg-indigo-700 disabled:bg-indigo-300',
  secondary: 'bg-gray-100 text-gray-800 hover:bg-gray-200 disabled:opacity-50',
  ghost: 'bg-transparent text-gray-600 hover:bg-gray-100 disabled:opacity-50',
  danger: 'bg-red-500 text-white hover:bg-red-600 disabled:opacity-50',
  outline: 'border border-indigo-600 text-indigo-600 hover:bg-indigo-50 disabled:opacity-50',
}
export default function Button({ variant = 'primary', className = '', children, ...props }) {
  return (
    <button className={`inline-flex items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-medium transition-colors cursor-pointer disabled:cursor-not-allowed ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  )
}
EOF

cat > src/components/ui/Badge.jsx << 'EOF'
export default function Badge({ children, className = '' }) {
  return <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ${className}`}>{children}</span>
}
EOF

cat > src/components/ui/Spinner.jsx << 'EOF'
export default function Spinner({ size = 'md' }) {
  const sizes = { sm: 'w-4 h-4', md: 'w-6 h-6', lg: 'w-10 h-10' }
  return <div className={`${sizes[size]} animate-spin rounded-full border-2 border-gray-300 border-t-indigo-600`} />
}
EOF

cat > src/components/ui/EmptyState.jsx << 'EOF'
export default function EmptyState({ icon, title, description, action }) {
  return (
    <div className="flex flex-col items-center justify-center py-20 text-center">
      {icon && <div className="mb-4 text-gray-300">{icon}</div>}
      <h3 className="text-lg font-semibold text-gray-700">{title}</h3>
      {description && <p className="mt-1 text-sm text-gray-500">{description}</p>}
      {action && <div className="mt-6">{action}</div>}
    </div>
  )
}
EOF

# ── Layout Components ─────────────────────────────────────────
cat > src/components/layout/Navbar.jsx << 'EOF'
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
          <Link to="/" className="flex items-center gap-2 text-indigo-600 font-bold text-xl">
            <Store className="w-6 h-6" /> ShopWave
          </Link>
          <div className="hidden sm:flex items-center gap-6 text-sm text-gray-600">
            <Link to="/" className="hover:text-indigo-600 transition-colors">Home</Link>
            <Link to="/cart" className="hover:text-indigo-600 transition-colors">Cart</Link>
          </div>
          <button onClick={() => navigate('/cart')} className="relative p-2 text-gray-600 hover:text-indigo-600 transition-colors cursor-pointer" aria-label="Shopping cart">
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
EOF

cat > src/components/layout/Footer.jsx << 'EOF'
import { Store } from 'lucide-react'
export default function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-gray-50 mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2 text-indigo-600 font-bold"><Store className="w-5 h-5" /> ShopWave</div>
          <p className="text-sm text-gray-500">© 2026 ShopWave. All rights reserved.</p>
          <div className="flex gap-4 text-sm text-gray-500">
            <span className="cursor-pointer hover:text-indigo-600">Privacy</span>
            <span className="cursor-pointer hover:text-indigo-600">Terms</span>
            <span className="cursor-pointer hover:text-indigo-600">Contact</span>
          </div>
        </div>
      </div>
    </footer>
  )
}
EOF

cat > src/components/layout/Layout.jsx << 'EOF'
import { Outlet } from 'react-router-dom'
import Navbar from './Navbar'
import Footer from './Footer'
export default function Layout() {
  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Navbar />
      <main className="flex-1"><Outlet /></main>
      <Footer />
    </div>
  )
}
EOF

# ── Product Components ────────────────────────────────────────
cat > src/components/product/ProductSearch.jsx << 'EOF'
import { Search, X } from 'lucide-react'
export default function ProductSearch({ value, onChange }) {
  return (
    <div className="relative max-w-md w-full">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
      <input type="text" placeholder="Search products..." value={value} onChange={(e) => onChange(e.target.value)} className="w-full pl-9 pr-9 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent bg-white" />
      {value && <button onClick={() => onChange('')} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"><X className="w-4 h-4" /></button>}
    </div>
  )
}
EOF

cat > src/components/product/ProductFilters.jsx << 'EOF'
import { categories } from '../../data/products'
const sortOptions = [
  { value: 'featured', label: 'Featured' },
  { value: 'price-asc', label: 'Price: Low to High' },
  { value: 'price-desc', label: 'Price: High to Low' },
  { value: 'rating', label: 'Highest Rated' },
]
export default function ProductFilters({ category, onCategory, sort, onSort }) {
  return (
    <div className="flex flex-col sm:flex-row gap-3 items-start sm:items-center">
      <div className="flex flex-wrap gap-2">
        {categories.map((cat) => (
          <button key={cat} onClick={() => onCategory(cat)} className={`px-3 py-1.5 rounded-full text-sm font-medium transition-colors cursor-pointer ${category === cat ? 'bg-indigo-600 text-white' : 'bg-white text-gray-600 border border-gray-300 hover:border-indigo-400 hover:text-indigo-600'}`}>{cat}</button>
        ))}
      </div>
      <select value={sort} onChange={(e) => onSort(e.target.value)} className="ml-auto px-3 py-2 border border-gray-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 focus:ring-indigo-500 cursor-pointer">
        {sortOptions.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
    </div>
  )
}
EOF

cat > src/components/product/ProductCard.jsx << 'EOF'
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
      {[1,2,3,4,5].map((star) => (
        <Star key={star} className={`w-3.5 h-3.5 ${star <= Math.round(rating) ? 'fill-amber-400 text-amber-400' : 'text-gray-300'}`} />
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

  const discount = product.originalPrice ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100) : null

  return (
    <div className="bg-white rounded-xl overflow-hidden border border-gray-200 shadow-sm hover:shadow-md transition-shadow cursor-pointer group" onClick={() => navigate(`/product/${product.slug}`)}>
      <div className="relative overflow-hidden h-52 bg-gray-100">
        <img src={product.images[0]} alt={product.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300" onError={(e) => { e.target.src = 'https://via.placeholder.com/600x400?text=Product' }} />
        <Badge className="absolute top-2 left-2 bg-indigo-100 text-indigo-700">{product.category}</Badge>
        {discount && <Badge className="absolute top-2 right-2 bg-red-500 text-white">-{discount}%</Badge>}
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-gray-900 text-sm line-clamp-2 leading-snug mb-2">{product.name}</h3>
        <div className="flex items-center gap-1.5 mb-3">
          <StarRating rating={product.rating} />
          <span className="text-xs text-gray-500">({product.reviewCount})</span>
        </div>
        <div className="flex items-center justify-between">
          <div>
            <span className="text-lg font-bold text-gray-900">{formatCurrency(product.price)}</span>
            {product.originalPrice && <span className="ml-1.5 text-sm text-gray-400 line-through">{formatCurrency(product.originalPrice)}</span>}
          </div>
          <button onClick={handleAddToCart} className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium transition-all cursor-pointer ${added ? 'bg-green-500 text-white' : 'bg-indigo-600 text-white hover:bg-indigo-700'}`}>
            {added ? <><Check className="w-4 h-4" /> Added!</> : <><ShoppingCart className="w-4 h-4" /> Add</>}
          </button>
        </div>
      </div>
    </div>
  )
}
EOF

cat > src/components/product/ProductGrid.jsx << 'EOF'
import ProductCard from './ProductCard'
export default function ProductGrid({ products }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
      {products.map((product) => <ProductCard key={product.id} product={product} />)}
    </div>
  )
}
EOF

# ── Cart Components ───────────────────────────────────────────
log "Writing cart components..."

cat > src/components/cart/CartItem.jsx << 'EOF'
import { Trash2, Minus, Plus } from 'lucide-react'
import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'

export default function CartItem({ item }) {
  const { removeItem, updateQuantity } = useCartStore()
  return (
    <div className="flex gap-4 py-4 border-b border-gray-100 last:border-0">
      <img src={item.image} alt={item.name} className="w-20 h-20 object-cover rounded-lg flex-shrink-0 bg-gray-100" />
      <div className="flex-1 min-w-0">
        <h3 className="font-medium text-gray-900 text-sm leading-snug line-clamp-2">{item.name}</h3>
        <p className="text-indigo-600 font-semibold mt-1">{formatCurrency(item.price)}</p>
        <div className="flex items-center justify-between mt-3">
          <div className="flex items-center border border-gray-300 rounded-lg overflow-hidden">
            <button onClick={() => updateQuantity(item.productId, item.quantity - 1)} disabled={item.quantity <= 1} className="px-2 py-1 text-gray-600 hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer transition-colors"><Minus className="w-3.5 h-3.5" /></button>
            <span className="px-3 py-1 text-sm font-medium text-gray-900 min-w-[2rem] text-center">{item.quantity}</span>
            <button onClick={() => updateQuantity(item.productId, item.quantity + 1)} disabled={item.quantity >= item.stock} className="px-2 py-1 text-gray-600 hover:bg-gray-100 disabled:opacity-30 disabled:cursor-not-allowed cursor-pointer transition-colors"><Plus className="w-3.5 h-3.5" /></button>
          </div>
          <div className="flex items-center gap-3">
            <span className="text-sm font-semibold text-gray-900">{formatCurrency(item.price * item.quantity)}</span>
            <button onClick={() => removeItem(item.productId)} className="text-red-400 hover:text-red-600 transition-colors cursor-pointer"><Trash2 className="w-4 h-4" /></button>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

cat > src/components/cart/CartSummary.jsx << 'EOF'
import { useNavigate } from 'react-router-dom'
import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'
import Button from '../ui/Button'

export default function CartSummary({ showCheckoutButton = true }) {
  const navigate = useNavigate()
  const { getSubtotal, getTax, getShippingCost, getTotal } = useCartStore()
  const subtotal = getSubtotal(), tax = getTax(), shipping = getShippingCost(), total = getTotal()
  return (
    <div className="bg-gray-50 rounded-xl p-6 border border-gray-200">
      <h2 className="font-semibold text-gray-900 text-lg mb-4">Order Summary</h2>
      <div className="space-y-2 text-sm">
        <div className="flex justify-between text-gray-600"><span>Subtotal</span><span>{formatCurrency(subtotal)}</span></div>
        <div className="flex justify-between text-gray-600"><span>Tax (8%)</span><span>{formatCurrency(tax)}</span></div>
        <div className="flex justify-between text-gray-600"><span>Shipping</span><span className={shipping === 0 ? 'text-green-600 font-medium' : ''}>{shipping === 0 ? 'Free' : formatCurrency(shipping)}</span></div>
        {shipping > 0 && <p className="text-xs text-gray-400">Free shipping on orders over $50</p>}
        <div className="border-t border-gray-300 pt-2 mt-2 flex justify-between font-bold text-gray-900 text-base"><span>Total</span><span>{formatCurrency(total)}</span></div>
      </div>
      {showCheckoutButton && <Button onClick={() => navigate('/checkout')} className="w-full mt-5 py-3">Proceed to Checkout</Button>}
    </div>
  )
}
EOF

# ── Checkout Components ───────────────────────────────────────
log "Writing checkout components..."

cat > src/components/checkout/StepIndicator.jsx << 'EOF'
import { Check } from 'lucide-react'
const steps = ['Shipping', 'Review', 'Payment']
export default function StepIndicator({ currentStep }) {
  return (
    <div className="flex items-center justify-center mb-8">
      {steps.map((label, idx) => {
        const step = idx + 1, done = step < currentStep, active = step === currentStep
        return (
          <div key={step} className="flex items-center">
            <div className="flex flex-col items-center">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold transition-colors ${done ? 'bg-green-500 text-white' : active ? 'bg-indigo-600 text-white' : 'bg-gray-200 text-gray-500'}`}>
                {done ? <Check className="w-4 h-4" /> : step}
              </div>
              <span className={`mt-1 text-xs font-medium ${active ? 'text-indigo-600' : done ? 'text-green-600' : 'text-gray-400'}`}>{label}</span>
            </div>
            {idx < steps.length - 1 && <div className={`w-16 sm:w-24 h-0.5 mx-2 mb-5 transition-colors ${step < currentStep ? 'bg-green-400' : 'bg-gray-200'}`} />}
          </div>
        )
      })}
    </div>
  )
}
EOF

cat > src/components/checkout/ShippingForm.jsx << 'EOF'
import { useForm } from 'react-hook-form'
import Button from '../ui/Button'

function Field({ label, error, children }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      {children}
      {error && <p className="mt-1 text-xs text-red-500">{error}</p>}
    </div>
  )
}
const ic = 'w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent'

export default function ShippingForm({ onSubmit, defaultValues }) {
  const { register, handleSubmit, formState: { errors } } = useForm({ defaultValues })
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Field label="First Name" error={errors.firstName?.message}>
          <input {...register('firstName', { required: 'Required', minLength: { value: 2, message: 'Min 2 chars' } })} className={`${ic} ${errors.firstName ? 'border-red-400' : 'border-gray-300'}`} placeholder="Jane" />
        </Field>
        <Field label="Last Name" error={errors.lastName?.message}>
          <input {...register('lastName', { required: 'Required', minLength: { value: 2, message: 'Min 2 chars' } })} className={`${ic} ${errors.lastName ? 'border-red-400' : 'border-gray-300'}`} placeholder="Doe" />
        </Field>
      </div>
      <Field label="Email" error={errors.email?.message}>
        <input {...register('email', { required: 'Required', pattern: { value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email' } })} type="email" className={`${ic} ${errors.email ? 'border-red-400' : 'border-gray-300'}`} placeholder="jane@example.com" />
      </Field>
      <Field label="Street Address" error={errors.address?.message}>
        <input {...register('address', { required: 'Required' })} className={`${ic} ${errors.address ? 'border-red-400' : 'border-gray-300'}`} placeholder="123 Main St" />
      </Field>
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
        <Field label="City" error={errors.city?.message}>
          <input {...register('city', { required: 'Required' })} className={`${ic} ${errors.city ? 'border-red-400' : 'border-gray-300'}`} placeholder="Springfield" />
        </Field>
        <Field label="State" error={errors.state?.message}>
          <input {...register('state', { required: 'Required', pattern: { value: /^[A-Z]{2}$/, message: '2-letter code' } })} className={`${ic} ${errors.state ? 'border-red-400' : 'border-gray-300'}`} placeholder="IL" maxLength={2} style={{ textTransform: 'uppercase' }} />
        </Field>
        <Field label="ZIP Code" error={errors.zip?.message}>
          <input {...register('zip', { required: 'Required', pattern: { value: /^\d{5}$/, message: '5-digit ZIP' } })} className={`${ic} ${errors.zip ? 'border-red-400' : 'border-gray-300'}`} placeholder="62701" maxLength={5} />
        </Field>
      </div>
      <Button type="submit" className="w-full py-3 mt-2">Continue to Review</Button>
    </form>
  )
}
EOF

cat > src/components/checkout/OrderReview.jsx << 'EOF'
import useCartStore from '../../store/useCartStore'
import { formatCurrency } from '../../utils/formatCurrency'
import Button from '../ui/Button'

export default function OrderReview({ shipping, onBack, onContinue }) {
  const items = useCartStore((s) => s.items)
  const { getSubtotal, getTax, getShippingCost, getTotal } = useCartStore()
  return (
    <div className="space-y-6">
      <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
        <h3 className="font-semibold text-gray-900 mb-2">Shipping To</h3>
        <p className="text-sm text-gray-600">{shipping.firstName} {shipping.lastName}<br />{shipping.address}<br />{shipping.city}, {shipping.state} {shipping.zip}<br />{shipping.email}</p>
      </div>
      <div>
        <h3 className="font-semibold text-gray-900 mb-3">Order Items</h3>
        <div className="space-y-3">
          {items.map((item) => (
            <div key={item.productId} className="flex items-center gap-3">
              <img src={item.image} alt={item.name} className="w-12 h-12 object-cover rounded-lg bg-gray-100 flex-shrink-0" />
              <div className="flex-1 min-w-0"><p className="text-sm font-medium text-gray-900 line-clamp-1">{item.name}</p><p className="text-xs text-gray-500">Qty: {item.quantity}</p></div>
              <p className="text-sm font-semibold text-gray-900">{formatCurrency(item.price * item.quantity)}</p>
            </div>
          ))}
        </div>
      </div>
      <div className="border-t border-gray-200 pt-4 space-y-1 text-sm">
        <div className="flex justify-between text-gray-600"><span>Subtotal</span><span>{formatCurrency(getSubtotal())}</span></div>
        <div className="flex justify-between text-gray-600"><span>Tax (8%)</span><span>{formatCurrency(getTax())}</span></div>
        <div className="flex justify-between text-gray-600"><span>Shipping</span><span className={getShippingCost() === 0 ? 'text-green-600' : ''}>{getShippingCost() === 0 ? 'Free' : formatCurrency(getShippingCost())}</span></div>
        <div className="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-200"><span>Total</span><span>{formatCurrency(getTotal())}</span></div>
      </div>
      <div className="flex gap-3">
        <Button variant="secondary" onClick={onBack} className="flex-1 py-3">Back</Button>
        <Button onClick={onContinue} className="flex-1 py-3">Continue to Payment</Button>
      </div>
    </div>
  )
}
EOF

cat > src/components/checkout/PaymentForm.jsx << 'EOF'
import { useForm } from 'react-hook-form'
import { CreditCard, Lock } from 'lucide-react'
import Button from '../ui/Button'
import Spinner from '../ui/Spinner'

function Field({ label, error, children }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      {children}
      {error && <p className="mt-1 text-xs text-red-500">{error}</p>}
    </div>
  )
}
const ic = 'w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent'

const fmt = (v) => v.replace(/\D/g,'').slice(0,16).replace(/(\d{4})(?=\d)/g,'$1 ')
const fmtExp = (v) => { const d = v.replace(/\D/g,'').slice(0,4); return d.length >= 3 ? `${d.slice(0,2)}/${d.slice(2)}` : d }

export default function PaymentForm({ onSubmit, onBack, isProcessing }) {
  const { register, handleSubmit, setValue, formState: { errors } } = useForm()
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="flex items-center gap-2 text-sm text-gray-500 bg-green-50 border border-green-200 rounded-lg px-3 py-2 mb-2">
        <Lock className="w-4 h-4 text-green-600" /> Secure mock payment — no real charges
      </div>
      <Field label="Name on Card" error={errors.cardName?.message}>
        <input {...register('cardName', { required: 'Required' })} className={`${ic} ${errors.cardName ? 'border-red-400' : 'border-gray-300'}`} placeholder="Jane Doe" />
      </Field>
      <Field label="Card Number" error={errors.cardNumber?.message}>
        <div className="relative">
          <input {...register('cardNumber', { required: 'Required', validate: (v) => v.replace(/\s/g,'').length === 16 || 'Must be 16 digits' })} onChange={(e) => setValue('cardNumber', fmt(e.target.value), { shouldValidate: true })} className={`${ic} ${errors.cardNumber ? 'border-red-400' : 'border-gray-300'} pr-10`} placeholder="1234 5678 9012 3456" maxLength={19} />
          <CreditCard className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        </div>
      </Field>
      <div className="grid grid-cols-2 gap-4">
        <Field label="Expiry (MM/YY)" error={errors.expiry?.message}>
          <input {...register('expiry', { required: 'Required', pattern: { value: /^(0[1-9]|1[0-2])\/\d{2}$/, message: 'Invalid format' } })} onChange={(e) => setValue('expiry', fmtExp(e.target.value), { shouldValidate: true })} className={`${ic} ${errors.expiry ? 'border-red-400' : 'border-gray-300'}`} placeholder="08/27" maxLength={5} />
        </Field>
        <Field label="CVV" error={errors.cvv?.message}>
          <input {...register('cvv', { required: 'Required', pattern: { value: /^\d{3,4}$/, message: '3-4 digits' } })} type="password" className={`${ic} ${errors.cvv ? 'border-red-400' : 'border-gray-300'}`} placeholder="•••" maxLength={4} />
        </Field>
      </div>
      <p className="text-xs text-gray-400">Tip: Use card number starting with <strong>0000</strong> to simulate a declined payment.</p>
      <div className="flex gap-3">
        <Button variant="secondary" type="button" onClick={onBack} className="flex-1 py-3" disabled={isProcessing}>Back</Button>
        <Button type="submit" className="flex-1 py-3" disabled={isProcessing}>
          {isProcessing ? <><Spinner size="sm" /> Processing...</> : 'Place Order'}
        </Button>
      </div>
    </form>
  )
}
EOF

# ── Pages ─────────────────────────────────────────────────────
log "Writing pages..."

cat > src/pages/HomePage.jsx << 'EOF'
import { ShoppingBag } from 'lucide-react'
import useProducts from '../hooks/useProducts'
import ProductSearch from '../components/product/ProductSearch'
import ProductFilters from '../components/product/ProductFilters'
import ProductGrid from '../components/product/ProductGrid'
import EmptyState from '../components/ui/EmptyState'

export default function HomePage() {
  const { filtered, search, setSearch, category, setCategory, sort, setSort } = useProducts()
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8 text-center">
        <h1 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-2">Welcome to <span className="text-indigo-600">ShopWave</span></h1>
        <p className="text-gray-500">Discover premium products at unbeatable prices</p>
      </div>
      <div className="flex flex-col gap-4 mb-8">
        <ProductSearch value={search} onChange={setSearch} />
        <ProductFilters category={category} onCategory={setCategory} sort={sort} onSort={setSort} />
      </div>
      <p className="text-sm text-gray-500 mb-4">{filtered.length} product{filtered.length !== 1 ? 's' : ''}{search ? ` for "${search}"` : ''}{category !== 'All' ? ` in ${category}` : ''}</p>
      {filtered.length > 0 ? <ProductGrid products={filtered} /> : <EmptyState icon={<ShoppingBag className="w-16 h-16" />} title="No products found" description="Try adjusting your search or filters" />}
    </div>
  )
}
EOF

cat > src/pages/ProductDetailPage.jsx << 'EOF'
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
      {[1,2,3,4,5].map((star) => <Star key={star} className={`w-4 h-4 ${star <= Math.round(rating) ? 'fill-amber-400 text-amber-400' : 'text-gray-300'}`} />)}
    </div>
  )
}

export default function ProductDetailPage() {
  const { slug } = useParams()
  const navigate = useNavigate()
  const addItem = useCartStore((s) => s.addItem)
  const [added, setAdded] = useState(false)
  const product = getProductBySlug(slug)

  if (!product) return (
    <div className="max-w-7xl mx-auto px-4 py-20 text-center">
      <h2 className="text-xl font-semibold text-gray-700">Product not found</h2>
      <Link to="/" className="mt-4 inline-block text-indigo-600 hover:underline">Back to shop</Link>
    </div>
  )

  const discount = product.originalPrice ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100) : null
  const handleAddToCart = () => { addItem(product); toast.success(`${product.name} added to cart!`); setAdded(true); setTimeout(() => setAdded(false), 1500) }

  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <button onClick={() => navigate(-1)} className="flex items-center gap-1 text-sm text-gray-500 hover:text-indigo-600 mb-6 cursor-pointer"><ChevronLeft className="w-4 h-4" /> Back</button>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
        <div className="relative rounded-xl overflow-hidden bg-gray-100 aspect-square">
          <img src={product.images[0]} alt={product.name} className="w-full h-full object-cover" />
          {discount && <Badge className="absolute top-3 right-3 bg-red-500 text-white text-sm px-3 py-1">-{discount}% OFF</Badge>}
        </div>
        <div className="flex flex-col gap-4">
          <Badge className="w-fit bg-indigo-100 text-indigo-700">{product.category}</Badge>
          <h1 className="text-2xl font-bold text-gray-900">{product.name}</h1>
          <div className="flex items-center gap-2"><StarRating rating={product.rating} /><span className="text-sm text-gray-500">{product.rating} ({product.reviewCount} reviews)</span></div>
          <div className="flex items-baseline gap-3">
            <span className="text-3xl font-bold text-gray-900">{formatCurrency(product.price)}</span>
            {product.originalPrice && <span className="text-lg text-gray-400 line-through">{formatCurrency(product.originalPrice)}</span>}
          </div>
          <p className="text-gray-600 leading-relaxed">{product.description}</p>
          <div className="flex items-center gap-2 text-sm text-green-600"><Package className="w-4 h-4" />{product.stock > 5 ? `In stock (${product.stock} available)` : product.stock > 0 ? `Only ${product.stock} left!` : 'Out of stock'}</div>
          <div className="flex gap-3 pt-2">
            <Button onClick={handleAddToCart} disabled={product.stock === 0} className="flex-1 py-3">{added ? <><Check className="w-5 h-5" /> Added!</> : <><ShoppingCart className="w-5 h-5" /> Add to Cart</>}</Button>
            <Button variant="outline" onClick={() => { addItem(product); navigate('/cart') }} disabled={product.stock === 0} className="flex-1 py-3">Buy Now</Button>
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

cat > src/pages/CartPage.jsx << 'EOF'
import { Link } from 'react-router-dom'
import { ShoppingCart } from 'lucide-react'
import useCartStore from '../store/useCartStore'
import CartItem from '../components/cart/CartItem'
import CartSummary from '../components/cart/CartSummary'
import EmptyState from '../components/ui/EmptyState'
import Button from '../components/ui/Button'

export default function CartPage() {
  const items = useCartStore((s) => s.items)
  if (items.length === 0) return (
    <div className="max-w-7xl mx-auto px-4 py-20">
      <EmptyState icon={<ShoppingCart className="w-16 h-16" />} title="Your cart is empty" description="Add some products to get started" action={<Link to="/"><Button>Continue Shopping</Button></Link>} />
    </div>
  )
  return (
    <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Shopping Cart</h1>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 bg-white rounded-xl border border-gray-200 p-4 shadow-sm">
          {items.map((item) => <CartItem key={item.productId} item={item} />)}
        </div>
        <div>
          <CartSummary />
          <Link to="/" className="block mt-3"><Button variant="ghost" className="w-full">Continue Shopping</Button></Link>
        </div>
      </div>
    </div>
  )
}
EOF

cat > src/pages/CheckoutPage.jsx << 'EOF'
import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { nanoid } from 'nanoid'
import useCartStore from '../store/useCartStore'
import { mockProcessPayment } from '../utils/validatePayment'
import StepIndicator from '../components/checkout/StepIndicator'
import ShippingForm from '../components/checkout/ShippingForm'
import OrderReview from '../components/checkout/OrderReview'
import PaymentForm from '../components/checkout/PaymentForm'
import Button from '../components/ui/Button'

export default function CheckoutPage() {
  const navigate = useNavigate()
  const { items, clearCart, getSubtotal, getTax, getShippingCost, getTotal } = useCartStore()
  const [step, setStep] = useState(1)
  const [shippingData, setShippingData] = useState(null)
  const [isProcessing, setIsProcessing] = useState(false)

  if (items.length === 0) return (
    <div className="max-w-lg mx-auto px-4 py-20 text-center">
      <p className="text-gray-600 mb-4">Your cart is empty.</p>
      <Link to="/"><Button>Go Shopping</Button></Link>
    </div>
  )

  const handlePaymentSubmit = async (paymentData) => {
    setIsProcessing(true)
    try {
      await mockProcessPayment(paymentData.cardNumber)
      const order = { orderId: `ORD-${nanoid(6).toUpperCase()}`, items: [...items], shipping: shippingData, payment: { last4: paymentData.cardNumber.replace(/\s/g,'').slice(-4) }, subtotal: getSubtotal(), tax: getTax(), shippingCost: getShippingCost(), total: getTotal(), createdAt: new Date().toISOString(), status: 'confirmed' }
      sessionStorage.setItem('last-order', JSON.stringify(order))
      clearCart()
      navigate(`/order-confirmation/${order.orderId}`)
    } catch (err) {
      toast.error(err.message)
    } finally {
      setIsProcessing(false)
    }
  }

  return (
    <div className="max-w-lg mx-auto px-4 sm:px-6 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-6 text-center">Checkout</h1>
      <StepIndicator currentStep={step} />
      <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6">
        {step === 1 && <><h2 className="font-semibold text-gray-900 mb-4">Shipping Information</h2><ShippingForm onSubmit={(d) => { setShippingData(d); setStep(2) }} defaultValues={shippingData} /></>}
        {step === 2 && <><h2 className="font-semibold text-gray-900 mb-4">Review Your Order</h2><OrderReview shipping={shippingData} onBack={() => setStep(1)} onContinue={() => setStep(3)} /></>}
        {step === 3 && <><h2 className="font-semibold text-gray-900 mb-4">Payment Details</h2><PaymentForm onSubmit={handlePaymentSubmit} onBack={() => setStep(2)} isProcessing={isProcessing} /></>}
      </div>
    </div>
  )
}
EOF

cat > src/pages/OrderConfirmationPage.jsx << 'EOF'
import { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { CheckCircle, Package } from 'lucide-react'
import { formatCurrency } from '../utils/formatCurrency'
import Button from '../components/ui/Button'

export default function OrderConfirmationPage() {
  const { orderId } = useParams()
  const [order, setOrder] = useState(null)
  useEffect(() => { const s = sessionStorage.getItem('last-order'); if (s) setOrder(JSON.parse(s)) }, [])
  const deliveryStr = new Date(Date.now() + 5 * 86400000).toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })

  return (
    <div className="max-w-lg mx-auto px-4 sm:px-6 py-12">
      <div className="text-center mb-8">
        <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
        <h1 className="text-2xl font-bold text-gray-900">Order Confirmed!</h1>
        <p className="text-gray-500 mt-1">Thank you for your purchase.</p>
        <p className="text-sm font-mono bg-gray-100 rounded-lg px-4 py-2 mt-3 inline-block text-gray-700">{orderId}</p>
      </div>
      {order ? (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 space-y-5">
          <div>
            <h2 className="font-semibold text-gray-900 mb-3 flex items-center gap-2"><Package className="w-4 h-4" /> Items Ordered</h2>
            <div className="space-y-3">
              {order.items.map((item) => (
                <div key={item.productId} className="flex items-center gap-3">
                  <img src={item.image} alt={item.name} className="w-10 h-10 object-cover rounded bg-gray-100 flex-shrink-0" />
                  <div className="flex-1 min-w-0"><p className="text-sm font-medium text-gray-900 line-clamp-1">{item.name}</p><p className="text-xs text-gray-500">Qty: {item.quantity}</p></div>
                  <p className="text-sm font-semibold">{formatCurrency(item.price * item.quantity)}</p>
                </div>
              ))}
            </div>
          </div>
          <div className="border-t border-gray-100 pt-4 space-y-1 text-sm">
            <div className="flex justify-between text-gray-600"><span>Subtotal</span><span>{formatCurrency(order.subtotal)}</span></div>
            <div className="flex justify-between text-gray-600"><span>Tax</span><span>{formatCurrency(order.tax)}</span></div>
            <div className="flex justify-between text-gray-600"><span>Shipping</span><span>{order.shippingCost === 0 ? 'Free' : formatCurrency(order.shippingCost)}</span></div>
            <div className="flex justify-between font-bold text-gray-900 text-base pt-1 border-t border-gray-200"><span>Total</span><span>{formatCurrency(order.total)}</span></div>
          </div>
          <div className="border-t border-gray-100 pt-4">
            <p className="text-sm text-gray-600"><span className="font-medium">Shipping to:</span> {order.shipping.firstName} {order.shipping.lastName}, {order.shipping.address}, {order.shipping.city}, {order.shipping.state} {order.shipping.zip}</p>
            <p className="text-sm text-gray-600 mt-1"><span className="font-medium">Confirmation sent to:</span> {order.shipping.email}</p>
            <p className="text-sm text-green-600 font-medium mt-1">Estimated delivery: {deliveryStr}</p>
          </div>
          <div className="border-t border-gray-100 pt-4 text-sm text-gray-500">Paid with card ending in <strong>{order.payment.last4}</strong></div>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 shadow-sm p-6 text-center text-gray-500">Order details unavailable (session may have expired).</div>
      )}
      <Link to="/" className="block mt-6"><Button className="w-full py-3">Continue Shopping</Button></Link>
    </div>
  )
}
EOF

ok "All pages created"

# ── CLAUDE.md ─────────────────────────────────────────────────
log "Writing CLAUDE.md..."
cat > CLAUDE.md << 'CLAUDE_EOF'
# ShopWave — E-Commerce React App

## Project Overview
A fully client-side e-commerce application built with React + Vite. No backend required.
All state is managed client-side with localStorage persistence.

## Tech Stack
- **Vite 5** + **React 18**
- **React Router v6** — routing
- **Zustand 4** — global cart state with localStorage persistence (`ecommerce-cart` key)
- **Tailwind CSS v4** — styling via `@tailwindcss/vite` plugin (no config file needed)
- **React Hook Form** — shipping & payment forms
- **Lucide React** — icons
- **React Hot Toast** — notifications
- **nanoid** — order ID generation

## Project Structure
```
src/
├── data/products.js          # 16 dummy products (4 categories)
├── store/useCartStore.js     # Zustand cart store
├── utils/formatCurrency.js   # USD formatter
├── utils/validatePayment.js  # mockProcessPayment() — declines cards starting with 0000
├── hooks/useProducts.js      # Filter/sort/search with 300ms debounce
├── components/
│   ├── layout/               # Navbar, Footer, Layout
│   ├── ui/                   # Button, Badge, Spinner, EmptyState
│   ├── product/              # ProductCard, ProductGrid, ProductFilters, ProductSearch
│   ├── cart/                 # CartItem, CartSummary
│   └── checkout/             # StepIndicator, ShippingForm, OrderReview, PaymentForm
└── pages/
    ├── HomePage.jsx
    ├── ProductDetailPage.jsx
    ├── CartPage.jsx
    ├── CheckoutPage.jsx      # 3-step: Shipping → Review → Payment
    └── OrderConfirmationPage.jsx
```

## Routes
| Path | Page |
|------|------|
| `/` | HomePage |
| `/product/:slug` | ProductDetailPage |
| `/cart` | CartPage |
| `/checkout` | CheckoutPage |
| `/order-confirmation/:orderId` | OrderConfirmationPage |

## Key Behaviors
- Cart persists via Zustand persist middleware → localStorage key: `ecommerce-cart`
- Order saved to `sessionStorage` before cart clear, read on confirmation page
- Free shipping on orders ≥ $50; otherwise $9.99. Tax = 8% of subtotal
- Decline simulation: card number starting with `0000`
- Products use slug-based routing (not IDs)

## Tailwind CSS v4 Notes
- No `tailwind.config.js` — config in `src/index.css` via `@theme {}`
- Import: `@import "tailwindcss"` (not `@tailwind` directives)
- Plugin: `@tailwindcss/vite` in `vite.config.js`

## Dev Commands
```bash
npm run dev      # http://localhost:5173
npm run build    # production build
npm run preview  # preview build
```

## Git & GitHub Workflow
**IMPORTANT: Every time a feature or functionality is completed, push the code to GitHub with a descriptive commit message.**

```bash
git add <relevant files>
git commit -m "feat: <description>"
git push origin main
```

Commit prefixes: `feat:` | `fix:` | `refactor:` | `style:` | `chore:`
CLAUDE_EOF

# ── Git init ──────────────────────────────────────────────────
log "Initializing git repository..."
git init -q
git add .
git commit -q -m "feat: initial ShopWave e-commerce app

Full client-side e-commerce app with:
- Home page: 16 products, category filters, search, sorting
- Product detail page
- Cart with quantity controls and order summary
- 3-step checkout (shipping, review, payment)
- Mock payment processing with order confirmation
- Zustand cart state with localStorage persistence
- Tailwind CSS v4, React Router v6, React Hook Form

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
git branch -M main
ok "Git repository initialized with initial commit"

# ── Final instructions ────────────────────────────────────────
echo ""
echo "  ✅  Setup complete!"
echo ""
echo "  📁  Project: $(pwd)"
echo ""
echo "  Next steps:"
echo "  ──────────────────────────────────────────────"
echo "  1. Start the dev server:"
echo "     cd ${APP_NAME} && npm run dev"
echo ""
echo "  2. Push to GitHub (optional):"
echo "     gh repo create ${APP_NAME} --public --source=. --remote=origin --push"
echo "     (requires GitHub CLI: brew install gh && gh auth login)"
echo ""
echo "  3. Open in browser:"
echo "     http://localhost:5173"
echo ""
echo "  Test tip: Use card number starting with '0000' to test payment decline."
echo ""
