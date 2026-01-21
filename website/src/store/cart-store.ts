import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { Product } from '@/types';

export interface CartItem extends Product {
    quantity: number;
    selectedModifiers?: {
        groupId: string;
        groupName: string;
        id: string;
        name: string;
        price: number;
    }[];
    modifiersKey?: string;
}

interface CartStore {
    items: CartItem[];
    isOpen: boolean;
    addItem: (product: Product, selectedModifiers?: CartItem['selectedModifiers']) => void;
    removeItem: (productId: string, modifiersKey?: string) => void;
    updateQuantity: (productId: string, quantity: number, modifiersKey?: string) => void;
    clearCart: () => void;
    getTotal: () => number;
    getTotalItems: () => number;
    openCart: () => void;
    closeCart: () => void;
    toggleCart: () => void;
}

export const useCartStore = create<CartStore>()(
    persist(
        (set, get) => ({
            items: [],
            isOpen: false,

            addItem: (product, selectedModifiers) => {
                const { items } = get();
                const modifiersKey = selectedModifiers
                    ? selectedModifiers.map(m => m.id).sort().join(',')
                    : '';

                const existingItem = items.find(
                    (item) => item.id === product.id && (item.modifiersKey || '') === modifiersKey
                );

                if (existingItem) {
                    set({
                        items: items.map((item) =>
                            (item.id === product.id && (item.modifiersKey || '') === modifiersKey)
                                ? { ...item, quantity: item.quantity + 1 }
                                : item
                        ),
                    });
                } else {
                    set({
                        items: [...items, {
                            ...product,
                            quantity: 1,
                            selectedModifiers,
                            modifiersKey
                        }],
                    });
                }
            },

            removeItem: (productId, modifiersKey) => {
                set({
                    items: get().items.filter((item) =>
                        !(item.id === productId && (item.modifiersKey || '') === (modifiersKey || ''))
                    ),
                });
            },

            updateQuantity: (productId, quantity, modifiersKey) => {
                if (quantity <= 0) {
                    get().removeItem(productId, modifiersKey);
                    return;
                }

                set({
                    items: get().items.map((item) =>
                        (item.id === productId && (item.modifiersKey || '') === (modifiersKey || ''))
                            ? { ...item, quantity }
                            : item
                    ),
                });
            },

            clearCart: () => {
                set({ items: [] });
            },

            getTotal: () => {
                return get().items.reduce((total, item) => {
                    const modifiersTotal = item.selectedModifiers?.reduce((sum, mod) => sum + mod.price, 0) || 0;
                    return total + (item.price + modifiersTotal) * item.quantity;
                }, 0);
            },

            getTotalItems: () => {
                return get().items.reduce((total, item) => total + item.quantity, 0);
            },

            openCart: () => set({ isOpen: true }),
            closeCart: () => set({ isOpen: false }),
            toggleCart: () => set((state) => ({ isOpen: !state.isOpen })),
        }),
        {
            name: 'cart-storage',
        }
    )
);
