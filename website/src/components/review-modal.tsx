'use client';

import { useState } from 'react';
import { X, Star, Send, Loader2 } from 'lucide-react';
import { useConfigStore } from '@/store/config-store';
import { useRestaurant } from '@/contexts/restaurant-context';
import apiClient from '@/lib/api-client';

interface Review {
    id: string;
    rating: number;
    comment?: string;
    customerName: string;
    createdAt: string;
}

interface Product {
    id: string;
    name: string;
    reviews?: Review[];
}

export default function ReviewModal({ product, onClose }: { product: Product, onClose: () => void }) {
    const { config } = useConfigStore();
    const { restaurant } = useRestaurant();
    const [rating, setRating] = useState(5);
    const [comment, setComment] = useState('');
    const [name, setName] = useState('');
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [submitted, setSubmitted] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!restaurant?.id || !name || !rating) return;

        setIsSubmitting(true);
        try {
            await apiClient.post('/reviews/submit', {
                rating,
                comment,
                customerName: name,
                productId: product.id,
                restaurantId: restaurant.id
            });
            setSubmitted(true);
        } catch (error) {
            console.error('Review submission failed:', error);
            alert('Failed to submit review. Please try again.');
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="fixed inset-0 z-[70] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />

            <div className="relative bg-white rounded-[2.5rem] w-full max-w-lg overflow-hidden shadow-2xl animate-fade-up">
                <button onClick={onClose} className="absolute top-6 right-6 p-2 hover:bg-gray-100 rounded-full transition-colors z-10">
                    <X size={24} />
                </button>

                <div className="p-8 md:p-12">
                    <h2 className="text-3xl font-black text-gray-900 mb-2">Reviews</h2>
                    <p className="text-gray-500 font-medium mb-8">What customers say about {product.name}</p>

                    <div className="space-y-6 max-h-[40vh] overflow-y-auto no-scrollbar mb-8">
                        {product.reviews && product.reviews.length > 0 ? (
                            product.reviews.map((review) => (
                                <div key={review.id} className="p-4 bg-gray-50 rounded-2xl">
                                    <div className="flex justify-between items-center mb-2">
                                        <div className="flex gap-1">
                                            {[...Array(5)].map((_, i) => (
                                                <Star key={i} size={14} className={i < review.rating ? "fill-amber-400 text-amber-400" : "text-gray-300"} />
                                            ))}
                                        </div>
                                        <span className="text-[10px] uppercase tracking-widest text-gray-400 font-bold">
                                            {new Date(review.createdAt).toLocaleDateString()}
                                        </span>
                                    </div>
                                    <p className="text-sm font-bold text-gray-900 mb-1">{review.customerName}</p>
                                    <p className="text-sm text-gray-600 italic">"{review.comment}"</p>
                                </div>
                            ))
                        ) : (
                            <p className="text-center py-8 text-gray-400 font-medium">No reviews yet. Be the first to review!</p>
                        )}
                    </div>

                    {!submitted ? (
                        <form onSubmit={handleSubmit} className="space-y-4 pt-6 border-t border-gray-100">
                            <h3 className="font-bold text-gray-900">Write a Review</h3>
                            <div className="flex justify-center gap-2 mb-4">
                                {[1, 2, 3, 4, 5].map((s) => (
                                    <button
                                        key={s}
                                        type="button"
                                        onClick={() => setRating(s)}
                                        className="transition-transform active:scale-90"
                                    >
                                        <Star size={32} className={s <= rating ? "fill-amber-400 text-amber-400" : "text-gray-200"} />
                                    </button>
                                ))}
                            </div>

                            <input
                                placeholder="Your Name"
                                value={name}
                                onChange={(e) => setName(e.target.value)}
                                required
                                className="w-full px-5 py-3 rounded-xl border-2 border-gray-100 focus:border-gray-200 outline-none transition-all text-sm"
                            />

                            <textarea
                                placeholder="Share your experience..."
                                value={comment}
                                onChange={(e) => setComment(e.target.value)}
                                rows={3}
                                className="w-full px-5 py-3 rounded-xl border-2 border-gray-100 focus:border-gray-200 outline-none transition-all text-sm resize-none"
                            />

                            <button
                                type="submit"
                                disabled={isSubmitting}
                                className="w-full py-4 rounded-xl text-white font-bold flex items-center justify-center gap-2 transition-all hover:opacity-90 active:scale-95 disabled:opacity-50"
                                style={{ backgroundColor: config?.primaryColor }}
                            >
                                {isSubmitting ? (
                                    <Loader2 className="animate-spin" size={20} />
                                ) : (
                                    <><Send size={18} /> Submit Review</>
                                )}
                            </button>
                        </form>
                    ) : (
                        <div className="text-center py-6 bg-green-50 rounded-2xl animate-fade-in">
                            <h3 className="text-green-800 font-bold mb-1">Thank you!</h3>
                            <p className="text-green-600 text-sm">Your review has been submitted for approval.</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
