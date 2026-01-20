'use client';

import { useEffect, useState } from 'react';
import { Category } from '@/types';
import apiClient from '@/lib/api-client';
import { useConfigStore } from '@/store/config-store';
import { useCartStore } from '@/store/cart-store';
import { useRestaurant } from '@/contexts/restaurant-context';
import { ShoppingCart, Star, Plus, ArrowRight } from 'lucide-react';
import { cn } from '@/lib/utils';

export default function MenuSection() {
    const [categories, setCategories] = useState<Category[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
    const { config } = useConfigStore();
    const { addItem } = useCartStore();
    const { restaurant } = useRestaurant();

    useEffect(() => {
        fetchMenu();
    }, [restaurant]);

    const fetchMenu = async () => {
        if (!restaurant?.id) return;

        try {
            const response = await apiClient.get(`/public/menu/${restaurant.id}`);
            setCategories(response.data);
            if (response.data.length > 0) {
                setSelectedCategory(response.data[0].id);
            }
        } catch (error) {
            console.error('Failed to fetch menu:', error);
        } finally {
            setLoading(false);
        }
    };

    const selectedCategoryData = categories.find((c) => c.id === selectedCategory);

    if (loading) {
        return (
            <section id="menu" className="py-32 px-6 bg-white">
                <div className="max-w-7xl mx-auto text-center">
                    <div className="w-16 h-16 border-4 border-t-transparent animate-spin mx-auto rounded-full mb-4" style={{ borderColor: `${config?.primaryColor}44`, borderTopColor: config?.primaryColor }} />
                    <p className="text-gray-400 font-medium">Preparing our signature recipes...</p>
                </div>
            </section>
        );
    }

    return (
        <section id="menu" className="py-32 px-6 bg-white relative overflow-hidden">
            {/* Background Decorative Element */}
            <div className="absolute top-0 right-0 -translate-y-1/2 translate-x-1/2 w-96 h-96 rounded-full blur-[120px] opacity-10" style={{ backgroundColor: config?.primaryColor }} />

            <div className="max-w-7xl mx-auto relative z-10">
                <div className="flex flex-col md:flex-row md:items-end justify-between mb-16 gap-8">
                    <div>
                        <span className="text-sm font-bold uppercase tracking-[0.2em]" style={{ color: config?.primaryColor }}>Delicious Selections</span>
                        <h2 className="text-5xl md:text-7xl font-black text-gray-900 mt-2 tracking-tighter">Our Menu</h2>
                    </div>
                    <p className="max-w-md text-xl text-gray-500 font-medium leading-relaxed">
                        Every dish is a masterpiece, crafted with passion and the finest seasonal ingredients.
                    </p>
                </div>

                {/* Category Tabs - Premium Scrollable */}
                <div className="flex items-center gap-4 overflow-x-auto pb-8 mb-12 no-scrollbar">
                    {categories.map((category) => (
                        <button
                            key={category.id}
                            onClick={() => setSelectedCategory(category.id)}
                            className={cn(
                                "whitespace-nowrap px-8 py-4 rounded-2xl font-bold transition-all duration-300 active:scale-95",
                                selectedCategory === category.id
                                    ? "text-white shadow-xl shadow-opacity-20 translate-y-[-2px]"
                                    : "bg-gray-100 text-gray-500 hover:bg-gray-200"
                            )}
                            style={{
                                backgroundColor:
                                    selectedCategory === category.id ? config?.primaryColor : undefined,
                                boxShadow: selectedCategory === category.id ? `0 10px 30px -10px ${config?.primaryColor}88` : undefined
                            }}
                        >
                            {category.name}
                        </button>
                    ))}
                </div>

                {/* Products Grid - Staggered Cards */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">
                    {selectedCategoryData?.products.map((product, idx) => (
                        <div
                            key={product.id}
                            className="group bg-gray-50 rounded-[2.5rem] p-4 premium-card animate-fade-up"
                            style={{ animationDelay: `${idx * 100}ms` }}
                        >
                            <div className="relative h-72 rounded-[2rem] overflow-hidden mb-6">
                                {product.imageUrl ? (
                                    <img
                                        src={product.imageUrl}
                                        alt={product.name}
                                        className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
                                    />
                                ) : (
                                    <div className="w-full h-full bg-gray-200 flex items-center justify-center">
                                        <Star className="text-gray-300" size={48} />
                                    </div>
                                )}

                                {/* Float Badge */}
                                <div className="absolute top-4 right-4 glass-dark px-3 py-1 rounded-full text-white text-xs font-bold uppercase tracking-widest">
                                    Popular
                                </div>
                            </div>

                            <div className="px-4 pb-4">
                                <div className="flex justify-between items-start mb-3">
                                    <h3 className="text-2xl font-black text-gray-900 leading-tight group-hover:text-primary transition-colors">{product.name}</h3>
                                    <span className="text-2xl font-black" style={{ color: config?.primaryColor }}>
                                        ${product.price.toFixed(2)}
                                    </span>
                                </div>

                                <p className="text-gray-500 font-medium mb-8 line-clamp-2 h-12">
                                    {product.description}
                                </p>

                                <div className="flex items-center gap-2">
                                    <button
                                        onClick={() => {
                                            addItem(product);
                                            // Show simple feedback
                                            const btn = event?.currentTarget as HTMLButtonElement;
                                            if (btn) {
                                                const original = btn.textContent;
                                                btn.textContent = '✓ Added!';
                                                setTimeout(() => {
                                                    btn.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-plus"><path d="M5 12h14"/><path d="M12 5v14"/></svg>Add to Order';
                                                }, 1500);
                                            }
                                        }}
                                        className="flex-1 py-4 rounded-2xl font-bold text-white transition-all flex items-center justify-center gap-2 active:scale-95 hover:opacity-90"
                                        style={{ backgroundColor: config?.primaryColor }}
                                    >
                                        <Plus size={20} />
                                        Add to Order
                                    </button>
                                    <button className="p-4 rounded-2xl bg-white border border-gray-200 text-gray-400 hover:text-red-500 hover:border-red-500 transition-all">
                                        <Star size={20} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Call to action footer */}
                <div className="mt-24 p-12 rounded-[3.5rem] glass-panel flex flex-col items-center text-center animate-fade-up">
                    <h3 className="text-4xl font-black text-gray-900 mb-6">Hungry yet?</h3>
                    <p className="text-gray-500 mb-10 text-xl font-medium max-w-lg">
                        Don't wait. Experience the flavors everyone is talking about from the comfort of your home.
                    </p>
                    <button
                        className="px-12 py-5 rounded-2xl text-white font-bold text-xl flex items-center gap-3 transition-transform hover:scale-105"
                        style={{ backgroundColor: config?.primaryColor }}
                    >
                        Order Your Favorites Now
                        <ArrowRight size={24} />
                    </button>
                </div>
            </div>
        </section>
    );
}
