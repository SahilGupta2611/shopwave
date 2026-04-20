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
          set({
            items: items.map((i) =>
              i.productId === product.id
                ? { ...i, quantity: Math.min(i.quantity + 1, product.stock) }
                : i
            ),
          })
        } else {
          set({
            items: [
              ...items,
              {
                productId: product.id,
                name: product.name,
                price: product.price,
                image: product.images[0],
                quantity: 1,
                stock: product.stock,
              },
            ],
          })
        }
      },

      removeItem: (productId) => {
        set({ items: get().items.filter((i) => i.productId !== productId) })
      },

      updateQuantity: (productId, qty) => {
        const item = get().items.find((i) => i.productId === productId)
        if (!item) return
        const clamped = Math.max(1, Math.min(qty, item.stock))
        set({
          items: get().items.map((i) =>
            i.productId === productId ? { ...i, quantity: clamped } : i
          ),
        })
      },

      clearCart: () => set({ items: [] }),

      // Derived values as getters
      getItemCount: () => get().items.reduce((sum, i) => sum + i.quantity, 0),
      getSubtotal: () => get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
      getTax: () => get().getSubtotal() * 0.08,
      getShippingCost: () => (get().getSubtotal() >= 50 ? 0 : 9.99),
      getTotal: () => get().getSubtotal() + get().getTax() + get().getShippingCost(),
    }),
    {
      name: 'ecommerce-cart',
    }
  )
)

export default useCartStore
