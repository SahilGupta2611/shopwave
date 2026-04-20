export const mockProcessPayment = async (cardNumber) => {
  const digits = cardNumber.replace(/\s/g, '')
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 1500))
  // Simulate card decline for cards starting with 0000
  if (digits.startsWith('0000')) {
    throw new Error('Your card was declined. Please try a different card.')
  }
  return { success: true }
}
