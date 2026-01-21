import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import createMiddleware from 'next-intl/middleware';
import { locales, localePrefix } from './navigation';

const intlMiddleware = createMiddleware({
    locales,
    localePrefix,
    defaultLocale: 'en'
});

export function middleware(request: NextRequest) {
    const hostname = request.headers.get('host') || '';

    // Extract subdomain
    const subdomain = extractSubdomain(hostname);

    // Run next-intl middleware first
    const response = intlMiddleware(request);

    if (subdomain) {
        response.headers.set('x-subdomain', subdomain);
        // Also set as cookie for client-side access
        response.cookies.set('subdomain', subdomain, {
            path: '/',
            sameSite: 'lax',
        });
    }

    return response;
}

function extractSubdomain(hostname: string): string | null {
    // Remove port if present
    const host = hostname.split(':')[0];

    // For localhost or IP addresses, return null
    if (host === 'localhost' || /^\d+\.\d+\.\d+\.\d+$/.test(host)) {
        return null;
    }

    // Split by dots
    const parts = host.split('.');

    // For cosmosadmin.com or www.cosmosadmin.com, no subdomain
    if (parts.length <= 2 || parts[0] === 'www') {
        return null;
    }

    // Return the subdomain (first part)
    return parts[0];
}

export const config = {
    matcher: [
        /*
         * Match all request paths except for the ones starting with:
         * - api (API routes)
         * - _next/static (static files)
         * - _next/image (image optimization files)
         * - favicon.ico (favicon file)
         */
        '/((?!api|_next/static|_next/image|favicon.ico).*)',
    ],
};
