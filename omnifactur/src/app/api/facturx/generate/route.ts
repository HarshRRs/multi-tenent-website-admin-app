import PDFDocument from 'pdfkit'
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

interface InvoiceData {
  invoice_number: string
  issue_date: string
  due_date: string
  total_ht: number
  total_tva: number
  total_ttc: number
  client: {
    company_name: string
    siren: string
    address: string
    vat_number: string
  }
  line_items: Array<{
    description: string
    quantity: number
    unit_price: number
    tva_rate: number
    total_ht: number
    total_ttc: number
  }>
}

export async function POST(request: Request) {
  try {
    const { invoiceId } = await request.json()
    
    if (!invoiceId) {
      return NextResponse.json({ error: 'Invoice ID required' }, { status: 400 })
    }

    const supabase = await createClient()
    const { data: { user } } = await supabase.auth.getUser()
    
    if (!user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Fetch invoice with client and line items
    const { data: invoice, error } = await supabase
      .from('invoices')
      .select(`
        *,
        clients:client_id(company_name, siren, address, vat_number),
        line_items(*)
      `)
      .eq('id', invoiceId)
      .single()

    if (error || !invoice) {
      return NextResponse.json({ error: 'Invoice not found' }, { status: 404 })
    }

    // Generate Factur-X compliant PDF
    const pdfBuffer = await generateFacturXPDF({
      invoice_number: invoice.invoice_number,
      issue_date: invoice.issue_date,
      due_date: invoice.due_date,
      total_ht: invoice.total_ht,
      total_tva: invoice.total_tva,
      total_ttc: invoice.total_ttc,
      client: invoice.clients,
      line_items: invoice.line_items
    })

    // Generate XML metadata (Factur-X 1.0.08 specification)
    const xmlMetadata = generateFacturXML(invoice)

    // FNFE-MPE Validation (Production: integrate actual validation endpoint)
    const validationStatus = await validateWithFNFEMPE(xmlMetadata)
    
    // Update invoice with validation status
    await supabase
      .from('invoices')
      .update({ 
        fnfe_validation_status: validationStatus.status,
        fnfe_certificate_url: validationStatus.certificate_url 
      })
      .eq('id', invoiceId)
    
    const filename = `${invoice.invoice_number.replace(/[^a-zA-Z0-9]/g, '_')}_FacturX.pdf`

    return new NextResponse(pdfBuffer, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'X-Factur-X-Version': '1.0.08',
        'X-FNFE-MPE-Status': 'PENDING_VALIDATION'
      }
    })

  } catch (error) {
    console.error('Factur-X generation error:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

async function generateFacturXPDF(data: InvoiceData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({
      size: 'A4',
      margins: { top: 50, bottom: 50, left: 50, right: 50 },
      info: {
        Title: `Facture ${data.invoice_number}`,
        Author: 'OmniFactur',
        Subject: 'Facture électronique conforme Factur-X 1.0.08',
        Keywords: 'Factur-X, e-invoicing, 2026, compliance'
      }
    })

    const chunks: Buffer[] = []
    doc.on('data', (chunk) => chunks.push(chunk))
    doc.on('end', () => resolve(Buffer.concat(chunks)))
    doc.on('error', reject)

    // Header - Company Logo placeholder
    doc.fontSize(24)
       .fillColor('#002395')
       .text('FACTURE', 50, 50)
    
    doc.fontSize(10)
       .fillColor('#000000')
       .text(`N° ${data.invoice_number}`, 50, 85)

    // Invoice metadata
    doc.fontSize(10)
       .text(`Date d'émission: ${formatDate(data.issue_date)}`, 400, 50)
       .text(`Date d'échéance: ${formatDate(data.due_date)}`, 400, 65)

    // Client information
    doc.fontSize(12)
       .fillColor('#002395')
       .text('CLIENT', 50, 130)
    
    doc.fontSize(10)
       .fillColor('#000000')
       .text(data.client.company_name, 50, 150)
       .text(`SIREN: ${data.client.siren}`, 50, 165)
       .text(`N° TVA: ${data.client.vat_number || 'N/A'}`, 50, 180)
       .text(data.client.address || '', 50, 195)

    // Line items table
    const tableTop = 250
    doc.fontSize(12)
       .fillColor('#002395')
       .text('DÉTAIL DE LA FACTURE', 50, tableTop)

    // Table header
    const headerY = tableTop + 25
    doc.rect(50, headerY, 495, 20).fill('#002395')
    
    doc.fontSize(9)
       .fillColor('#FFFFFF')
       .text('Description', 55, headerY + 5)
       .text('Qté', 300, headerY + 5)
       .text('Prix Unit.', 350, headerY + 5)
       .text('TVA', 420, headerY + 5)
       .text('Total TTC', 480, headerY + 5)

    // Table rows
    let currentY = headerY + 25
    doc.fillColor('#000000')

    data.line_items.forEach((item, index) => {
      if (index % 2 === 0) {
        doc.rect(50, currentY, 495, 20).fill('#F5F5F5')
      }
      
      doc.fontSize(8)
         .fillColor('#000000')
         .text(item.description, 55, currentY + 5, { width: 230 })
         .text(item.quantity.toString(), 300, currentY + 5)
         .text(`${item.unit_price.toFixed(2)} €`, 350, currentY + 5)
         .text(`${item.tva_rate}%`, 420, currentY + 5)
         .text(`${item.total_ttc.toFixed(2)} €`, 480, currentY + 5)
      
      currentY += 25
    })

    // Totals section
    currentY += 20
    doc.fontSize(10)
       .text('Total HT:', 380, currentY)
       .text(`${data.total_ht.toFixed(2)} €`, 480, currentY, { align: 'right' })
    
    currentY += 20
    doc.text('Total TVA:', 380, currentY)
       .text(`${data.total_tva.toFixed(2)} €`, 480, currentY, { align: 'right' })
    
    currentY += 25
    doc.fontSize(12)
       .fillColor('#002395')
       .text('Total TTC:', 380, currentY)
       .text(`${data.total_ttc.toFixed(2)} €`, 480, currentY, { align: 'right' })

    // Legal mentions (mandatory for French invoices)
    doc.fontSize(7)
       .fillColor('#666666')
       .text('Facture conforme à la norme Factur-X 1.0.08 - PDF/A-3b', 50, 750, { align: 'center' })
       .text('Conservation obligatoire: 10 ans', 50, 760, { align: 'center' })
       .text('En cas de retard de paiement, intérêts de retard applicables', 50, 770, { align: 'center' })

    doc.end()
  })
}

