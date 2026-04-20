import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import toast from 'react-hot-toast'
import { nanoid } from 'nanoid'
import useCartStore from '../store/useCartStore'
import { mockProcessPayment } from '../utils/validatePayment'
import { formatCurrency } from '../utils/formatCurrency'
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

  if (items.length === 0) {
    return (
      <div className="max-w-lg mx-auto px-4 py-20 text-center">
        <p className="text-gray-600 mb-4">Your cart is empty.</p>
        <Link to="/"><Button>Go Shopping</Button></Link>
      </div>
    )
  }

  const handleShippingSubmit = (data) => {
    setShippingData(data)
    setStep(2)
  }

  const handlePaymentSubmit = async (paymentData) => {
    setIsProcessing(true)
    try {
      await mockProcessPayment(paymentData.cardNumber)

      const order = {
        orderId: `ORD-${nanoid(6).toUpperCase()}`,
        items: [...items],
        shipping: shippingData,
        payment: { last4: paymentData.cardNumber.replace(/\s/g, '').slice(-4) },
        subtotal: getSubtotal(),
        tax: getTax(),
        shippingCost: getShippingCost(),
        total: getTotal(),
        createdAt: new Date().toISOString(),
        status: 'confirmed',
      }

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
        {step === 1 && (
          <>
            <h2 className="font-semibold text-gray-900 mb-4">Shipping Information</h2>
            <ShippingForm onSubmit={handleShippingSubmit} defaultValues={shippingData} />
          </>
        )}

        {step === 2 && (
          <>
            <h2 className="font-semibold text-gray-900 mb-4">Review Your Order</h2>
            <OrderReview
              shipping={shippingData}
              onBack={() => setStep(1)}
              onContinue={() => setStep(3)}
            />
          </>
        )}

        {step === 3 && (
          <>
            <h2 className="font-semibold text-gray-900 mb-4">Payment Details</h2>
            <PaymentForm
              onSubmit={handlePaymentSubmit}
              onBack={() => setStep(2)}
              isProcessing={isProcessing}
            />
          </>
        )}
      </div>
    </div>
  )
}
