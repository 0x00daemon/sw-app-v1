//
//  AddSSHConfigurationView.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//
import SwiftUI

struct AddSSHConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hostname = ""
    @State private var username = ""
    @State private var password = ""
    @State private var port = "22"
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var onSave: (SSHHostConfiguration) -> Void
    
    private var isValid: Bool {
        !hostname.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty &&
        (Int(port) ?? 0) > 0 &&
        (Int(port) ?? 0) <= 65535
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Details")) {
                    TextField("Hostname (e.g., localhost)", text: $hostname)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                    
                    TextField("Port", text: $port)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Information"), footer: Text("Make sure your SSH server allows password authentication")) {
                    Text("Default port is 22")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Add SSH Host")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHost()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveHost() {
        guard let portNumber = Int(port), portNumber > 0, portNumber <= 65535 else {
            errorMessage = "Invalid port number. Must be between 1 and 65535."
            showingError = true
            return
        }
        
        let config = SSHHostConfiguration(
            hostname: hostname.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            port: portNumber
        )
        
        onSave(config)
        dismiss()
    }
}
