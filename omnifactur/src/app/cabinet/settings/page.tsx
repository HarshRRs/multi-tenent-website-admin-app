'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Settings, Upload, Palette, Globe, Mail, Shield, Link as LinkIcon } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface WhiteLabelConfig {
  logo_url: string
  primary_color: string
  accent_color: string
  custom_domain: string
  welcome_message: string
}

export default function SettingsPage() {
  const [config, setConfig] = useState<WhiteLabelConfig>({
    logo_url: '',
    primary_color: '#002395',
    accent_color: '#0066CC',
    custom_domain: '',
    welcome_message: 'Bienvenue sur votre portail de conformité 2026'
  })

  const [paStatus, setPAStatus] = useState<'disconnected' | 'connected' | 'testing'>('disconnected')
  const [paCredentials, setPACredentials] = useState({ apiKey: '', endpoint: '' })
  const [loading, setLoading] = useState(false)
  const [logoFile, setLogoFile] = useState<File | null>(null)
  const [activeTab, setActiveTab] = useState<'branding' | 'pa' | 'notifications'>('branding')
  
  const supabase = createClient()
  const router = useRouter()

  useEffect(() => {
    loadWhiteLabelConfig()
  }, [])

  const loadWhiteLabelConfig = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      const { data: accountant } = await supabase
        .from('accountants')
        .select('cabinet_id')
        .eq('auth_user_id', user.id)
        .single()

      if (!accountant) return

      const { data: configData } = await supabase
        .from('white_label_configs')
        .select('*')
        .eq('cabinet_id', accountant.cabinet_id)
        .single()

      if (configData) {
        setConfig({
          logo_url: configData.logo_url || '',
          primary_color: configData.primary_color || '#002395',
          accent_color: configData.accent_color || '#0066CC',
          custom_domain: configData.custom_domain || '',
          welcome_message: configData.welcome_message || 'Bienvenue sur votre portail de conformité 2026'
        })
      }
    } catch (error) {
      console.error('Error loading config:', error)
    }
  }

  const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    if (file.size > 2 * 1024 * 1024) {
      alert('Le logo ne doit pas dépasser 2 MB')
      return
    }

    if (!['image/png', 'image/jpeg', 'image/svg+xml'].includes(file.type)) {
      alert('Format accepté: PNG, JPG, SVG')
      return
    }

    setLogoFile(file)
    
    // Preview
    const reader = new FileReader()
    reader.onload = (e) => {
      setConfig({ ...config, logo_url: e.target?.result as string })
    }
    reader.readAsDataURL(file)
  }

  const handleSaveBranding = async () => {
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

      let logoUrl = config.logo_url

      // Upload logo if new file selected
      if (logoFile) {
        const fileExt = logoFile.name.split('.').pop()
        const fileName = `${accountant.cabinet_id}-logo.${fileExt}`
        const { error: uploadError } = await supabase.storage
          .from('logos')
          .upload(fileName, logoFile, { upsert: true })

        if (uploadError) {
          console.error('Upload error:', uploadError)
          alert('Erreur lors du téléchargement du logo')
          return
        }

        const { data: { publicUrl } } = supabase.storage
          .from('logos')
          .getPublicUrl(fileName)

        logoUrl = publicUrl
      }

      // Upsert white label config
      const { error } = await supabase
        .from('white_label_configs')
        .upsert({
          cabinet_id: accountant.cabinet_id,
          logo_url: logoUrl,
          primary_color: config.primary_color,
          accent_color: config.accent_color,
          custom_domain: config.custom_domain,
          welcome_message: config.welcome_message
        })

      if (error) {
        console.error('Config save error:', error)
        alert('Erreur lors de la sauvegarde')
      } else {
        alert('Configuration white-label enregistrée!')
      }
    } catch (error) {
      console.error('Save error:', error)
      alert('Erreur lors de la sauvegarde')
    } finally {
      setLoading(false)
    }
  }

  const handleTestPA = async () => {
    setPAStatus('testing')
    
    // Simulate PA connection test
    setTimeout(() => {
      if (paCredentials.apiKey && paCredentials.endpoint) {
        setPAStatus('connected')
        alert('Connexion à la Plateforme Agréée réussie!')
      } else {
        setPAStatus('disconnected')
        alert('Veuillez remplir les informations d\'identification')
      }
    }, 2000)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-[#002395]">Paramètres Cabinet</h1>
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
        {/* Tabs */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
          <div className="border-b border-gray-200">
            <nav className="flex -mb-px">
              <button
                onClick={() => setActiveTab('branding')}
                className={`px-6 py-4 text-sm font-medium border-b-2 ${
                  activeTab === 'branding'
                    ? 'border-[#002395] text-[#002395]'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Palette className="w-4 h-4 inline mr-2" />
                White-Label
              </button>
              <button
                onClick={() => setActiveTab('pa')}
                className={`px-6 py-4 text-sm font-medium border-b-2 ${
                  activeTab === 'pa'
                    ? 'border-[#002395] text-[#002395]'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <LinkIcon className="w-4 h-4 inline mr-2" />
                Plateforme Agréée
              </button>
              <button
                onClick={() => setActiveTab('notifications')}
                className={`px-6 py-4 text-sm font-medium border-b-2 ${
                  activeTab === 'notifications'
                    ? 'border-[#002395] text-[#002395]'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                <Mail className="w-4 h-4 inline mr-2" />
                Notifications
              </button>
            </nav>
          </div>

          {/* White-Label Tab */}
          {activeTab === 'branding' && (
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-6">Configuration White-Label</h2>
              <p className="text-gray-600 mb-6">
                Personnalisez le portail pour vos clients. Ils verront votre marque, pas "OmniFactur".
              </p>

              <div className="space-y-6">
                {/* Logo Upload */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Upload className="w-4 h-4 inline mr-1" />
                    Logo du Cabinet
                  </label>
                  <div className="flex items-center gap-4">
                    {config.logo_url && (
                      <div className="w-32 h-32 border-2 border-gray-300 rounded-lg flex items-center justify-center overflow-hidden">
                        <img src={config.logo_url} alt="Logo preview" className="max-w-full max-h-full" />
                      </div>
                    )}
                    <div>
                      <input
                        type="file"
                        id="logo-upload"
                        accept="image/png,image/jpeg,image/svg+xml"
                        onChange={handleLogoUpload}
                        className="hidden"
                      />
                      <label
                        htmlFor="logo-upload"
                        className="px-4 py-2 bg-gray-100 border border-gray-300 rounded-lg hover:bg-gray-200 cursor-pointer inline-block text-sm font-medium"
                      >
                        Choisir un fichier
                      </label>
                      <p className="text-xs text-gray-500 mt-1">PNG, JPG, SVG • Max 2 MB</p>
                    </div>
                  </div>
                </div>

                {/* Primary Color */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Palette className="w-4 h-4 inline mr-1" />
                    Couleur Principale
                  </label>
                  <div className="flex items-center gap-4">
                    <input
                      type="color"
                      value={config.primary_color}
                      onChange={(e) => setConfig({ ...config, primary_color: e.target.value })}
                      className="w-16 h-16 rounded border border-gray-300 cursor-pointer"
                    />
                    <input
                      type="text"
                      value={config.primary_color}
                      onChange={(e) => setConfig({ ...config, primary_color: e.target.value })}
                      placeholder="#002395"
                      className="px-4 py-2 border border-gray-300 rounded-lg w-32"
                    />
                    <span className="text-sm text-gray-600">Code hexadécimal</span>
                  </div>
                </div>

                {/* Custom Domain */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    <Globe className="w-4 h-4 inline mr-1" />
                    Domaine Personnalisé (Optionnel)
                  </label>
                  <input
                    type="text"
                    value={config.custom_domain}
                    onChange={(e) => setConfig({ ...config, custom_domain: e.target.value })}
                    placeholder="facturation.votrecabinet.fr"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                  />
                  <p className="text-xs text-gray-500 mt-1">Configuration CNAME requise</p>
                </div>

                {/* Welcome Message */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Message de Bienvenue
                  </label>
                  <textarea
                    value={config.welcome_message}
                    onChange={(e) => setConfig({ ...config, welcome_message: e.target.value })}
                    rows={3}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                  />
                </div>

                <button
                  onClick={handleSaveBranding}
                  disabled={loading}
                  className="px-6 py-3 bg-[#002395] text-white rounded-lg hover:bg-blue-800 transition-colors font-medium disabled:opacity-50"
                >
                  {loading ? 'Enregistrement...' : 'Enregistrer White-Label'}
                </button>
              </div>
            </div>
          )}

          {/* Plateforme Agréée Tab */}
          {activeTab === 'pa' && (
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-6">Connexion Plateforme Agréée</h2>
              <p className="text-gray-600 mb-6">
                Connectez-vous à Chorus Pro ou une PA certifiée DGFiP pour la transmission automatique des factures électroniques.
              </p>

              <div className="space-y-6">
                {/* PA Status Indicator */}
                <div className={`p-4 rounded-lg border-2 ${
                  paStatus === 'connected' 
                    ? 'bg-green-50 border-green-500' 
                    : paStatus === 'testing'
                    ? 'bg-yellow-50 border-yellow-500'
                    : 'bg-gray-50 border-gray-300'
                }`}>
                  <div className="flex items-center gap-3">
                    <Shield className={`w-8 h-8 ${
                      paStatus === 'connected' ? 'text-green-600' : 'text-gray-400'
                    }`} />
                    <div>
                      <p className="font-semibold">
                        Statut PA: {
                          paStatus === 'connected' ? 'Connecté' : 
                          paStatus === 'testing' ? 'Test en cours...' : 
                          'Non configuré'
                        }
                      </p>
                      <p className="text-sm text-gray-600">
                        {paStatus === 'connected' 
                          ? 'Prêt pour la transmission automatique' 
                          : 'Configurez vos identifiants ci-dessous'}
                      </p>
                    </div>
                  </div>
                </div>

                {/* PA Credentials */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Clé API Plateforme Agréée
                  </label>
                  <input
                    type="password"
                    value={paCredentials.apiKey}
                    onChange={(e) => setPACredentials({ ...paCredentials, apiKey: e.target.value })}
                    placeholder="Votre clé API"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Point de Terminaison API
                  </label>
                  <input
                    type="url"
                    value={paCredentials.endpoint}
                    onChange={(e) => setPACredentials({ ...paCredentials, endpoint: e.target.value })}
                    placeholder="https://api.chorus-pro.gouv.fr"
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#002395]"
                  />
                </div>

                <button
                  onClick={handleTestPA}
                  disabled={paStatus === 'testing'}
                  className="px-6 py-3 bg-[#002395] text-white rounded-lg hover:bg-blue-800 transition-colors font-medium disabled:opacity-50"
                >
                  {paStatus === 'testing' ? 'Test en cours...' : 'Tester la Connexion'}
                </button>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mt-6">
                  <p className="text-sm text-blue-800 font-medium mb-2">
                    ℹ️ À propos des Plateformes Agréées
                  </p>
                  <p className="text-sm text-blue-700">
                    Les Plateformes Agréées sont certifiées par la DGFiP pour la transmission des factures électroniques. 
                    Chorus Pro est la plateforme gouvernementale par défaut pour les transactions avec le secteur public.
                  </p>
                </div>
              </div>
            </div>
          )}

          {/* Notifications Tab */}
          {activeTab === 'notifications' && (
            <div className="p-6">
              <h2 className="text-xl font-semibold mb-6">Préférences de Notification</h2>
              
              <div className="space-y-4">
                <label className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer">
                  <input type="checkbox" defaultChecked className="w-4 h-4" />
                  <div>
                    <p className="font-medium">Alertes de Conformité</p>
                    <p className="text-sm text-gray-600">Clients avec score de conformité &lt; 70%</p>
                  </div>
                </label>

                <label className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer">
                  <input type="checkbox" defaultChecked className="w-4 h-4" />
                  <div>
                    <p className="font-medium">Factures Impayées</p>
                    <p className="text-sm text-gray-600">Notification 7 jours après échéance</p>
                  </div>
                </label>

                <label className="flex items-center gap-3 p-4 border border-gray-200 rounded-lg hover:bg-gray-50 cursor-pointer">
                  <input type="checkbox" className="w-4 h-4" />
                  <div>
                    <p className="font-medium">Rapports Hebdomadaires</p>
                    <p className="text-sm text-gray-600">Résumé des activités chaque lundi</p>
                  </div>
                </label>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
