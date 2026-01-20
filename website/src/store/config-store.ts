import { create } from 'zustand';
import { WebsiteConfig } from '@/types';

interface ConfigStore {
    config: WebsiteConfig | null;
    isLoading: boolean;
    error: string | null;
    setConfig: (config: WebsiteConfig) => void;
    setLoading: (loading: boolean) => void;
    setError: (error: string | null) => void;
}

export const useConfigStore = create<ConfigStore>((set) => ({
    config: null,
    isLoading: true,
    error: null,
    setConfig: (config) => set({ config, isLoading: false, error: null }),
    setLoading: (isLoading) => set({ isLoading }),
    setError: (error) => set({ error, isLoading: false }),
}));
