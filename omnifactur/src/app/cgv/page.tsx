export default function CGVPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-8">
          <h1 className="text-3xl font-bold text-[#002395] mb-8">Conditions Générales de Vente</h1>
          
          <div className="space-y-6 text-gray-700">
            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 1 - Objet</h2>
              <p className="mb-4">
                Les présentes Conditions Générales de Vente (CGV) régissent la fourniture du service OmniFactur,
                plateforme SaaS de facturation électronique conforme à la réglementation française 2026.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 2 - Services Fournis</h2>
              <p className="mb-2"><strong>2.1 Licence Cabinet (€990/mois HT)</strong></p>
              <ul className="list-disc list-inside space-y-2 ml-4 mb-4">
                <li>Gestion illimitée de clients</li>
                <li>Génération de factures conformes Factur-X 1.0.08</li>
                <li>Export FEC compatible Cegid, Sage, ACD</li>
                <li>Portail white-label personnalisé</li>
                <li>Monitoring de conformité 2026</li>
                <li>Archivage légal 10 ans</li>
                <li>Support technique prioritaire</li>
              </ul>

              <p className="mb-2"><strong>2.2 Période d&apos;essai Beta (€490/mois HT)</strong></p>
              <p className="mb-4">
                Offre réservée aux 2 premiers cabinets pilotes. Engagement 6 mois. Accès à toutes les fonctionnalités.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 3 - Durée et Résiliation</h2>
              <p className="mb-2"><strong>3.1 Durée du contrat:</strong> Abonnement mensuel tacitement reconductible</p>
              <p className="mb-2"><strong>3.2 Résiliation:</strong> Possible à tout moment avec préavis de 30 jours calendaires</p>
              <p className="mb-4"><strong>3.3 Suspension:</strong> En cas de non-paiement, accès suspendu après 7 jours de retard</p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 4 - Tarifs et Paiement</h2>
              <p className="mb-2"><strong>4.1 Prix:</strong> Tarifs affichés en Euros Hors Taxes (TVA 20% applicable)</p>
              <p className="mb-2"><strong>4.2 Facturation:</strong> Mensuelle à date anniversaire de souscription</p>
              <p className="mb-2"><strong>4.3 Modalités:</strong> Paiement par carte bancaire ou virement (sous 15 jours)</p>
              <p className="mb-4"><strong>4.4 Retard:</strong> Pénalités de 3x taux légal + indemnité forfaitaire de 40€</p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 5 - Obligations du Client</h2>
              <ul className="list-disc list-inside space-y-2 ml-4">
                <li>Fournir des informations exactes et à jour (SIREN, coordonnées)</li>
                <li>Respecter les droits de propriété intellectuelle</li>
                <li>Ne pas utiliser le service à des fins illégales</li>
                <li>Sécuriser ses identifiants de connexion</li>
                <li>Informer immédiatement en cas d&apos;utilisation frauduleuse</li>
              </ul>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 6 - Obligations du Fournisseur</h2>
              <ul className="list-disc list-inside space-y-2 ml-4">
                <li>Disponibilité du service: 99,5% (hors maintenance programmée)</li>
                <li>Sauvegarde quotidienne des données</li>
                <li>Hébergement en France (conformité RGPD)</li>
                <li>Conformité Factur-X 1.0.08 et validation FNFE-MPE</li>
                <li>Support technique par email sous 24h ouvrées</li>
              </ul>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 7 - Protection des Données</h2>
              <p className="mb-4">
                OmniFactur s&apos;engage à traiter les données personnelles conformément au RGPD.
                Les données sont hébergées en France (Scaleway Paris) et ne sont jamais transférées hors UE.
              </p>
              <p className="mb-2"><strong>7.1 Données collectées:</strong></p>
              <ul className="list-disc list-inside space-y-2 ml-4 mb-4">
                <li>Données d&apos;identification (nom, email, SIREN)</li>
                <li>Données de facturation (factures, clients, montants)</li>
                <li>Données de connexion (logs, IP)</li>
              </ul>
              <p className="mb-2"><strong>7.2 Conservation:</strong> 10 ans pour les factures (obligation légale), 3 ans pour les logs</p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 8 - Responsabilités et Garanties</h2>
              <p className="mb-2"><strong>8.1 Limitation de responsabilité:</strong></p>
              <p className="mb-4">
                OmniFactur fournit un outil facilitant la conformité 2026 mais ne se substitue pas au conseil
                d&apos;un expert-comptable. Le client reste responsable de l&apos;exactitude des données saisies.
              </p>
              <p className="mb-2"><strong>8.2 Garantie de conformité:</strong></p>
              <p className="mb-4">
                Les fichiers générés sont conformes à Factur-X 1.0.08. En cas de non-conformité avérée,
                correction gratuite sous 48h.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 9 - Force Majeure</h2>
              <p className="mb-4">
                En cas d&apos;événement de force majeure (catastrophe naturelle, cyberattaque massive, décision gouvernementale),
                OmniFactur pourra suspendre temporairement le service sans engagement de responsabilité.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 10 - Modifications des CGV</h2>
              <p className="mb-4">
                OmniFactur se réserve le droit de modifier les CGV avec notification par email 30 jours à l&apos;avance.
                La poursuite de l&apos;utilisation après modification vaut acceptation des nouvelles conditions.
              </p>
            </section>

            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-3">Article 11 - Droit Applicable et Litiges</h2>
              <p className="mb-2"><strong>11.1 Loi applicable:</strong> Droit français</p>
              <p className="mb-2"><strong>11.2 Juridiction compétente:</strong> Tribunal de Commerce de Paris</p>
              <p className="mb-4"><strong>11.3 Médiation:</strong> En cas de litige, médiation obligatoire avant saisine judiciaire (Médiateur de la Consommation)</p>
            </section>

            <section className="bg-green-50 border-l-4 border-green-600 p-4 mt-8">
              <p className="text-sm text-gray-700">
                <strong>✓ Conformité réglementaire:</strong><br />
                Ces CGV sont conformes aux exigences du Code de Commerce français et de l&apos;ordonnance 2021-1190
                relative à la facturation électronique dans les transactions entre assujettis à la TVA.
              </p>
            </section>

            <section className="bg-blue-50 border-l-4 border-[#002395] p-4 mt-4">
              <p className="text-sm text-gray-700">
                <strong>Version:</strong> 1.0<br />
                <strong>Date d&apos;entrée en vigueur:</strong> Janvier 2026<br />
                <strong>Contact:</strong> contact@omnifactur.fr
              </p>
            </section>
          </div>

          <div className="mt-8 pt-6 border-t border-gray-200">
            <a 
              href="/"
              className="text-[#002395] hover:underline font-medium"
            >
              ← Retour à l&apos;accueil
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}
