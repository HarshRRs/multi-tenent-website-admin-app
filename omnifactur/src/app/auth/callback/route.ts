import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = await createClient()
    await supabase.auth.exchangeCodeForSession(code)
    
    // Get user profile and determine role-based routing
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Check if user is accountant
      const { data: accountant } = await supabase
        .from('accountants')
        .select('id, cabinet_id, role')
        .eq('auth_user_id', user.id)
        .single()
      
      if (accountant) {
        // Redirect to Cabinet Portal
        return NextResponse.redirect(new URL('/cabinet', requestUrl.origin))
      }
      
      // Check if user is client
      const { data: client } = await supabase
        .from('clients')
        .select('id, cabinet_id')
        .eq('auth_user_id', user.id)
        .single()
      
      if (client) {
        // Redirect to Client Dashboard
        return NextResponse.redirect(new URL('/dashboard', requestUrl.origin))
      }
      
      // Default fallback
      return NextResponse.redirect(new URL('/dashboard', requestUrl.origin))
    }
  }

  // Redirect to auth page if no code
  return NextResponse.redirect(new URL('/auth', requestUrl.origin))
}
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const requestUrl = new URL(request.url)
  const code = requestUrl.searchParams.get('code')

  if (code) {
    const supabase = await createClient()
    await supabase.auth.exchangeCodeForSession(code)
    
    // Get user profile and determine role-based routing
    const { data: { user } } = await supabase.auth.getUser()
    
    if (user) {
      // Check if user is accountant
      const { data: accountant } = await supabase
        .from('accountants')
        .select('id, cabinet_id, role')
        .eq('auth_user_id', user.id)
        .single()
      
      if (accountant) {
        // Redirect to Cabinet Portal
        return NextResponse.redirect(new URL('/cabinet', requestUrl.origin))
      }
      
      // Check if user is client
      const { data: client } = await supabase
        .from('clients')
        .select('id, cabinet_id')
        .eq('auth_user_id', user.id)
        .single()
      
      if (client) {
        // Redirect to Client Dashboard
        return NextResponse.redirect(new URL('/dashboard', requestUrl.origin))
      }
      
      // Default fallback
      return NextResponse.redirect(new URL('/dashboard', requestUrl.origin))
    }
  }

  // Redirect to auth page if no code
  return NextResponse.redirect(new URL('/auth', requestUrl.origin))
}
