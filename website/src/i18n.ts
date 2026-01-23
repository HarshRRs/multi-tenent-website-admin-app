import { notFound } from 'next/navigation';
import { getRequestConfig } from 'next-intl/server';

// Can be imported from a shared config
import { routing } from './navigation';

export default getRequestConfig(async ({ requestLocale }) => {
    // Validate that the incoming `locale` parameter is valid
    const locale = await requestLocale;
    if (!locale || !routing.locales.includes(locale as any)) notFound();

    return {
        locale: locale as string,
        messages: (await import(`../messages/${locale}.json`)).default
    };
});
