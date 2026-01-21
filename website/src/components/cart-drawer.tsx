'use client';

import { useCartStore } from '@/store/cart-store';
import { X, Plus, Minus, ShoppingBag, Trash2 } from 'lucide-react';
import { useState } from 'react';
import CheckoutModal from './checkout-modal';
import { useConfigStore } from '@/store/config-store';

export default function CartDrawer() {
    const { items, isOpen, closeCart, updateQuantity, removeItem, getTotal, getTotalItems } = useCartStore();
    const { config } = useConfigStore();
    const [checkoutOpen, setCheckoutOpen] = useState(false);

    if (!isOpen) return null;

    const handleCheckout = () => {
        if (items.length === 0) return;
        setCheckoutOpen(true);
    };

    return (
        <>
            <div className="fixed inset-0 bg-black/60 z-50 animate-fade-in" onClick={closeCart} />

            <div className="fixed right-0 top-0 bottom-0 w-full max-w-md bg-white z-50 shadow-2xl flex flex-col animate-slide-in-right">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-gray-200">
                    <div className="flex items-center gap-3">
                        <ShoppingBag size={24} style={{ color: config?.primaryColor }} />
                        <h2 className="text-2xl font-bold text-gray-900">Your Cart</h2>
                        <span className="px-2 py-1 rounded-full text-xs font-bold text-white" style={{ backgroundColor: config?.primaryColor }}>
                            {getTotalItems()}
                        </span>
                    </div>
                    <button
                        onClick={closeCart}
                        className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                    >
                        <X size={24} />
                    </button>
                </div>

                {/* Cart Items */}
                {items.length === 0 ? (
                    <div className="flex-1 flex flex-col items-center justify-center p-8 text-center">
                        <ShoppingBag size={64} className="text-gray-300 mb-4" />
                        <p className="text-gray-500 font-medium mb-2">Your cart is empty</p>
                        <p className="text-gray-400 text-sm">Add some delicious items to get started!</p>
                    </div>
                ) : (
                    <div className="flex-1 overflow-y-auto p-6 space-y-4">
                        {items.map((item) => (
                            <div key={item.id} className="flex gap-4 bg-gray-50 p-4 rounded-2xl">
                                {item.imageUrl && (
                                    <div className="w-20 h-20 rounded-xl overflow-hidden flex-shrink-0">
                                        <img
                                            src={item.imageUrl}
                                            alt={item.name}
                                            className="w-full h-full object-cover"
                                        />
                                    </div>
                                )}

                                <div className="flex-1 min-w-0">
                                    <h3 className="font-bold text-gray-900 truncate">{item.name}</h3>
                                    {item.selectedModifiers && item.selectedModifiers.length > 0 && (
                                        <div className="flex flex-wrap gap-1 mt-1">
                                            {item.selectedModifiers.map((mod, idx) => (
                                                <span key={idx} className="text-[10px] bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded-md font-bold">
                                                    {mod.name}
                                                </span>
                                            ))}
                                        </div>
                                    )}
                                    <p className="text-sm font-bold mt-1" style={{ color: config?.primaryColor }}>
                                        ${(item.price + (item.selectedModifiers?.reduce((sum, mod) => sum + mod.price, 0) || 0)).toFixed(2)}
                                    </p>

                                    <div className="flex items-center gap-3 mt-3">
                                        <button
                                            onClick={() => updateQuantity(item.id, item.quantity - 1, item.modifiersKey)}
                                            className="p-1.5 rounded-lg hover:bg-white transition-colors"
                                        >
                                            <Minus size={16} />
                                        </button>
                                        <span className="font-bold text-gray-900 min-w-[24px] text-center">{item.quantity}</span>
                                        <button
                                            onClick={() => updateQuantity(item.id, item.quantity + 1, item.modifiersKey)}
                                            className="p-1.5 rounded-lg hover:bg-white transition-colors"
                                        >
                                            <Plus size={16} />
                                        </button>
                                    </div>
                                </div>

                                <button
                                    onClick={() => removeItem(item.id, item.modifiersKey)}
                                    className="p-2 hover:bg-red-50 hover:text-red-600 rounded-lg transition-colors self-start"
                                >
                                    <Trash2 size={20} />
                                </button>
                            </div>
                        ))}
                    </div>
                )}

                {/* Footer */}
                {items.length > 0 && (
                    <div className="border-t border-gray-200 p-6 space-y-4">
                        <div className="flex justify-between items-center">
                            <span className="text-gray-600 font-medium">Total</span>
                            <span className="text-3xl font-black" style={{ color: config?.primaryColor }}>
                                ${getTotal().toFixed(2)}
                            </span>
                        </div>

                        <button
                            onClick={handleCheckout}
                            className="w-full py-4 rounded-2xl text-white font-bold text-lg transition-all hover:scale-105 active:scale-95"
                            style={{ backgroundColor: config?.primaryColor }}
                        >
                            Proceed to Checkout
                        </button>
                    </div>
                )}
            </div>

            {checkoutOpen && <CheckoutModal onClose={() => setCheckoutOpen(false)} />}
        </>
    );
}
