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
      {/* Hero */}
      <div className="mb-8 text-center">
        <h1 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-2">
          Welcome to <span className="text-indigo-600">ShopWave</span>
        </h1>
        <p className="text-gray-500">Discover premium products at unbeatable prices</p>
      </div>

      {/* Search + Filters */}
      <div className="flex flex-col gap-4 mb-8">
        <ProductSearch value={search} onChange={setSearch} />
        <ProductFilters
          category={category}
          onCategory={setCategory}
          sort={sort}
          onSort={setSort}
        />
      </div>

      {/* Results count */}
      <p className="text-sm text-gray-500 mb-4">
        {filtered.length} product{filtered.length !== 1 ? 's' : ''}
        {search ? ` for "${search}"` : ''}
        {category !== 'All' ? ` in ${category}` : ''}
      </p>

      {/* Grid or Empty */}
      {filtered.length > 0 ? (
        <ProductGrid products={filtered} />
      ) : (
        <EmptyState
          icon={<ShoppingBag className="w-16 h-16" />}
          title="No products found"
          description="Try adjusting your search or filters"
        />
      )}
    </div>
  )
}
