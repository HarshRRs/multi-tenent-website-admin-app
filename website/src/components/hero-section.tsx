'use client';

import { useConfigStore } from '@/store/config-store';
import { cn } from '@/lib/utils';
import { ChevronDown, Play, ArrowRight } from 'lucide-react';

export default function HeroSection() {
    const { config } = useConfigStore();

    if (!config) return null;

    const scrollToMenu = () => {
        document.getElementById('menu')?.scrollIntoView({ behavior: 'smooth' });
    };

    return (
        <section
            className="relative h-screen flex items-center justify-center overflow-hidden"
        >
            {/* Background with parallax-like effect (simplified for CSS) */}
            <div
                className="absolute inset-0 z-0 transition-transform duration-1000 scale-105"
                style={{
                    backgroundImage: `url(${config.heroImageUrl})`,
                    backgroundSize: 'cover',
                    backgroundPosition: 'center',
                }}
            />

            {/* Dynamic Gradient Overlay */}
            <div className="absolute inset-0 z-10 bg-gradient-to-b from-black/60 via-black/40 to-gray-50" />

            {/* Content */}
            <div className="relative z-20 text-center px-6 max-w-5xl mx-auto">
                <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass-dark text-white/90 text-sm font-medium mb-8 animate-fade-up">
                    <span className="w-2 h-2 rounded-full animate-pulse" style={{ backgroundColor: config.primaryColor }} />
                    Discover Culinary Excellence
                </div>

                <h1 className="text-6xl md:text-8xl font-black text-white mb-8 tracking-tighter leading-none animate-fade-up delay-100">
                    {config.headline.split(' ').map((word, i) => (
                        <span key={i} className="inline-block mr-4 italic last:not-italic">
                            {word}
                        </span>
                    ))}
                </h1>

                <p className="text-xl md:text-3xl text-white/80 mb-12 max-w-2xl mx-auto font-light leading-relaxed animate-fade-up delay-200">
                    {config.subheadline}
                </p>

                <div className="flex flex-col sm:flex-row items-center justify-center gap-6 animate-fade-up delay-300">
                    <button
                        onClick={scrollToMenu}
                        className="group relative px-10 py-5 rounded-2xl text-white font-bold text-xl transition-all hover:scale-105 active:scale-95 shadow-2xl"
                        style={{
                            backgroundColor: config.primaryColor,
                        }}
                    >
                        <span className="flex items-center gap-2">
                            {config.startButtonText}
                            <ArrowRight className="group-hover:translate-x-1 transition-transform" size={24} />
                        </span>
                    </button>

                    <button className="px-10 py-5 rounded-2xl glass-dark text-white font-bold text-xl transition-all hover:bg-white/20 flex items-center gap-2">
                        <Play size={24} fill="white" />
                        Watch Story
                    </button>
                </div>
            </div>

            {/* Scroll indicator with glass effect */}
            <button
                onClick={scrollToMenu}
                className="absolute bottom-12 left-1/2 -translate-x-1/2 z-20 w-12 h-12 flex items-center justify-center rounded-full glass-dark text-white animate-bounce hover:bg-white/20 transition-colors"
                aria-label="Scroll to menu"
            >
                <ChevronDown size={28} />
            </button>

            {/* Glassy Floating Stats (Optional aesthetic) */}
            <div className="absolute bottom-24 right-12 z-20 hidden xl:flex flex-col gap-4 animate-fade-up delay-500 opacity-0 group-hover:opacity-100 transition-opacity">
                <div className="p-4 rounded-2xl glass-panel flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full flex items-center justify-center text-white" style={{ backgroundColor: config.primaryColor }}>
                        <span className="font-bold">4.9</span>
                    </div>
                    <div>
                        <p className="text-xs text-gray-500 font-bold uppercase tracking-wider">Rating</p>
                        <p className="text-sm font-black text-gray-900">1.2k Reviews</p>
                    </div>
                </div>
            </div>
        </section>
    );
}
