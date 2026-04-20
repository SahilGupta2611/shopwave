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

const inputClass = 'w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-transparent'
const errorInputClass = 'border-red-400'
const normalInputClass = 'border-gray-300'

export default function ShippingForm({ onSubmit, defaultValues }) {
  const { register, handleSubmit, formState: { errors } } = useForm({ defaultValues })

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Field label="First Name" error={errors.firstName?.message}>
          <input
            {...register('firstName', { required: 'Required', minLength: { value: 2, message: 'Min 2 chars' } })}
            className={`${inputClass} ${errors.firstName ? errorInputClass : normalInputClass}`}
            placeholder="Jane"
          />
        </Field>
        <Field label="Last Name" error={errors.lastName?.message}>
          <input
            {...register('lastName', { required: 'Required', minLength: { value: 2, message: 'Min 2 chars' } })}
            className={`${inputClass} ${errors.lastName ? errorInputClass : normalInputClass}`}
            placeholder="Doe"
          />
        </Field>
      </div>

      <Field label="Email" error={errors.email?.message}>
        <input
          {...register('email', {
            required: 'Required',
            pattern: { value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email' },
          })}
          type="email"
          className={`${inputClass} ${errors.email ? errorInputClass : normalInputClass}`}
          placeholder="jane@example.com"
        />
      </Field>

      <Field label="Street Address" error={errors.address?.message}>
        <input
          {...register('address', { required: 'Required' })}
          className={`${inputClass} ${errors.address ? errorInputClass : normalInputClass}`}
          placeholder="123 Main St"
        />
      </Field>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
        <Field label="City" error={errors.city?.message}>
          <input
            {...register('city', { required: 'Required' })}
            className={`${inputClass} ${errors.city ? errorInputClass : normalInputClass}`}
            placeholder="Springfield"
          />
        </Field>
        <Field label="State" error={errors.state?.message}>
          <input
            {...register('state', {
              required: 'Required',
              pattern: { value: /^[A-Z]{2}$/, message: '2-letter code' },
            })}
            className={`${inputClass} ${errors.state ? errorInputClass : normalInputClass}`}
            placeholder="IL"
            maxLength={2}
            style={{ textTransform: 'uppercase' }}
          />
        </Field>
        <Field label="ZIP Code" error={errors.zip?.message}>
          <input
            {...register('zip', {
              required: 'Required',
              pattern: { value: /^\d{5}$/, message: '5-digit ZIP' },
            })}
            className={`${inputClass} ${errors.zip ? errorInputClass : normalInputClass}`}
            placeholder="62701"
            maxLength={5}
          />
        </Field>
      </div>

      <Button type="submit" className="w-full py-3 mt-2">
        Continue to Review
      </Button>
    </form>
  )
}