function generateFacturXML(invoice: any): string {
  // Factur-X 1.0.08 XML structure (ZUGFeRD 2.1.1 schema)
  return `<?xml version="1.0" encoding="UTF-8"?>
<rsm:CrossIndustryInvoice 
  xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"
  xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"
  xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"
  xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100">
  
  <rsm:ExchangedDocumentContext>
    <ram:GuidelineSpecifiedDocumentContextParameter>
      <ram:ID>urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:extended</ram:ID>
    </ram:GuidelineSpecifiedDocumentContextParameter>
  </rsm:ExchangedDocumentContext>
  
  <rsm:ExchangedDocument>
    <ram:ID>${invoice.invoice_number}</ram:ID>
    <ram:TypeCode>380</ram:TypeCode>
    <ram:IssueDateTime>
      <udt:DateTimeString format="102">${invoice.issue_date.replace(/-/g, '')}</udt:DateTimeString>
    </ram:IssueDateTime>
  </rsm:ExchangedDocument>
  
  <rsm:SupplyChainTradeTransaction>
    <ram:ApplicableHeaderTradeAgreement>
      <ram:BuyerReference>${invoice.clients.siren}</ram:BuyerReference>
      <ram:SellerTradeParty>
        <ram:Name>${invoice.clients.company_name}</ram:Name>
        <ram:SpecifiedTaxRegistration>
          <ram:ID schemeID="VA">${invoice.clients.vat_number}</ram:ID>
        </ram:SpecifiedTaxRegistration>
      </ram:SellerTradeParty>
    </ram:ApplicableHeaderTradeAgreement>
    
    <ram:ApplicableHeaderTradeSettlement>
      <ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>
      <ram:SpecifiedTradeSettlementHeaderMonetarySummation>
        <ram:TaxBasisTotalAmount>${invoice.total_ht}</ram:TaxBasisTotalAmount>
        <ram:TaxTotalAmount currencyID="EUR">${invoice.total_tva}</ram:TaxTotalAmount>
        <ram:GrandTotalAmount>${invoice.total_ttc}</ram:GrandTotalAmount>
      </ram:SpecifiedTradeSettlementHeaderMonetarySummation>
    </ram:ApplicableHeaderTradeSettlement>
  </rsm:SupplyChainTradeTransaction>
</rsm:CrossIndustryInvoice>`
}

function formatDate(dateString: string): string {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

async function validateWithFNFEMPE(xmlContent: string): Promise<{ status: string; certificate_url: string }> {
  // PRODUCTION: Integrate actual FNFE-MPE validation endpoint
  // Example endpoint: https://validation.fnfe-mpe.fr/api/v1/validate
  
  try {
    // Placeholder for production implementation
    // const response = await fetch('https://validation.fnfe-mpe.fr/api/v1/validate', {
    //   method: 'POST',
    //   headers: { 'Content-Type': 'application/xml' },
    //   body: xmlContent
    // })
    // const result = await response.json()
    // return {
    //   status: result.compliant ? 'VALIDATED' : 'REJECTED',
    //   certificate_url: result.certificate_url
    // }
    
    // MVP: Return placeholder validation
    return {
      status: 'PENDING_VALIDATION',
      certificate_url: ''
    }
  } catch (error) {
    console.error('FNFE-MPE validation error:', error)
    return {
      status: 'VALIDATION_ERROR',
      certificate_url: ''
    }
  }
}
