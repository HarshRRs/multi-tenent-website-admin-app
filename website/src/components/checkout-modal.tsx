'use client';

import { useState } from 'react';
import { useCartStore } from '@/store/cart-store';
import { useConfigStore } from '@/store/config-store';
import { useRestaurant } from '@/contexts/restaurant-context';
import { X, CreditCard, Wallet, Loader2, CheckCircle } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import apiClient from '@/lib/api-client';
import { loadStripe } from '@stripe/stripe-js';
import { Elements, CardElement, useStripe, useElements } from '@stripe/react-stripe-js';

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || '');

const checkoutSchema = z.object({
    customerName: z.string().min(2, 'Name must be at least 2 characters'),
    customerEmail: z.string().email('Invalid email address'),
    customerPhone: z.string().min(10, 'Phone number must be at least 10 digits'),
    deliveryAddress: z.string().min(10, 'Please enter a complete address'),
    paymentMethod: z.enum(['card', 'cash']),
});

type CheckoutFormData = z.infer<typeof checkoutSchema>;

function CheckoutForm({ onClose }: { onClose: () => void }) {
    const { items, getTotal, clearCart } = useCartStore();
    const { config } = useConfigStore();
    const { restaurant } = useRestaurant();
    const [step, setStep] = useState(1);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [orderSuccess, setOrderSuccess] = useState(false);
    const [orderNumber, setOrderNumber] = useState('');
    const [couponCode, setCouponCode] = useState('');
    const [appliedCoupon, setAppliedCoupon] = useState<{ id: string, amount: number } | null>(null);
    const [isValidatingCoupon, setIsValidatingCoupon] = useState(false);
    const [couponError, setCouponError] = useState<string | null>(null);

    const stripe = useStripe();
    const elements = useElements();

    const {
        register,
        handleSubmit,
        watch,
        formState: { errors },
    } = useForm<CheckoutFormData>({
        resolver: zodResolver(checkoutSchema),
        defaultValues: {
            paymentMethod: 'cash',
        },
    });

    const paymentMethod = watch('paymentMethod');

    const handleApplyCoupon = async () => {
        if (!couponCode || !restaurant?.id) return;
        setIsValidatingCoupon(true);
        setCouponError(null);
        try {
            const response = await apiClient.post('/coupons/validate', {
                code: couponCode,
                cartTotal: getTotal(),
                restaurantId: restaurant.id
            });
            setAppliedCoupon({ id: response.data.couponId, amount: response.data.discountAmount });
        } catch (error: any) {
            setCouponError(error.response?.data?.message || 'Invalid coupon code');
            setAppliedCoupon(null);
        } finally {
            setIsValidatingCoupon(false);
        }
    };

    const onSubmit = async (data: CheckoutFormData) => {
        setIsSubmitting(true);
        try {
            const orderData = {
                restaurantId: restaurant?.id,
                customerName: data.customerName,
                customerEmail: data.customerEmail,
                customerPhone: data.customerPhone,
                deliveryAddress: data.deliveryAddress,
                paymentMethod: data.paymentMethod,
                totalAmount: getTotal(),
                couponCode: appliedCoupon ? couponCode : undefined,
                items: items.map(item => ({
                    name: item.name,
                    quantity: item.quantity,
                    price: item.price,
                    selectedModifiers: item.selectedModifiers,
                })),
            };

            if (!restaurant?.id) {
                throw new Error('Restaurant information missing. Please refresh the page.');
            }

            const response = await apiClient.post('/public/order', orderData);

            // Handle card payment
            if (data.paymentMethod === 'card' && stripe && elements) {
                const cardElement = elements.getElement(CardElement);
                if (!cardElement) {
                    throw new Error('Card element not found');
                }

                const { error, paymentIntent } = await stripe.confirmCardPayment(
                    response.data.paymentIntent.clientSecret,
                    {
                        payment_method: {
                            card: cardElement,
                            billing_details: {
                                name: data.customerName,
                                email: data.customerEmail,
                            },
                        },
                    }
                );

                if (error) {
                    throw new Error(error.message);
                }

                if (paymentIntent?.status !== 'succeeded') {
                    throw new Error('Payment failed');
                }
            }

            setOrderNumber(response.data.order.id.slice(0, 8).toUpperCase());
            setOrderSuccess(true);
            clearCart();
        } catch (error: any) {
            console.error('Order error:', error);
            alert(error.message || 'Failed to place order. Please try again.');
        } finally {
            setIsSubmitting(false);
        }
    };

    if (orderSuccess) {
        return (
            <div className="flex flex-col items-center justify-center p-12 text-center">
                <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
                    <CheckCircle className="text-green-600" size={48} />
                </div>
                <h2 className="text-3xl font-black text-gray-900 mb-4">Order Confirmed!</h2>
                <p className="text-gray-600 mb-2">Order #{orderNumber}</p>
                <p className="text-gray-500 mb-8">
                    We&apos;ve sent a confirmation email with all the details.
                </p>
                <button
                    onClick={onClose}
                    className="px-8 py-3 rounded-2xl text-white font-bold"
                    style={{ backgroundColor: config?.primaryColor }}
                >
                    Continue Shopping
                </button>
            </div>
        );
    }

    return (
        <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col h-full">
            {/* Steps Indicator */}
            <div className="flex items-center justify-center gap-2 mb-8 px-8 pt-8">
                {[1, 2, 3].map((s) => (
                    <div
                        key={s}
                        className={`h-2 flex-1 rounded-full transition-colors ${s <= step ? 'opacity-100' : 'bg-gray-200 opacity-50'
                            }`}
                        style={{ backgroundColor: s <= step ? config?.primaryColor : undefined }}
                    />
                ))}
            </div>

            <div className="flex-1 overflow-y-auto px-8 pb-8">
                {/* Step 1: Contact Info */}
                {step === 1 && (
                    <div className="space-y-6 animate-fade-in">
                        <h3 className="text-2xl font-bold text-gray-900 mb-6">Contact Information</h3>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Full Name</label>
                            <input
                                {...register('customerName')}
                                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                placeholder="John Doe"
                            />
                            {errors.customerName && (
                                <p className="text-red-500 text-sm mt-1">{errors.customerName.message}</p>
                            )}
                        </div>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Email</label>
                            <input
                                {...register('customerEmail')}
                                type="email"
                                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                placeholder="john@example.com"
                            />
                            {errors.customerEmail && (
                                <p className="text-red-500 text-sm mt-1">{errors.customerEmail.message}</p>
                            )}
                        </div>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Phone</label>
                            <input
                                {...register('customerPhone')}
                                type="tel"
                                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                placeholder="+1 (555) 123-4567"
                            />
                            {errors.customerPhone && (
                                <p className="text-red-500 text-sm mt-1">{errors.customerPhone.message}</p>
                            )}
                        </div>
                    </div>
                )}

                {/* Step 2: Delivery Address */}
                {step === 2 && (
                    <div className="space-y-6 animate-fade-in">
                        <h3 className="text-2xl font-bold text-gray-900 mb-6">Delivery Address</h3>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2">Full Address</label>
                            <textarea
                                {...register('deliveryAddress')}
                                rows={4}
                                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors resize-none"
                                placeholder="123 Main St, Apt 4B, New York, NY 10001"
                            />
                            {errors.deliveryAddress && (
                                <p className="text-red-500 text-sm mt-1">{errors.deliveryAddress.message}</p>
                            )}
                        </div>
                    </div>
                )}

                {/* Step 3: Payment */}
                {step === 3 && (
                    <div className="space-y-6 animate-fade-in">
                        <h3 className="text-2xl font-bold text-gray-900 mb-6">Payment Method</h3>

                        <div className="space-y-4">
                            <label className="flex items-center gap-4 p-4 border-2 rounded-2xl cursor-pointer transition-all hover:bg-gray-50">
                                <input
                                    {...register('paymentMethod')}
                                    type="radio"
                                    value="card"
                                    className="w-5 h-5"
                                />
                                <CreditCard size={24} />
                                <span className="flex-1 font-bold text-gray-900">Credit/Debit Card</span>
                            </label>

                            <label className="flex items-center gap-4 p-4 border-2 rounded-2xl cursor-pointer transition-all hover:bg-gray-50">
                                <input
                                    {...register('paymentMethod')}
                                    type="radio"
                                    value="cash"
                                    className="w-5 h-5"
                                />
                                <Wallet size={24} />
                                <span className="flex-1 font-bold text-gray-900">Cash on Delivery</span>
                            </label>
                        </div>

                        {paymentMethod === 'card' && (
                            <div className="mt-6 p-4 bg-gray-50 rounded-2xl">
                                <label className="block text-sm font-bold text-gray-700 mb-3">Card Details</label>
                                <div className="p-4 bg-white rounded-xl border-2 border-gray-200">
                                    <CardElement
                                        options={{
                                            style: {
                                                base: {
                                                    fontSize: '16px',
                                                    color: '#111827',
                                                    '::placeholder': {
                                                        color: '#9ca3af',
                                                    },
                                                },
                                            },
                                        }}
                                    />
                                </div>
                            </div>
                        )}

                        {/* Coupon Code section */}
                        <div className="mt-6">
                            <label className="block text-sm font-bold text-gray-700 mb-2">Coupon Code</label>
                            <div className="flex gap-2">
                                <input
                                    type="text"
                                    value={couponCode}
                                    onChange={(e) => setCouponCode(e.target.value.toUpperCase())}
                                    className="flex-1 px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                    placeholder="Enter code"
                                    disabled={!!appliedCoupon || isValidatingCoupon}
                                />
                                {appliedCoupon ? (
                                    <button
                                        type="button"
                                        onClick={() => { setAppliedCoupon(null); setCouponCode(''); }}
                                        className="px-4 py-3 rounded-xl bg-red-50 text-red-600 font-bold"
                                    >
                                        Remove
                                    </button>
                                ) : (
                                    <button
                                        type="button"
                                        onClick={handleApplyCoupon}
                                        disabled={!couponCode || isValidatingCoupon}
                                        className="px-4 py-3 rounded-xl bg-gray-900 text-white font-bold disabled:opacity-50"
                                    >
                                        {isValidatingCoupon ? <Loader2 className="animate-spin" size={20} /> : 'Apply'}
                                    </button>
                                )}
                            </div>
                            {couponError && <p className="text-red-500 text-sm mt-1">{couponError}</p>}
                            {appliedCoupon && <p className="text-green-600 text-sm mt-1 font-bold">Coupon applied! -${appliedCoupon.amount.toFixed(2)}</p>}
                        </div>

                        {/* Order Summary */}
                        <div className="mt-8 p-6 bg-gray-50 rounded-2xl">
                            <h4 className="font-bold text-gray-900 mb-4">Order Summary</h4>
                            <div className="space-y-2">
                                {items.map((item) => (
                                    <div key={item.id} className="flex justify-between text-sm">
                                        <span className="text-gray-600">
                                            {item.name} x{item.quantity}
                                        </span>
                                        <span className="font-bold text-gray-900">
                                            ${(item.price * item.quantity).toFixed(2)}
                                        </span>
                                    </div>
                                ))}
                                <span className="font-bold text-gray-900">Subtotal</span>
                                <span className="font-bold text-gray-900">
                                    ${getTotal().toFixed(2)}
                                </span>
                            </div>
                            {appliedCoupon && (
                                <div className="flex justify-between text-green-600 font-bold">
                                    <span>Discount</span>
                                    <span>-${appliedCoupon.amount.toFixed(2)}</span>
                                </div>
                            )}
                            <div className="border-t-2 border-gray-200 pt-2 mt-2 flex justify-between">
                                <span className="font-bold text-gray-900">Total</span>
                                <span className="text-2xl font-black" style={{ color: config?.primaryColor }}>
                                    ${(getTotal() - (appliedCoupon?.amount || 0)).toFixed(2)}
                                </span>
                            </div>
                        </div>
                    </div>
                )}
            </div>

            {/* Actions */}
            <div className="flex gap-3 p-8 border-t border-gray-200">
                {step > 1 && (
                    <button
                        type="button"
                        onClick={() => setStep(step - 1)}
                        className="flex-1 py-4 rounded-2xl bg-gray-100 text-gray-900 font-bold"
                    >
                        Back
                    </button>
                )}

                {step < 3 ? (
                    <button
                        type="button"
                        onClick={() => setStep(step + 1)}
                        className="flex-1 py-4 rounded-2xl text-white font-bold"
                        style={{ backgroundColor: config?.primaryColor }}
                    >
                        Continue
                    </button>
                ) : (
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className="flex-1 py-4 rounded-2xl text-white font-bold flex items-center justify-center gap-2"
                        style={{ backgroundColor: config?.primaryColor }}
                    >
                        {isSubmitting ? (
                            <>
                                <Loader2 className="animate-spin" size={20} />
                                Processing...
                            </>
                        ) : (
                            <>{paymentMethod === 'card' ? 'Pay Now' : 'Place Order'}</>
                        )}
                    </button>
                )}
            </div>
        </form>
    );
}

export default function CheckoutModal({ onClose }: { onClose: () => void }) {
    return (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60" onClick={onClose} />

            <div className="relative bg-white rounded-3xl w-full max-w-2xl max-h-[90vh] flex flex-col shadow-2xl">
                <button
                    onClick={onClose}
                    className="absolute top-6 right-6 p-2 hover:bg-gray-100 rounded-full transition-colors z-10"
                >
                    <X size={24} />
                </button>

                <Elements stripe={stripePromise}>
                    <CheckoutForm onClose={onClose} />
                </Elements>
            </div>
        </div>
    );
}
