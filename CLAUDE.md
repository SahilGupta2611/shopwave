# ShopWave — E-Commerce React App

## Project Overview
A fully client-side e-commerce application built with React + Vite. No backend — all state is managed client-side with localStorage persistence. GitHub repo: https://github.com/SahilGupta2611/shopwave (update if different).

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
├── store/useCartStore.js     # Zustand cart store (addItem, removeItem, updateQuantity, clearCart)
├── utils/
│   ├── formatCurrency.js     # Intl.NumberFormat USD formatter
│   └── validatePayment.js    # mockProcessPayment() — 1.5s delay, declines cards starting with 0000
├── hooks/useProducts.js      # Filter/sort/search logic with 300ms debounce
├── components/
│   ├── layout/               # Navbar, Footer, Layout
│   ├── ui/                   # Button, Badge, Spinner, EmptyState
│   ├── product/              # ProductCard, ProductGrid, ProductFilters, ProductSearch
│   ├── cart/                 # CartItem, CartSummary
│   └── checkout/             # StepIndicator, ShippingForm, OrderReview, PaymentForm
└── pages/
    ├── HomePage.jsx           # Product grid + filters + search
    ├── ProductDetailPage.jsx  # Single product view
    ├── CartPage.jsx           # Cart items + summary
    ├── CheckoutPage.jsx       # 3-step checkout (Shipping → Review → Payment)
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
- Cart persists across refreshes via Zustand `persist` middleware → localStorage
- Order data saved to `sessionStorage` before cart clear, read on confirmation page
- Free shipping on orders ≥ $50; otherwise $9.99
- Tax is 8% of subtotal
- Declining payment simulation: card numbers starting with `0000`
- Product slugs are used as URL params (not IDs)

## Dev Commands
```bash
npm run dev      # start dev server (usually http://localhost:5173)
npm run build    # production build
npm run preview  # preview production build
```

## Tailwind CSS v4 Note
This project uses Tailwind CSS v4 (not v3). Key differences:
- No `tailwind.config.js` — configuration is in `src/index.css` via `@theme {}`
- Import via `@import "tailwindcss"` in CSS (not `@tailwind` directives)
- Plugin: `@tailwindcss/vite` added to `vite.config.js`

## Git & GitHub Workflow
**IMPORTANT: Every time a feature or functionality is completed, push the code to GitHub with a descriptive commit message.**

Commit message format:
```
feat: add <feature name>

Brief description of what was added/changed and why.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

Push command after each completed feature:
```bash
git add <relevant files>
git commit -m "feat: ..."
git push origin main
```

Common prefixes: `feat:` (new feature), `fix:` (bug fix), `refactor:` (restructure), `style:` (UI changes), `chore:` (config/deps).
