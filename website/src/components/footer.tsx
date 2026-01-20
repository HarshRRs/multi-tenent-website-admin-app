'use client';

import { useConfigStore } from '@/store/config-store';
import { MapPin, Phone, Clock, Mail } from 'lucide-react';

export default function Footer() {
    const { config } = useConfigStore();

    return (
        <footer id="contact" className="bg-gray-900 text-white py-16">
            <div className="max-w-7xl mx-auto px-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-12 mb-12">
                    {/* About */}
                    <div>
                        <h3 className="text-2xl font-bold mb-4" style={{ color: config?.primaryColor }}>
                            About Us
                        </h3>
                        <p className="text-gray-400">
                            Experience culinary excellence with fresh ingredients and bold flavors. We're
                            committed to delivering an unforgettable dining experience.
                        </p>
                    </div>

                    {/* Contact Info */}
                    <div>
                        <h3 className="text-2xl font-bold mb-4" style={{ color: config?.primaryColor }}>
                            Contact
                        </h3>
                        <div className="space-y-3 text-gray-400">
                            <div className="flex items-center gap-3">
                                <MapPin size={20} />
                                <span>123 Restaurant St, Food City</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Phone size={20} />
                                <span>+1 (555) 123-4567</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Mail size={20} />
                                <span>hello@restaurant.com</span>
                            </div>
                            <div className="flex items-center gap-3">
                                <Clock size={20} />
                                <span>Open Daily: 11 AM - 10 PM</span>
                            </div>
                        </div>
                    </div>

                    {/* Hours */}
                    <div>
                        <h3 className="text-2xl font-bold mb-4" style={{ color: config?.primaryColor }}>
                            Opening Hours
                        </h3>
                        <div className="space-y-2 text-gray-400">
                            <div className="flex justify-between">
                                <span>Monday - Friday</span>
                                <span>11:00 AM - 10:00 PM</span>
                            </div>
                            <div className="flex justify-between">
                                <span>Saturday - Sunday</span>
                                <span>10:00 AM - 11:00 PM</span>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Bottom Bar */}
                <div className="border-t border-gray-800 pt-8 text-center text-gray-400">
                    <p>&copy; 2026 Restaurant. All rights reserved.</p>
                </div>
            </div>
        </footer>
    );
}
