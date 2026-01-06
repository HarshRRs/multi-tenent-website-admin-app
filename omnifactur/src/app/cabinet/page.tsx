'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Users, FileDown, AlertTriangle, Settings, LogOut, FolderSync } from 'lucide-react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

interface Client {
  id: string
  company_name: string
  siren: string
  industry_type: string
  created_at: string
}

interface CabinetStats {
  totalClients: number
  totalInvoices: number
  complianceRate: number
}

export default function CabinetPortal() {
  const [clients, setClients] = useState<Client[]>([])
  const [stats, setStats] = useState<CabinetStats>({ totalClients: 0, totalInvoices: 0, complianceRate: 0 })
  const [selectedClients, setSelectedClients] = useState<Set<string>>(new Set())
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const supabase = createClient()
  const router = useRouter()

  useEffect(() => {
    loadCabinetData()
  }, [])

  const loadCabinetData = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        router.push('/auth')
        return
      }

      // Get accountant's cabinet_id
      const { data: accountant } = await supabase
        .from('accountants')
        .select('cabinet_id')
        .eq('auth_user_id', user.id)
        .single()

      if (!accountant) {
        console.error('Accountant not found')
        return
      }

      // Load clients (RLS will filter automatically)
      const { data: clientsData } = await supabase
        .from('clients')
        .select('*')
        .eq('cabinet_id', accountant.cabinet_id)
        .order('company_name')

      setClients(clientsData || [])

      // Load stats
      const { count: invoiceCount } = await supabase
        .from('invoices')
        .select('*', { count: 'exact', head: true })
        .eq('cabinet_id', accountant.cabinet_id)

      setStats({
        totalClients: clientsData?.length || 0,
        totalInvoices: invoiceCount || 0,
        complianceRate: 75 // Placeholder
      })

      setLoading(false)
    } catch (error) {
      console.error('Error loading cabinet data:', error)
      setLoading(false)
    }
  }

  const handleSignOut = async () => {
    await supabase.auth.signOut()
    router.push('/')
  }

  const toggleClientSelection = (clientId: string) => {
    const newSelection = new Set(selectedClients)
    if (newSelection.has(clientId)) {
      newSelection.delete(clientId)
    } else {
      newSelection.add(clientId)
    }
    setSelectedClients(newSelection)
  }

  const handleBulkFECExport = async () => {
    if (selectedClients.size === 0) {
      alert('Veuillez sélectionner au moins un client')
      return
    }
    
    // Call FEC export API
    const response = await fetch('/api/fec/export', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ clientIds: Array.from(selectedClients) })
    })
    
    if (response.ok) {
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `FEC_${new Date().toISOString().split('T')[0]}.txt`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
    } else {
      alert('Erreur lors de l\'export FEC')
    }
  }

  const filteredClients = clients.filter(client =>
    client.company_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    client.siren.includes(searchTerm)
  )

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#002395] mx-auto"></div>
          <p className="mt-4 text-gray-600">Chargement...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-[#002395]">Portail Cabinet</h1>
            <div className="flex items-center gap-4">
              <Link 
                href="/cabinet/settings"
                className="p-2 text-gray-600 hover:text-[#002395] transition-colors"
              >
                <Settings className="w-5 h-5" />
              </Link>
              <button 
                onClick={handleSignOut}
                className="p-2 text-gray-600 hover:text-red-600 transition-colors"
              >
                <LogOut className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Stats Panel */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Total Clients</p>
                <p className="text-3xl font-bold text-gray-900">{stats.totalClients}</p>
              </div>
              <Users className="w-10 h-10 text-[#002395] opacity-20" />
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Factures Traitées</p>
                <p className="text-3xl font-bold text-gray-900">{stats.totalInvoices}</p>
              </div>
              <FileDown className="w-10 h-10 text-[#002395] opacity-20" />
            </div>
          </div>

          <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-600">Taux de Conformité</p>
                <p className="text-3xl font-bold text-green-600">{stats.complianceRate}%</p>
              </div>
              <AlertTriangle className="w-10 h-10 text-green-600 opacity-20" />
            </div>
          </div>
        </div>

        {/* Bulk Actions Toolbar */}
        {selectedClients.size > 0 && (
          <div className="bg-[#002395] text-white px-6 py-4 rounded-lg mb-6 flex items-center justify-between">
            <span className="font-medium">{selectedClients.size} client(s) sélectionné(s)</span>
            <div className="flex gap-3">
              <button 
                onClick={handleBulkFECExport}
                className="px-4 py-2 bg-white text-[#002395] rounded-md hover:bg-gray-100 transition-colors font-medium flex items-center gap-2"
              >
                <FileDown className="w-4 h-4" />
                Export FEC
              </button>
              <button className="px-4 py-2 bg-white text-[#002395] rounded-md hover:bg-gray-100 transition-colors font-medium flex items-center gap-2">
                <FolderSync className="w-4 h-4" />
                Archive Factur-X
              </button>
            </div>
          </div>
        )}

        {/* Client List */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200">
          <div className="p-6 border-b border-gray-200">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-semibold">Portfolio Clients</h2>
              <Link 
                href="/cabinet/clients/new"
                className="px-4 py-2 bg-[#002395] text-white rounded-md hover:bg-blue-800 transition-colors text-sm font-medium"
              >
                + Nouveau Client
              </Link>
            </div>
            <input
              type="text"
              placeholder="Rechercher par nom ou SIREN..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
            />
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50 border-b border-gray-200">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    <input
                      type="checkbox"
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedClients(new Set(filteredClients.map(c => c.id)))
                        } else {
                          setSelectedClients(new Set())
                        }
                      }}
                      className="rounded border-gray-300"
                    />
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Entreprise
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    SIREN
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Secteur
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Conformité
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredClients.map((client) => (
                  <tr key={client.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <input
                        type="checkbox"
                        checked={selectedClients.has(client.id)}
                        onChange={() => toggleClientSelection(client.id)}
                        className="rounded border-gray-300"
                      />
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm font-medium text-gray-900">{client.company_name}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-sm text-gray-600">{client.siren}</div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                        {client.industry_type || 'Non défini'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 rounded-full">
                        ● Conforme
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <Link 
                        href={`/cabinet/clients/${client.id}`}
                        className="text-[#002395] hover:underline font-medium"
                      >
                        Voir détails
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredClients.length === 0 && (
            <div className="text-center py-12">
              <Users className="w-12 h-12 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600">Aucun client trouvé</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
