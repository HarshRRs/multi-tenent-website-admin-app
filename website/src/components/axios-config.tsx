'use client';

import { useEffect } from 'react';
import { useLocale } from 'next-intl';
import apiClient from '@/lib/api-client';

export default function AxiosConfig() {
    const locale = useLocale();

    useEffect(() => {
        // Update the default specific header for all requests
        apiClient.defaults.headers.common['Accept-Language'] = locale;
    }, [locale]);

    return null;
}
