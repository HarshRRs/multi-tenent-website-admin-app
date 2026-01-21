'use client';

import HeroSection from '@/components/hero-section';
import MenuSection from '@/components/menu-section';
import FeaturesSection from '@/components/features-section';
import Footer from '@/components/footer';
import Navbar from '@/components/navbar';
import { useConfigStore } from '@/store/config-store';
import { useRestaurant } from '@/contexts/restaurant-context';
import apiClient from '@/lib/api-client';
import { useEffect } from 'react';

export default function HomePage() {
  const { setConfig } = useConfigStore();
  const { restaurant, loading, error } = useRestaurant();

  useEffect(() => {
    const fetchConfig = async () => {
      if (!restaurant?.id) return;

      try {
        const response = await apiClient.get(`/public/config/${restaurant.id}`);
        setConfig(response.data);
      } catch (error) {
        console.error('Failed to fetch config:', error);
        // Fallback configuration
        setConfig({
          primaryColor: '#667eea',
          headline: 'Delicious Food Delivered',
          subheadline: 'Experience the finest cuisine',
          heroImageUrl: '',
          startButtonText: 'Order Now',
          deliveryRadiusKm: 10,
        });
      }
    };

    fetchConfig();
  }, [restaurant, setConfig]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-4 border-primary border-t-transparent mx-auto mb-4"></div>
          <p className="text-gray-600 font-medium">Loading restaurant...</p>
        </div>
      </div>
    );
  }

  if (error || !restaurant) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 bg-gray-50">
        <div className="text-center max-w-md">
          <h1 className="text-4xl font-black text-gray-900 mb-4">Restaurant Not Found</h1>
          <p className="text-gray-600 mb-6">{error || 'Unable to load restaurant data'}</p>
          <p className="text-sm text-gray-500">
            If you&apos;re the restaurant owner, please set up your subdomain in the Admin App.
          </p>
        </div>
      </div>
    );
  }

  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <HeroSection />
      <MenuSection />
      <FeaturesSection />
      <Footer />
    </main>
  );
}
