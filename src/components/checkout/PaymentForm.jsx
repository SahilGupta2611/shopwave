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

const inputClass = 'w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent'
const errorInputClass = 'border-red-400'
const normalInputClass = 'border-gray-300'

function formatCardNumber(value) {
  return value.replace(/\D/g, '').slice(0, 16).replace(/(\d{4})(?=\d)/g, '$1 ')
}

function formatExpiry(value) {
  const digits = value.replace(/\D/g, '').slice(0, 4)
  if (digits.length >= 3) return `${digits.slice(0, 2)}/${digits.slice(2)}`
  return digits
}

export default function PaymentForm({ onSubmit, onBack, isProcessing }) {
  const { register, handleSubmit, setValue, watch, formState: { errors } } = useForm()

  const handleCardNumber = (e) => {
    const formatted = formatCardNumber(e.target.value)
    setValue('cardNumber', formatted, { shouldValidate: true })
  }

  const handleExpiry = (e) => {
    const formatted = formatExpiry(e.target.value)
    setValue('expiry', formatted, { shouldValidate: true })
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="flex items-center gap-2 text-sm text-gray-500 bg-green-50 border border-green-200 rounded-lg px-3 py-2 mb-2">
        <Lock className="w-4 h-4 text-green-600" />
        Secure mock payment — no real charges
      </div>

      <Field label="Name on Card" error={errors.cardName?.message}>
        <input
          {...register('cardName', { required: 'Required' })}
          className={`${inputClass} ${errors.cardName ? errorInputClass : normalInputClass}`}
          placeholder="Jane Doe"
        />
      </Field>

      <Field label="Card Number" error={errors.cardNumber?.message}>
        <div className="relative">
          <input
            {...register('cardNumber', {
              required: 'Required',
              validate: (v) => v.replace(/\s/g, '').length === 16 || 'Must be 16 digits',
            })}
            onChange={handleCardNumber}
            className={`${inputClass} ${errors.cardNumber ? errorInputClass : normalInputClass} pr-10`}
            placeholder="1234 5678 9012 3456"
            maxLength={19}
          />
          <CreditCard className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
        </div>
      </Field>

      <div className="grid grid-cols-2 gap-4">
        <Field label="Expiry (MM/YY)" error={errors.expiry?.message}>
          <input
            {...register('expiry', {
              required: 'Required',
              pattern: { value: /^(0[1-9]|1[0-2])\/\d{2}$/, message: 'Invalid format' },
            })}
            onChange={handleExpiry}
            className={`${inputClass} ${errors.expiry ? errorInputClass : normalInputClass}`}
            placeholder="08/27"
            maxLength={5}
          />
        </Field>
        <Field label="CVV" error={errors.cvv?.message}>
          <input
            {...register('cvv', {
              required: 'Required',
              pattern: { value: /^\d{3,4}$/, message: '3-4 digits' },
            })}
            type="password"
            className={`${inputClass} ${errors.cvv ? errorInputClass : normalInputClass}`}
            placeholder="•••"
            maxLength={4}
          />
        </Field>
      </div>

      <p className="text-xs text-gray-400">
        Tip: Use card number starting with <strong>0000</strong> to simulate a declined payment.
      </p>

      <div className="flex gap-3">
        <Button variant="secondary" type="button" onClick={onBack} className="flex-1 py-3" disabled={isProcessing}>
          Back
        </Button>
        <Button type="submit" className="flex-1 py-3" disabled={isProcessing}>
          {isProcessing ? (
            <><Spinner size="sm" /> Processing...</>
          ) : (
            'Place Order'
          )}
        </Button>
      </div>
    </form>
  )
}
