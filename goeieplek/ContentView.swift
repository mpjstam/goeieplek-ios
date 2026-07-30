import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) var modelContext
  @State private var viewModel: CollectionsViewModel?
  @State private var newCollectionName = ""
  @State private var showingNewCollection = false

  var body: some View {
    NavigationStack {
      Group {
        if let viewModel = viewModel {
          if viewModel.collections.isEmpty {
            VStack(spacing: 20) {
              Image(systemName: "mappin.circle")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
              Text("No collections yet")
                .font(.headline)
              Text("Create one to start collecting places")
                .font(.caption)
                .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.05))
          } else {
            List {
              ForEach(viewModel.collections, id: \.id) { collection in
                NavigationLink(destination: CollectionDetailView(collection: collection, repository: CollectionsRepository(modelContext: modelContext))) {
                  VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                      .font(.headline)
                    if !collection.notes.isEmpty {
                      Text(collection.notes)
                        .font(.caption)
                        .foregroundStyle(.gray)
                    }
                    Text("\(collection.places.count) places")
                      .font(.caption2)
                      .foregroundStyle(.secondary)
                  }
                }
              }
            }
          }
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Atlas")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: { showingNewCollection = true }) {
            Image(systemName: "plus")
          }
        }
      }
      .sheet(isPresented: $showingNewCollection) {
        NavigationStack {
          Form {
            TextField("Collection name", text: $newCollectionName)
          }
          .navigationTitle("New Collection")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Cancel") {
                showingNewCollection = false
                newCollectionName = ""
              }
            }
            ToolbarItem(placement: .confirmationAction) {
              Button("Create") {
                if !newCollectionName.isEmpty {
                  viewModel?.createCollection(name: newCollectionName)
                  showingNewCollection = false
                  newCollectionName = ""
                }
              }
            }
          }
        }
      }
    }
    .onAppear {
      if viewModel == nil {
        viewModel = CollectionsViewModel(modelContext: modelContext)
      }
    }
  }
}

#Preview {
  ContentView()
}
