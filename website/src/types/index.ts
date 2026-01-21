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
    images?: string[];
    isAvailable: boolean;
    categoryId: string;
    modifierGroups?: ModifierGroup[];
    reviews?: Review[];
}

export interface Review {
    id: string;
    rating: number;
    comment?: string;
    customerName: string;
    createdAt: string;
}

export interface ModifierGroup {
    id: string;
    name: string;
    minSelection: number;
    maxSelection: number;
    modifiers: Modifier[];
}

export interface Modifier {
    id: string;
    name: string;
    price: number;
}

export interface Category {
    id: string;
    name: string;
    products: Product[];
}
