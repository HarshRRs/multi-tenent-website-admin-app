'use client';

import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import apiClient from '@/lib/api-client';

interface Restaurant {
    id: string;
    name: string;
    slug: string;
}

interface RestaurantContextType {
    restaurant: Restaurant | null;
    loading: boolean;
    error: string | null;
}

const RestaurantContext = createContext<RestaurantContextType>({
    restaurant: null,
    loading: true,
    error: null,
});

export function useRestaurant() {
    return useContext(RestaurantContext);
}

interface RestaurantProviderProps {
    children: ReactNode;
}

export function RestaurantProvider({ children }: RestaurantProviderProps) {
    const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const loadRestaurant = async () => {
            try {
                // Try to get subdomain from cookie (set by middleware)
                const subdomain = getSubdomainFromCookie();

                if (!subdomain) {
                    // Fallback to env variable for local development
                    const restaurantId = process.env.NEXT_PUBLIC_RESTAURANT_ID;
                    if (restaurantId) {
                        // For local dev, create a mock restaurant object
                        setRestaurant({
                            id: restaurantId,
                            name: 'Local Restaurant',
                            slug: 'local'
                        });
                    } else {
                        setError('No restaurant configured');
                    }
                    setLoading(false);
                    return;
                }

                // Resolve subdomain to restaurant
                const response = await apiClient.get(`/public/resolve/${subdomain}`);
                setRestaurant({
                    id: response.data.restaurantId,
                    name: response.data.name,
                    slug: response.data.slug,
                });
            } catch (err: any) {
                console.error('Failed to load restaurant:', err);
                setError(err.response?.data?.message || 'Failed to load restaurant');
            } finally {
                setLoading(false);
            }
        };

        loadRestaurant();
    }, []);

    return (
        <RestaurantContext.Provider value={{ restaurant, loading, error }}>
            {children}
        </RestaurantContext.Provider>
    );
}

function getSubdomainFromCookie(): string | null {
    if (typeof document === 'undefined') return null;

    const cookies = document.cookie.split(';');
    const subdomainCookie = cookies.find(c => c.trim().startsWith('subdomain='));

    if (!subdomainCookie) return null;

    return subdomainCookie.split('=')[1];
}
