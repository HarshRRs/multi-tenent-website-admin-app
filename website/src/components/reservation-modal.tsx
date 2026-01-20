'use client';

import { useState } from 'react';
import { useConfigStore } from '@/store/config-store';
import { useRestaurant } from '@/contexts/restaurant-context';
import { X, Calendar, Users, Clock, CheckCircle, Loader2 } from 'lucide-react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import apiClient from '@/lib/api-client';

const reservationSchema = z.object({
    customerName: z.string().min(2, 'Name must be at least 2 characters'),
    customerEmail: z.string().email('Invalid email address'),
    customerPhone: z.string().min(10, 'Phone number must be at least 10 digits'),
    partySize: z.number().min(1).max(20),
    date: z.string().min(1, 'Please select a date'),
    time: z.string().min(1, 'Please select a time'),
});

type ReservationFormData = z.infer<typeof reservationSchema>;

export default function ReservationModal({ onClose }: { onClose: () => void }) {
    const { config } = useConfigStore();
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [reservationSuccess, setReservationSuccess] = useState(false);

    const {
        register,
        handleSubmit,
        formState: { errors },
    } = useForm<ReservationFormData>({
        resolver: zodResolver(reservationSchema),
        defaultValues: {
            partySize: 2,
        },
    });

    const onSubmit = async (data: ReservationFormData) => {
        setIsSubmitting(true);
        try {
            const reservationDateTime = new Date(`${data.date}T${data.time}`);

            const reservationData = {
                restaurantId: process.env.NEXT_PUBLIC_RESTAURANT_ID,
                customerName: data.customerName,
                customerEmail: data.customerEmail,
                customerPhone: data.customerPhone,
                partySize: data.partySize,
                time: reservationDateTime.toISOString(),
            };

            await apiClient.post('/public/reservation', reservationData);
            setReservationSuccess(true);
        } catch (error: any) {
            console.error('Reservation error:', error);
            alert(error.response?.data?.message || 'Failed to create reservation. Please try again.');
        } finally {
            setIsSubmitting(false);
        }
    };

    // Get today's date for min attribute
    const today = new Date().toISOString().split('T')[0];

    if (reservationSuccess) {
        return (
            <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
                <div className="absolute inset-0 bg-black/60" onClick={onClose} />

                <div className="relative bg-white rounded-3xl w-full max-w-md p-12 shadow-2xl">
                    <div className="flex flex-col items-center text-center">
                        <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mb-6">
                            <CheckCircle className="text-green-600" size={48} />
                        </div>
                        <h2 className="text-3xl font-black text-gray-900 mb-4">Reservation Confirmed!</h2>
                        <p className="text-gray-500 mb-8">
                            We&apos;ve sent a confirmation email with all the details. See you soon!
                        </p>
                        <button
                            onClick={onClose}
                            className="px-8 py-3 rounded-2xl text-white font-bold"
                            style={{ backgroundColor: config?.primaryColor }}
                        >
                            Close
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="fixed inset-0 z-[60] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60" onClick={onClose} />

            <div className="relative bg-white rounded-3xl w-full max-w-2xl max-h-[90vh] overflow-y-auto shadow-2xl">
                <div className="sticky top-0 bg-white border-b border-gray-200 p-6 flex items-center justify-between z-10">
                    <h2 className="text-3xl font-black text-gray-900">Reserve a Table</h2>
                    <button
                        onClick={onClose}
                        className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                    >
                        <X size={24} />
                    </button>
                </div>

                <form onSubmit={handleSubmit(onSubmit)} className="p-8 space-y-6">
                    {/* Contact Info */}
                    <div className="space-y-4">
                        <h3 className="text-lg font-bold text-gray-900">Contact Information</h3>

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

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
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
                    </div>

                    {/* Reservation Details */}
                    <div className="space-y-4 pt-6 border-t border-gray-200">
                        <h3 className="text-lg font-bold text-gray-900">Reservation Details</h3>

                        <div>
                            <label className="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                <Users size={16} />
                                Party Size
                            </label>
                            <select
                                {...register('partySize', { valueAsNumber: true })}
                                className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                            >
                                {Array.from({ length: 20 }, (_, i) => i + 1).map((num) => (
                                    <option key={num} value={num}>
                                        {num} {num === 1 ? 'Guest' : 'Guests'}
                                    </option>
                                ))}
                            </select>
                            {errors.partySize && (
                                <p className="text-red-500 text-sm mt-1">{errors.partySize.message}</p>
                            )}
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label className="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <Calendar size={16} />
                                    Date
                                </label>
                                <input
                                    {...register('date')}
                                    type="date"
                                    min={today}
                                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                />
                                {errors.date && (
                                    <p className="text-red-500 text-sm mt-1">{errors.date.message}</p>
                                )}
                            </div>

                            <div>
                                <label className="block text-sm font-bold text-gray-700 mb-2 flex items-center gap-2">
                                    <Clock size={16} />
                                    Time
                                </label>
                                <input
                                    {...register('time')}
                                    type="time"
                                    className="w-full px-4 py-3 rounded-xl border-2 border-gray-200 focus:border-gray-400 outline-none transition-colors"
                                />
                                {errors.time && (
                                    <p className="text-red-500 text-sm mt-1">{errors.time.message}</p>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Note */}
                    <div className="bg-amber-50 border border-amber-200 rounded-xl p-4">
                        <p className="text-sm text-amber-800">
                            <strong>Note:</strong> Please arrive 10 minutes before your reservation time.
                            If you need to cancel or modify your reservation, please contact us as soon as possible.
                        </p>
                    </div>

                    {/* Submit Button */}
                    <button
                        type="submit"
                        disabled={isSubmitting}
                        className="w-full py-4 rounded-2xl text-white font-bold text-lg flex items-center justify-center gap-2 transition-all hover:scale-105 active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
                        style={{ backgroundColor: config?.primaryColor }}
                    >
                        {isSubmitting ? (
                            <>
                                <Loader2 className="animate-spin" size={20} />
                                Creating Reservation...
                            </>
                        ) : (
                            'Confirm Reservation'
                        )}
                    </button>
                </form>
            </div>
        </div>
    );
}
