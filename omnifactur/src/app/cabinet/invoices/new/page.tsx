'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Plus, Trash2, Save, Calculator, Mic, FileText } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface LineItem {
  id: string
  description: string
  quantity: number
  unit_price: number
  tva_rate: number
  total_ht: number
  total_ttc: number
}

interface InvoiceHeader {
  client_id: string
  invoice_number: string
  issue_date: string
  due_date: string
}

const TVA_RATES = [
  { value: 5.5, label: '5.5% - Biens essentiels', category: 'essential' },
  { value: 10, label: '10% - Services spéciaux', category: 'special' },
  { value: 20, label: '20% - Taux standard', category: 'standard' }
]

export default function InvoiceEditorPage() {
  const [header, setHeader] = useState<InvoiceHeader>({
    client_id: '',
    invoice_number: '',
    issue_date: new Date().toISOString().split('T')[0],
    due_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
  })
  
  const [lineItems, setLineItems] = useState<LineItem[]>([
    {
      id: crypto.randomUUID(),
      description: '',
      quantity: 1,
      unit_price: 0,
      tva_rate: 20,
      total_ht: 0,
      total_ttc: 0
    }
  ])

  const [clients, setClients] = useState<any[]>([])
  const [loading, setLoading] = useState(false)
  const [voiceRecording, setVoiceRecording] = useState(false)
  const supabase = createClient()
  const router = useRouter()

  useEffect(() => {
    loadClients()
  }, [])

  const loadClients = async () => {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data: accountant } = await supabase
      .from('accountants')
      .select('cabinet_id')
      .eq('auth_user_id', user.id)
      .single()

    if (!accountant) return

    const { data: clientsData } = await supabase
      .from('clients')
      .select('id, company_name, siren')
      .eq('cabinet_id', accountant.cabinet_id)
      .order('company_name')

    setClients(clientsData || [])
  }

  const calculateLineTotals = (item: Partial<LineItem>): LineItem => {
    const quantity = item.quantity || 0
    const unit_price = item.unit_price || 0
    const tva_rate = item.tva_rate || 20
    
    const total_ht = quantity * unit_price
    const total_ttc = total_ht * (1 + tva_rate / 100)

    return {
      id: item.id || crypto.randomUUID(),
      description: item.description || '',
      quantity,
      unit_price,
      tva_rate,
      total_ht,
      total_ttc
    }
  }

  const updateLineItem = (index: number, field: keyof LineItem, value: any) => {
    const newItems = [...lineItems]
    newItems[index] = {
      ...newItems[index],
      [field]: value
    }
    newItems[index] = calculateLineTotals(newItems[index])
    setLineItems(newItems)
  }

  const addLineItem = () => {
    setLineItems([...lineItems, {
      id: crypto.randomUUID(),
      description: '',
      quantity: 1,
      unit_price: 0,
      tva_rate: 20,
      total_ht: 0,
      total_ttc: 0
    }])
  }

  const removeLineItem = (index: number) => {
    if (lineItems.length > 1) {
      setLineItems(lineItems.filter((_, i) => i !== index))
    }
  }

  const calculateInvoiceTotals = () => {
    const total_ht = lineItems.reduce((sum, item) => sum + item.total_ht, 0)
    const total_tva = lineItems.reduce((sum, item) => sum + (item.total_ttc - item.total_ht), 0)
    const total_ttc = lineItems.reduce((sum, item) => sum + item.total_ttc, 0)
    
    return { total_ht, total_tva, total_ttc }
  }

  const handleSaveInvoice = async () => {
    if (!header.client_id || !header.invoice_number) {
      alert('Veuillez remplir tous les champs obligatoires')
      return
    }

    setLoading(true)
    
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      const { data: accountant } = await supabase
        .from('accountants')
        .select('cabinet_id')
        .eq('auth_user_id', user.id)
        .single()

      if (!accountant) return

      const totals = calculateInvoiceTotals()

      // Insert invoice
      const { data: invoice, error: invoiceError } = await supabase
        .from('invoices')
        .insert({
          client_id: header.client_id,
          cabinet_id: accountant.cabinet_id,
          invoice_number: header.invoice_number,
          issue_date: header.issue_date,
          due_date: header.due_date,
          total_ht: totals.total_ht,
          total_tva: totals.total_tva,
          total_ttc: totals.total_ttc,
          status: 'draft',
          created_by: user.id
        })
        .select()
        .single()

      if (invoiceError) {
        console.error('Invoice error:', invoiceError)
        alert('Erreur lors de la création de la facture')
        return
      }

      // Insert line items
      const lineItemsData = lineItems.map(item => ({
        invoice_id: invoice.id,
        description: item.description,
        quantity: item.quantity,
        unit_price: item.unit_price,
        tva_rate: item.tva_rate,
        total_ht: item.total_ht,
        total_ttc: item.total_ttc
      }))

      const { error: lineItemsError } = await supabase
        .from('line_items')
        .insert(lineItemsData)

      if (lineItemsError) {
        console.error('Line items error:', lineItemsError)
        alert('Erreur lors de l\'ajout des lignes')
        return
      }

      alert('Facture créée avec succès!')
      router.push('/cabinet')
      
    } catch (error) {
      console.error('Save error:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  const handleVoiceInput = async () => {
    setVoiceRecording(true)
    // Voice recording implementation would go here
    // For MVP, show placeholder
    setTimeout(() => {
      setVoiceRecording(false)
      alert('Fonctionnalité vocale disponible en Phase 3')
    }, 1000)
  }

  const totals = calculateInvoiceTotals()

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-[#002395]">Éditeur de Factures</h1>
            <button
              onClick={() => router.back()}
              className="px-4 py-2 text-sm text-gray-600 hover:text-gray-900"
            >
              ← Retour
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Invoice Header Section */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4">En-tête de Facture</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Client *
              </label>
              <select
                value={header.client_id}
                onChange={(e) => setHeader({ ...header, client_id: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                required
              >
                <option value="">Sélectionner un client</option>
                {clients.map(client => (
                  <option key={client.id} value={client.id}>
                    {client.company_name} ({client.siren})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Numéro de Facture *
              </label>
              <input
                type="text"
                value={header.invoice_number}
                onChange={(e) => setHeader({ ...header, invoice_number: e.target.value })}
                placeholder="FAC-2026-001"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Date d'Émission *
              </label>
              <input
                type="date"
                value={header.issue_date}
                onChange={(e) => setHeader({ ...header, issue_date: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Date d'Échéance *
              </label>
              <input
                type="date"
                value={header.due_date}
                onChange={(e) => setHeader({ ...header, due_date: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                required
              />
            </div>
          </div>
        </div>

        {/* Line Items Section */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold">Lignes de Facture</h2>
            <div className="flex gap-2">
              <button
                onClick={handleVoiceInput}
                disabled={voiceRecording}
                className="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2 text-sm font-medium disabled:opacity-50"
              >
                <Mic className="w-4 h-4" />
                {voiceRecording ? 'Écoute...' : 'Saisie Vocale'}
              </button>
              <button
                onClick={addLineItem}
                className="px-4 py-2 bg-[#002395] text-white rounded-lg hover:bg-blue-800 transition-colors flex items-center gap-2 text-sm font-medium"
              >
                <Plus className="w-4 h-4" />
                Ajouter Ligne
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Qté</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Prix Unit. (€)</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Taux TVA</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total HT (€)</th>
                  <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total TTC (€)</th>
                  <th className="px-4 py-3"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {lineItems.map((item, index) => (
                  <tr key={item.id}>
                    <td className="px-4 py-3">
                      <input
                        type="text"
                        value={item.description}
                        onChange={(e) => updateLineItem(index, 'description', e.target.value)}
                        placeholder="Description du produit/service"
                        className="w-full px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-[#002395]"
                      />
                    </td>
                    <td className="px-4 py-3">
                      <input
                        type="number"
                        value={item.quantity}
                        onChange={(e) => updateLineItem(index, 'quantity', parseFloat(e.target.value) || 0)}
                        min="0"
                        step="0.01"
                        className="w-20 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-[#002395]"
                      />
                    </td>
                    <td className="px-4 py-3">
                      <input
                        type="number"
                        value={item.unit_price}
                        onChange={(e) => updateLineItem(index, 'unit_price', parseFloat(e.target.value) || 0)}
                        min="0"
                        step="0.01"
                        className="w-24 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-[#002395]"
                      />
                    </td>
                    <td className="px-4 py-3">
                      <select
                        value={item.tva_rate}
                        onChange={(e) => updateLineItem(index, 'tva_rate', parseFloat(e.target.value))}
                        className="w-32 px-3 py-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-[#002395]"
                      >
                        {TVA_RATES.map(rate => (
                          <option key={rate.value} value={rate.value}>
                            {rate.label}
                          </option>
                        ))}
                      </select>
                    </td>
                    <td className="px-4 py-3 font-medium">
                      {item.total_ht.toFixed(2)}
                    </td>
                    <td className="px-4 py-3 font-medium">
                      {item.total_ttc.toFixed(2)}
                    </td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => removeLineItem(index)}
                        disabled={lineItems.length === 1}
                        className="p-2 text-red-600 hover:bg-red-50 rounded transition-colors disabled:opacity-30"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Totals Section */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 mb-6">
          <div className="flex justify-between items-center mb-2">
            <Calculator className="w-5 h-5 text-[#002395]" />
            <h3 className="text-lg font-semibold">Calcul Automatique TVA</h3>
          </div>
          
          <div className="space-y-3 mt-4">
            <div className="flex justify-between text-lg">
              <span className="text-gray-600">Total HT:</span>
              <span className="font-semibold">{totals.total_ht.toFixed(2)} €</span>
            </div>
            <div className="flex justify-between text-lg">
              <span className="text-gray-600">Total TVA:</span>
              <span className="font-semibold text-orange-600">{totals.total_tva.toFixed(2)} €</span>
            </div>
            <div className="flex justify-between text-xl font-bold border-t-2 border-gray-200 pt-3">
              <span>Total TTC:</span>
              <span className="text-[#002395]">{totals.total_ttc.toFixed(2)} €</span>
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-4">
          <button
            onClick={handleSaveInvoice}
            disabled={loading}
            className="flex-1 px-6 py-3 bg-[#002395] text-white rounded-lg hover:bg-blue-800 transition-colors flex items-center justify-center gap-2 font-medium disabled:opacity-50"
          >
            <Save className="w-5 h-5" />
            {loading ? 'Enregistrement...' : 'Enregistrer Brouillon'}
          </button>
          
          <button
            onClick={handleSaveInvoice}
            disabled={loading}
            className="flex-1 px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors flex items-center justify-center gap-2 font-medium disabled:opacity-50"
          >
            <FileText className="w-5 h-5" />
            Générer Factur-X
          </button>
        </div>
      </div>
    </div>
  )
}
