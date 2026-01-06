import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const { clientIds } = await request.json()
    
    if (!clientIds || clientIds.length === 0) {
      return NextResponse.json({ error: 'No clients selected' }, { status: 400 })
    }

    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Get accountant's cabinet_id for RLS enforcement
    const { data: accountant } = await supabase
      .from('accountants')
      .select('cabinet_id')
      .eq('auth_user_id', user.id)
      .single()

    if (!accountant) {
      return NextResponse.json({ error: 'Accountant not found' }, { status: 403 })
    }

    // Fetch invoices with line items for selected clients (RLS enforced)
    const { data: invoices, error } = await supabase
      .from('invoices')
      .select(`
        *,
        line_items(*),
        clients:client_id(siren, company_name)
      `)
      .in('client_id', clientIds)
      .eq('cabinet_id', accountant.cabinet_id)
      .order('issue_date', { ascending: true })

    if (error) {
      console.error('Error fetching invoices:', error)
      return NextResponse.json({ error: 'Failed to fetch invoices' }, { status: 500 })
    }

    // Generate FEC file content
    const fecLines = generateFECContent(invoices || [])
    
    // Validate FEC format
    const validation = validateFECFormat(fecLines)
    if (!validation.valid) {
      return NextResponse.json({ 
        error: 'FEC validation failed', 
        details: validation.errors 
      }, { status: 400 })
    }

    // Return as downloadable file
    const fecContent = fecLines.join('\n')
    const filename = `${accountant.cabinet_id.substring(0, 9)}FEC${new Date().toISOString().split('T')[0].replace(/-/g, '')}.txt`

    return new NextResponse(fecContent, {
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'X-Validation-Status': validation.valid ? 'PASS' : 'FAIL'
      }
    })

  } catch (error) {
    console.error('FEC export error:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

function generateFECContent(invoices: any[]): string[] {
  const lines: string[] = []
  
  // FEC Header (required by French tax authorities)
  lines.push('JournalCode|JournalLib|EcritureNum|EcritureDate|CompteNum|CompteLib|CompAuxNum|CompAuxLib|PieceRef|PieceDate|EcritureLib|Debit|Credit|EcritureLet|DateLet|ValidDate|Montantdevise|Idevise')

  invoices.forEach((invoice: any) => {
    const issueDate = formatDate(invoice.issue_date)
    const client = invoice.clients
    const clientAccount = `411${client.siren}` // French chart of accounts: 411 = customer receivables

    // Debit entry: Customer account (411)
    lines.push([
      'VE', // Journal code for sales (Ventes)
      'Ventes',
      invoice.invoice_number,
      issueDate,
      clientAccount,
      client.company_name,
      client.siren,
      client.company_name,
      invoice.invoice_number,
      issueDate,
      `Facture ${invoice.invoice_number}`,
      formatAmount(invoice.total_ttc), // Debit
      '0,00', // Credit
      '', // EcritureLet
      '', // DateLet
      issueDate,
      '', // Montantdevise
      '' // Idevise
    ].join('|'))

    // Credit entry: Revenue account (707 - Sales of goods/services)
    lines.push([
      'VE',
      'Ventes',
      invoice.invoice_number,
      issueDate,
      '707000', // Revenue account
      'Ventes de marchandises',
      '',
      '',
      invoice.invoice_number,
      issueDate,
      `Facture ${invoice.invoice_number} - HT`,
      '0,00', // Debit
      formatAmount(invoice.total_ht), // Credit
      '',
      '',
      issueDate,
      '',
      ''
    ].join('|'))

    // Credit entry: TVA collected account (44571)
    lines.push([
      'VE',
      'Ventes',
      invoice.invoice_number,
      issueDate,
      '44571000', // TVA collected account
      'TVA collectée',
      '',
      '',
      invoice.invoice_number,
      issueDate,
      `Facture ${invoice.invoice_number} - TVA`,
      '0,00', // Debit
      formatAmount(invoice.total_tva), // Credit
      '',
      '',
      issueDate,
      '',
      ''
    ].join('|'))
  })

  return lines
}

function formatDate(dateString: string): string {
  // Convert ISO date to YYYYMMDD format
  return dateString.replace(/-/g, '')
}

function formatAmount(amount: number): string {
  // French format: comma as decimal separator
  return amount.toFixed(2).replace('.', ',')
}

function validateFECFormat(lines: string[]): { valid: boolean; errors: string[] } {
  const errors: string[] = []
  
  if (lines.length < 2) {
    errors.push('FEC file must contain at least header and one data line')
  }

  // Validate debit/credit balance
  let totalDebit = 0
  let totalCredit = 0

  lines.slice(1).forEach((line, index) => {
    const fields = line.split('|')
    if (fields.length !== 18) {
      errors.push(`Line ${index + 2}: Invalid number of fields (expected 18, got ${fields.length})`)
    }

    const debit = parseFloat(fields[11].replace(',', '.'))
    const credit = parseFloat(fields[12].replace(',', '.'))
    
    totalDebit += debit
    totalCredit += credit
  })

  // Check if debits equal credits (within 0.01 cent tolerance)
  if (Math.abs(totalDebit - totalCredit) > 0.01) {
    errors.push(`Debit/Credit imbalance: Debits=${totalDebit.toFixed(2)}, Credits=${totalCredit.toFixed(2)}`)
  }

  return {
    valid: errors.length === 0,
    errors
  }
}
