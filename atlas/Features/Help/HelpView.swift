import SwiftUI

/// A short in-app manual, reachable from the Library header's "?" button.
/// Content mirrors the standalone web manual, adapted for a single scrolling
/// sheet in the app's own type scale rather than a separate styled page.
struct HelpView: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Text("Help")
          .font(AtlasFont.screenTitle)
          .foregroundStyle(AtlasColor.text)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, AtlasSpacing.screenHorizontal)
          .padding(.bottom, AtlasSpacing.l)

        AtlasDivider()

        ScrollView {
          VStack(alignment: .leading, spacing: 0) {
            librarySection
            AtlasDivider()
            addPlaceSection
            AtlasDivider()
            editPlaceSection
            AtlasDivider()
            categoriesSection
            AtlasDivider()
            mapSection
            AtlasDivider()
            backupSection
          }
        }
      }
      .background(AtlasColor.background)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Gereed") { dismiss() }
            .font(AtlasFont.body)
            .foregroundStyle(AtlasColor.textSecondary)
        }
      }
      .tint(AtlasColor.accent)
    }
  }

  // MARK: - Sections

  private var librarySection: some View {
    section(title: "Collecties — je overzicht") {
      point("Een collectie maken", "Tik op + rechtsboven → Nieuwe collectie.")
      point("Naam en notities", "Open de collectie, tik het potlood-icoon rechtsboven.")
      point("Cover-foto", "Verschijnt automatisch — de eerste foto van de eerste plek erin die er een heeft.")
      point("Verwijderen", "Veeg de collectie naar links → Verwijder. Verwijdert ook alle plekken erin.")
    }
  }

  private var addPlaceSection: some View {
    section(title: "Een plek toevoegen") {
      point("Zoeken terwijl je typt", "In de Search-tab — suggesties verschijnen live.")
      point("Huidige locatie", "\"Gebruik huidige locatie\" voegt toe waar je nu staat.")
      point("Plakken vanuit Maps", "Kopieer een link uit Apple of Google Maps, tik \"Plak vanuit Maps\".")
      point("Delen vanuit Maps-apps", "Deel-icoon in Maps → Goeieplek. Staat klaar in een bannertje bij de volgende keer openen.")
      point("Nog geen collectie?", "Tik \"Nieuwe collectie\" direct in het zoekresultaat — wordt ter plekke aangemaakt en de plek erin bewaard.")
    }
  }

  private var editPlaceSection: some View {
    section(title: "Een plek bewerken") {
      point("Foto's", "Tot 5 per plek. Veeg door de foto's als er meer dan één is.")
      point("Notities & categorie", "Bepaalt meteen de kleur van het label.")
      point("Verplaatsen", "Map-icoon in de werkbalk — kies een andere collectie.")
      point("Kaart-uitsnede", "Tik erop om in de Kaart-tab in te zoomen op die plek.")
    }
  }

  private var categoriesSection: some View {
    section(title: "Categorieën") {
      HStack(spacing: 8) {
        AtlasTag(category: "restaurant")
        AtlasTag(category: "hotel")
        AtlasTag(category: "uitzicht")
        AtlasTag(category: "activiteit")
      }
      .padding(.top, 2)
      .padding(.bottom, AtlasSpacing.s)

      Text("Elke categorie krijgt automatisch een eigen kleur. Beheren doe je via het label-icoon op de Collecties-pagina.")
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
    }
  }

  private var mapSection: some View {
    section(title: "Kaart") {
      Text("Al je plekken uit alle collecties samen. Tik op een pin voor de details. Onderaan filter je op categorie.")
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
    }
  }

  private var backupSection: some View {
    section(title: "Back-up, herstel & delen") {
      point("Hele bibliotheek", "Collecties → + → Back-up van alle collecties… Terugzetten via + → Importeer….")
      point("Eén collectie delen", "Deel-icoon op de collectiepagina: als tekst (leesbare lijst met Maps-links) of als Goeieplek-bestand (volledig herimporteerbaar, met foto's).")
    }
  }

  // MARK: - Building blocks

  @ViewBuilder
  private func section(title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: AtlasSpacing.s) {
      Text(title)
        .font(AtlasFont.collectionRow)
        .foregroundStyle(AtlasColor.text)
        .padding(.top, AtlasSpacing.s)
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, AtlasSpacing.screenHorizontal)
    .padding(.vertical, AtlasSpacing.l)
  }

  private func point(_ title: String, _ body: String) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(AtlasFont.action)
        .foregroundStyle(AtlasColor.text)
      Text(body)
        .font(AtlasFont.body)
        .foregroundStyle(AtlasColor.textSecondary)
    }
    .padding(.bottom, AtlasSpacing.xs)
  }
}
