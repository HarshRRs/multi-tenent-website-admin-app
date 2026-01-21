'use client';

import { useState } from 'react';
import { Product, ModifierGroup, Modifier } from '@/types';
import { useConfigStore } from '@/store/config-store';
import { useCartStore } from '@/store/cart-store';
import { X, Check } from 'lucide-react';
import { cn } from '@/lib/utils';

interface ModifierModalProps {
    product: Product;
    onClose: () => void;
}

export default function ModifierModal({ product, onClose }: ModifierModalProps) {
    const { config } = useConfigStore();
    const { addItem } = useCartStore();
    const [selectedModifiers, setSelectedModifiers] = useState<Record<string, string[]>>({});

    const handleToggleModifier = (groupId: string, modifierId: string, min: number, max: number) => {
        const currentGroup = selectedModifiers[groupId] || [];
        const isSelected = currentGroup.includes(modifierId);

        if (isSelected) {
            setSelectedModifiers({
                ...selectedModifiers,
                [groupId]: currentGroup.filter(id => id !== modifierId)
            });
        } else {
            // Check max
            if (max === 1) {
                // Radio button behavior
                setSelectedModifiers({
                    ...selectedModifiers,
                    [groupId]: [modifierId]
                });
            } else if (currentGroup.length < max) {
                setSelectedModifiers({
                    ...selectedModifiers,
                    [groupId]: [...currentGroup, modifierId]
                });
            }
        }
    };

    const isGroupValid = (group: ModifierGroup) => {
        const count = (selectedModifiers[group.id] || []).length;
        return count >= group.minSelection && count <= group.maxSelection;
    };

    const allGroupsValid = product.modifierGroups?.every(isGroupValid) ?? true;

    const handleAddToCart = () => {
        if (!allGroupsValid) return;

        // Construct selected modifiers for the cart
        const modifiersForCart: any[] = [];
        product.modifierGroups?.forEach(group => {
            const selectedIds = selectedModifiers[group.id] || [];
            selectedIds.forEach(id => {
                const mod = group.modifiers.find(m => m.id === id);
                if (mod) {
                    modifiersForCart.push({
                        groupId: group.id,
                        groupName: group.name,
                        id: mod.id,
                        name: mod.name,
                        price: mod.price
                    });
                }
            });
        });

        addItem(product, modifiersForCart);
        onClose();
    };

    return (
        <div className="fixed inset-0 z-[70] flex items-center justify-center p-4">
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" onClick={onClose} />
            <div className="relative bg-white rounded-[2.5rem] w-full max-w-lg max-h-[90vh] overflow-hidden flex flex-col shadow-2xl animate-fade-up">
                <div className="p-8 border-b border-gray-100 flex justify-between items-center">
                    <div>
                        <h2 className="text-2xl font-black text-gray-900 line-clamp-1">{product.name}</h2>
                        <p className="text-gray-500 font-medium">Customize your selection</p>
                    </div>
                    <button onClick={onClose} className="p-2 hover:bg-gray-100 rounded-full transition-colors">
                        <X size={24} />
                    </button>
                </div>

                <div className="flex-1 overflow-y-auto p-8 space-y-10">
                    {product.modifierGroups?.map(group => (
                        <div key={group.id} className="space-y-4">
                            <div className="flex justify-between items-end">
                                <div>
                                    <h3 className="text-lg font-black text-gray-900">{group.name}</h3>
                                    <p className="text-sm text-gray-500 font-bold uppercase tracking-wider">
                                        {group.minSelection > 0 ? `Required • Select ${group.minSelection}` : `Optional • Max ${group.maxSelection}`}
                                    </p>
                                </div>
                                {!isGroupValid(group) && (
                                    <span className="text-red-500 text-xs font-bold animate-pulse">Missing Selection</span>
                                )}
                            </div>

                            <div className="grid gap-3">
                                {group.modifiers.map(modifier => {
                                    const isSelected = (selectedModifiers[group.id] || []).includes(modifier.id);
                                    return (
                                        <button
                                            key={modifier.id}
                                            onClick={() => handleToggleModifier(group.id, modifier.id, group.minSelection, group.maxSelection)}
                                            className={cn(
                                                "flex items-center justify-between p-5 rounded-2xl border-2 transition-all duration-300",
                                                isSelected
                                                    ? "bg-gray-50 shadow-sm"
                                                    : "border-gray-100 hover:border-gray-200"
                                            )}
                                            style={{ borderColor: isSelected ? config?.primaryColor : undefined }}
                                        >
                                            <div className="flex items-center gap-4">
                                                <div className={cn(
                                                    "w-6 h-6 rounded-lg border-2 flex items-center justify-center transition-all",
                                                    isSelected ? "text-white" : "border-gray-200"
                                                )} style={{ backgroundColor: isSelected ? config?.primaryColor : 'transparent', borderColor: isSelected ? config?.primaryColor : undefined }}>
                                                    {isSelected && <Check size={14} strokeWidth={4} />}
                                                </div>
                                                <span className={cn("font-bold transition-colors", isSelected ? "text-gray-900" : "text-gray-600")}>
                                                    {modifier.name}
                                                </span>
                                            </div>
                                            {modifier.price > 0 && (
                                                <span className="font-black text-gray-900">
                                                    +${modifier.price.toFixed(2)}
                                                </span>
                                            )}
                                        </button>
                                    );
                                })}
                            </div>
                        </div>
                    ))}
                </div>

                <div className="p-8 border-t border-gray-100 bg-gray-50/50">
                    <button
                        disabled={!allGroupsValid}
                        onClick={handleAddToCart}
                        className={cn(
                            "w-full py-5 rounded-2xl font-bold text-white text-lg transition-all shadow-xl active:scale-95 disabled:opacity-50 disabled:grayscale disabled:pointer-events-none",
                        )}
                        style={{
                            backgroundColor: allGroupsValid ? config?.primaryColor : '#cbd5e1',
                            boxShadow: allGroupsValid ? `0 10px 40px -10px ${config?.primaryColor}aa` : 'none'
                        }}
                    >
                        {allGroupsValid ? 'Add to Order' : 'Complete Selection'}
                    </button>
                </div>
            </div>
        </div>
    );
}
