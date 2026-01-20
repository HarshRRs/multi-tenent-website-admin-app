'use client';

import {
    Zap,
    Leaf,
    UtensilsCrossed,
    MapPin,
    Truck,
    Star
} from 'lucide-react';
import { useConfigStore } from '@/store/config-store';

export default function FeaturesSection() {
    const { config } = useConfigStore();

    const features = [
        {
            icon: <UtensilsCrossed size={32} />,
            title: "Handcrafted Flavors",
            description: "Our chefs use legacy techniques to bring out the most exquisite tastes in every bite."
        },
        {
            icon: <Leaf size={32} />,
            title: "Farm to Table",
            description: "We partner with local farmers to ensure only the freshest, organic ingredients reach your plate."
        },
        {
            icon: <Truck size={32} />,
            title: "Swift Delivery",
            description: "Enjoy our premium experience from the comfort of your home with our optimized delivery fleet."
        }
    ];

    return (
        <section className="py-32 px-6 bg-gray-50 relative">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-24 max-w-3xl mx-auto">
                    <span className="text-sm font-bold uppercase tracking-[0.2em]" style={{ color: config?.primaryColor }}>Why Choose Us</span>
                    <h2 className="text-5xl md:text-7xl font-black text-gray-900 mt-4 tracking-tighter">The Perfection in Every Detail</h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-12">
                    {features.map((feature, i) => (
                        <div key={i} className="group p-10 rounded-[3rem] bg-white shadow-sm hover:shadow-2xl transition-all duration-500 border border-gray-100 hover:border-transparent">
                            <div
                                className="w-20 h-20 rounded-[1.5rem] flex items-center justify-center mb-8 transition-transform group-hover:rotate-6 group-hover:scale-110"
                                style={{ backgroundColor: `${config?.primaryColor}15`, color: config?.primaryColor }}
                            >
                                {feature.icon}
                            </div>
                            <h3 className="text-3xl font-black text-gray-900 mb-4">{feature.title}</h3>
                            <p className="text-gray-500 text-lg font-medium leading-relaxed">
                                {feature.description}
                            </p>
                        </div>
                    ))}
                </div>

                {/* Statistics Bar */}
                <div className="mt-32 grid grid-cols-2 lg:grid-cols-4 gap-8 p-12 rounded-[3.5rem] glass-panel border-none">
                    {[
                        { label: "Happy Clients", value: "25k+" },
                        { label: "Dishes Served", value: "100k+" },
                        { label: "Expert Chefs", value: "12" },
                        { label: "Years Experience", value: "15" }
                    ].map((stat, i) => (
                        <div key={i} className="text-center">
                            <p className="text-4xl font-black mb-2" style={{ color: config?.primaryColor }}>{stat.value}</p>
                            <p className="text-gray-500 font-bold uppercase tracking-wider text-xs">{stat.label}</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}
