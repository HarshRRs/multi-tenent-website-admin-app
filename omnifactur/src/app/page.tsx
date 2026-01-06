'use client'

import Link from 'next/link'
import { Shield, FileText, Mic, Clock } from 'lucide-react'
import { useEffect, useState } from 'react'

export default function LandingPage() {
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0
  })

  useEffect(() => {
    const targetDate = new Date('2026-01-01T00:00:00').getTime()

    const interval = setInterval(() => {
      const now = new Date().getTime()
      const difference = targetDate - now

      if (difference > 0) {
        setTimeLeft({
          days: Math.floor(difference / (1000 * 60 * 60 * 24)),
          hours: Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60)),
          minutes: Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60)),
          seconds: Math.floor((difference % (1000 * 60)) / 1000)
        })
      }
    }, 1000)

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex justify-between items-center">
            <h1 className="text-2xl font-bold text-[#002395]">OmniFactur</h1>
            <Link 
              href="/auth"
              className="px-4 py-2 text-sm font-medium text-[#002395] hover:bg-blue-50 rounded-md transition-colors"
            >
              Se connecter
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-red-50 border border-red-200 rounded-full mb-8">
            <Clock className="w-4 h-4 text-red-600" />
            <span className="text-sm font-medium text-red-600">
              Échéance 2026 : {timeLeft.days} jours restants
            </span>
          </div>

          <h2 className="text-5xl font-bold text-gray-900 mb-6">
            Votre Cabinet, Prêt pour la
            <span className="text-[#002395]"> Facturation Électronique 2026</span>
          </h2>

          <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
            Transformez votre cabinet comptable en partenaire de conformité 2026. 
            Gérez 50+ clients avec un portail white-label, exports FEC automatisés, 
            et monitoring de conformité temps réel.
          </p>

          {/* Countdown Timer */}
          <div className="flex justify-center gap-4 mb-12">
            {[
              { label: 'Jours', value: timeLeft.days },
              { label: 'Heures', value: timeLeft.hours },
              { label: 'Minutes', value: timeLeft.minutes },
              { label: 'Secondes', value: timeLeft.seconds }
            ].map((item) => (
              <div key={item.label} className="bg-[#002395] text-white p-4 rounded-lg min-w-[80px]">
                <div className="text-3xl font-bold">{item.value}</div>
                <div className="text-xs uppercase mt-1">{item.label}</div>
              </div>
            ))}
          </div>

          <Link 
            href="/auth"
            className="inline-block px-8 py-4 bg-[#002395] text-white text-lg font-semibold rounded-lg hover:bg-blue-800 transition-colors"
          >
            Planifier une Démo Cabinet
          </Link>
        </div>
      </section>

      {/* Features Section */}
      <section className="bg-gray-50 py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h3 className="text-3xl font-bold text-center mb-12">
            Les 3 Fonctionnalités qui Justifient les €990/mois
          </h3>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Feature 1: White-Label */}
            <div className="bg-white p-8 rounded-xl shadow-sm">
              <div className="w-12 h-12 bg-[#002395] bg-opacity-10 rounded-lg flex items-center justify-center mb-4">
                <Shield className="w-6 h-6 text-[#002395]" />
              </div>
              <h4 className="text-xl font-semibold mb-3">Portail White-Label</h4>
              <p className="text-gray-600 mb-4">
                Vos clients voient "L'Outil Officiel de Cabinet Dupont", pas une application tierce. 
                Renforcez votre relation client et fidélisez votre portefeuille.
              </p>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>✓ Logo et couleurs personnalisés</li>
                <li>✓ Domaine personnalisé optionnel</li>
                <li>✓ Messages de bienvenue sur mesure</li>
              </ul>
            </div>

            {/* Feature 2: FEC Export */}
            <div className="bg-white p-8 rounded-xl shadow-sm border-2 border-[#002395]">
              <div className="w-12 h-12 bg-[#002395] rounded-lg flex items-center justify-center mb-4">
                <FileText className="w-6 h-6 text-white" />
              </div>
              <h4 className="text-xl font-semibold mb-3">Export FEC (LA FONCTIONNALITÉ CLÉ)</h4>
              <p className="text-gray-600 mb-4">
                Export FEC multi-clients qui s'importe dans Cegid Quadra avec ZÉRO erreur. 
                Économisez 10+ heures par mois de corrections manuelles.
              </p>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>✓ Import Cegid/Sage/ACD sans erreur</li>
                <li>✓ Validation débits/crédits automatique</li>
                <li>✓ Format Plan Comptable Général</li>
              </ul>
            </div>

            {/* Feature 3: Compliance Monitor */}
            <div className="bg-white p-8 rounded-xl shadow-sm">
              <div className="w-12 h-12 bg-[#002395] bg-opacity-10 rounded-lg flex items-center justify-center mb-4">
                <Mic className="w-6 h-6 text-[#002395]" />
              </div>
              <h4 className="text-xl font-semibold mb-3">Monitoring de Conformité</h4>
              <p className="text-gray-600 mb-4">
                Tableau de bord "feux tricolores" montrant la préparation 2026 de chaque client. 
                Devenez conseiller conformité, pas saisie de données.
              </p>
              <ul className="space-y-2 text-sm text-gray-600">
                <li>✓ Score de conformité 0-100</li>
                <li>✓ Rapports PDF pour réunions clients</li>
                <li>✓ Suivi historique des progrès</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Compliance Badges */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <h3 className="text-2xl font-bold text-center mb-8">Conformité Garantie</h3>
          <div className="flex justify-center gap-12 items-center">
            <div className="text-center">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <Shield className="w-10 h-10 text-green-600" />
              </div>
              <p className="text-sm font-medium">Factur-X 1.0.08</p>
              <p className="text-xs text-gray-500">Validé FNFE-MPE</p>
            </div>
            <div className="text-center">
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <Shield className="w-10 h-10 text-blue-600" />
              </div>
              <p className="text-sm font-medium">RGPD Conforme</p>
              <p className="text-xs text-gray-500">Hébergement EU</p>
            </div>
            <div className="text-center">
              <div className="w-20 h-20 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-2">
                <FileText className="w-10 h-10 text-purple-600" />
              </div>
              <p className="text-sm font-medium">Plateforme Agréée</p>
              <p className="text-xs text-gray-500">Chorus Pro Ready</p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-[#002395] text-white py-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h3 className="text-3xl font-bold mb-4">
            Lancement Bêta : €490/mois pour les 2 Premiers Cabinets
          </h3>
          <p className="text-lg mb-8 text-blue-100">
            Accès complet aux fonctionnalités. Support prioritaire. Lock-in 6 mois.
          </p>
          <Link 
            href="/auth"
            className="inline-block px-8 py-4 bg-white text-[#002395] text-lg font-semibold rounded-lg hover:bg-gray-100 transition-colors"
          >
            Commencer l'Essai Cabinet
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-sm text-gray-600">
          <p>© 2026 OmniFactur. Plateforme de conformité e-facturation pour cabinets comptables.</p>
          <p className="mt-2">Hébergé en France (Scaleway Paris) • Conformité RGPD</p>
          <div className="mt-4 flex justify-center gap-6">
            <a href="/mentions-legales" className="hover:text-[#002395] transition-colors">
              Mentions Légales
            </a>
            <span className="text-gray-400">|</span>
            <a href="/cgv" className="hover:text-[#002395] transition-colors">
              CGV
            </a>
            <span className="text-gray-400">|</span>
            <a href="mailto:contact@omnifactur.fr" className="hover:text-[#002395] transition-colors">
              Contact
            </a>
          </div>
        </div>
      </footer>
    </div>
  )
}
