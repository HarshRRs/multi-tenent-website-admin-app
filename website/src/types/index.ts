export interface WebsiteConfig {
    id?: string;
    userId?: string;
    headline: string;
    subheadline: string;
    primaryColor: string;
    heroImageUrl: string;
    startButtonText: string;
    deliveryRadiusKm: number;
    createdAt?: string;
    updatedAt?: string;
}

export interface Product {
    id: string;
    name: string;
    description: string;
    price: number;
    imageUrl?: string;
    isAvailable: boolean;
    categoryId: string;
}

export interface Category {
    id: string;
    name: string;
    products: Product[];
}
