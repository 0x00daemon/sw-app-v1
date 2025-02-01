import SwiftUI

struct ContentView: View {
    @State private var configurations: [SSHHostConfiguration] = []
    @State private var showingAddSheet = false
    private let store = SSHConfigurationStore()
    
    var body: some View {
        NavigationView {
            List(configurations) { config in
                NavigationLink(destination: SSHTerminalView(config: config)) {
                    VStack(alignment: .leading) {
                        Text(config.hostname)
                            .font(.headline)
                        Text(config.username)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("SSH Hosts")
            .toolbar {
                Button("Add Host") {
                    showingAddSheet = true
                }
            }
        }
        .onAppear {
            configurations = store.getAllConfigurations()
        }
        .sheet(isPresented: $showingAddSheet) {
            AddSSHConfigurationView { newConfig in
                store.saveConfiguration(newConfig)
                configurations = store.getAllConfigurations()
            }
        }
    }
}
