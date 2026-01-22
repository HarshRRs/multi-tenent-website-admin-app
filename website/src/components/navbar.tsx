'use client';

import { useConfigStore } from '@/store/config-store';
import { useCartStore } from '@/store/cart-store';
import { Menu as MenuIcon, X, ShoppingBag, CalendarCheck, Globe } from 'lucide-react';
import { useState, useEffect } from 'react';
import { cn } from '@/lib/utils';
import CartDrawer from './cart-drawer';
import ReservationModal from './reservation-modal';
import { useTranslations, useLocale } from 'next-intl';
import { usePathname, useRouter } from '@/navigation';

export default function Navbar() {
    const t = useTranslations('Navbar');
    const locale = useLocale();
    const router = useRouter();
    const pathname = usePathname();
    const { config } = useConfigStore();
    const { getTotalItems, openCart } = useCartStore();
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);
    const [reservationOpen, setReservationOpen] = useState(false);
    const [langMenuOpen, setLangMenuOpen] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setScrolled(window.scrollY > 50);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const toggleLanguage = (newLocale: string) => {
        router.replace(pathname, { locale: newLocale });
        setLangMenuOpen(false);
    };

    const scrollToSection = (id: string) => {
        document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
        setMobileMenuOpen(false);
    };

    const cartCount = getTotalItems();

    return (
        <>
            <nav
                className={cn(
                    "fixed top-4 left-1/2 -translate-x-1/2 z-50 w-[95%] max-w-7xl rounded-[2rem] transition-all duration-500 px-6",
                    scrolled
                        ? "py-3 glass-panel shadow-2xl"
                        : "py-6 bg-transparent"
                )}
            >
                <div className="flex justify-between items-center">
                    {/* Logo */}
                    <button
                        onClick={() => scrollToSection('home')}
                        className="flex items-center gap-2 group"
                    >
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center transition-transform group-hover:rotate-12" style={{ backgroundColor: config?.primaryColor }}>
                            <span className="text-white font-black text-xl">R</span>
                        </div>
                        <span className={cn(
                            "text-2xl font-black tracking-tighter transition-colors",
                            scrolled ? "text-gray-900" : "text-white"
                        )}>
                            ROCKSTER
                        </span>
                    </button>

                    {/* Desktop Navigation */}
                    <div className={cn(
                        "hidden md:flex items-center gap-1 p-1 rounded-2xl glass-panel border-none shadow-none",
                        !scrolled && "bg-white/10"
                    )}>
                        {['home', 'menu', 'contact'].map((item) => (
                            <button
                                key={item}
                                onClick={() => scrollToSection(item)}
                                className={cn(
                                    "px-6 py-2 rounded-xl text-sm font-bold uppercase tracking-widest transition-all",
                                    scrolled
                                        ? "text-gray-500 hover:text-gray-900 hover:bg-gray-100"
                                        : "text-white/70 hover:text-white hover:bg-white/10"
                                )}
                            >
                                {t(item)}
                            </button>
                        ))}
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-3">
                        <button
                            onClick={() => setReservationOpen(true)}
                            className={cn(
                                "hidden sm:flex items-center gap-2 px-4 py-2 rounded-xl transition-all hover:scale-105 active:scale-95 font-bold backdrop-blur-md",
                                scrolled ? "bg-gray-100 text-gray-900" : "bg-black/30 text-white border border-white/20"
                            )}
                        >
                            <CalendarCheck size={20} />
                            <span className="hidden lg:inline">Reserve</span>
                        </button>

                        <button
                            onClick={openCart}
                            className={cn(
                                "p-3 rounded-xl transition-all hover:scale-105 active:scale-95 relative backdrop-blur-md",
                                scrolled ? "bg-gray-100 text-gray-900" : "bg-black/30 text-white border border-white/20"
                            )}
                        >
                            <ShoppingBag size={20} />
                            {cartCount > 0 && (
                                <span className="absolute -top-1 -right-1 w-5 h-5 rounded-full bg-red-500 text-[10px] flex items-center justify-center text-white font-bold">
                                    {cartCount}
                                </span>
                            )}
                        </button>

                        {/* Language Switcher */}
                        <div className="relative">
                            <button
                                onClick={() => setLangMenuOpen(!langMenuOpen)}
                                className={cn(
                                    "p-3 rounded-xl transition-all hover:scale-105 active:scale-95 backdrop-blur-md",
                                    scrolled ? "bg-gray-100 text-gray-900" : "bg-black/30 text-white border border-white/20"
                                )}
                            >
                                <Globe size={20} />
                            </button>
                            {langMenuOpen && (
                                <div className="absolute top-full right-0 mt-2 w-32 glass-panel rounded-2xl overflow-hidden shadow-2xl py-2">
                                    {['en', 'es'].map((l) => (
                                        <button
                                            key={l}
                                            onClick={() => toggleLanguage(l)}
                                            className={cn(
                                                "w-full px-4 py-2 text-left text-sm font-bold transition-colors",
                                                locale === l ? "bg-gray-100 text-gray-900" : "text-gray-500 hover:bg-gray-50"
                                            )}
                                        >
                                            {l === 'en' ? 'English' : 'Español'}
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>

                        <button
                            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                            className={cn(
                                "md:hidden p-3 rounded-xl backdrop-blur-md",
                                scrolled ? "bg-gray-100 text-gray-900" : "bg-black/30 text-white border border-white/20"
                            )}
                        >
                            {mobileMenuOpen ? <X size={20} /> : <MenuIcon size={20} />}
                        </button>
                    </div>
                </div>

                {/* Mobile Menu */}
                <div className={cn(
                    "md:hidden absolute top-full left-0 right-0 mt-4 overflow-hidden transition-all duration-500",
                    mobileMenuOpen ? "max-h-96 opacity-100" : "max-h-0 opacity-0 pointer-events-none"
                )}>
                    <div className="glass-panel rounded-[2rem] p-6 shadow-3xl flex flex-col gap-2">
                        {['home', 'menu', 'contact'].map((item) => (
                            <button
                                key={item}
                                onClick={() => scrollToSection(item)}
                                className="px-6 py-4 rounded-xl text-lg font-bold text-gray-900 hover:bg-gray-100 text-left capitalize"
                            >
                                {item}
                            </button>
                        ))}
                        <button
                            onClick={() => {
                                setReservationOpen(true);
                                setMobileMenuOpen(false);
                            }}
                            className="mt-4 px-6 py-4 rounded-xl text-white font-bold text-lg shadow-xl active:scale-95 flex items-center justify-center gap-2"
                            style={{ backgroundColor: config?.primaryColor }}
                        >
                            <CalendarCheck size={20} />
                            Reserve Table
                        </button>
                    </div>
                </div>
            </nav>

            <CartDrawer />
            {reservationOpen && <ReservationModal onClose={() => setReservationOpen(false)} />}
        </>
    );
}
