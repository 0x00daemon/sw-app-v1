//
//  SSHTerminalView.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//
import SwiftUI

struct SSHTerminalView: View {
    @StateObject private var viewModel = SSHTerminalViewModel()
    @State private var commandInput: String = ""
    @FocusState private var isInputFocused: Bool
    let config: SSHHostConfiguration
    
    var body: some View {
        VStack(spacing: 0) {
            // Terminal Output Area
            ScrollViewReader { proxy in
                ScrollView {
                    Text(viewModel.output)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .id("output")
                }
                .onChange(of: viewModel.output) { _ in
                    // Auto-scroll to bottom when output changes
                    withAnimation {
                        proxy.scrollTo("output", anchor: .bottom)
                    }
                }
            }
            
            // Command Input Area
            VStack(spacing: 0) {
                Divider()
                HStack {
                    TextField("Enter command", text: $commandInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .focused($isInputFocused)
                        .disabled(!viewModel.isConnected)
                        .onSubmit {
                            sendCommand()
                        }
                    
                    Button("Send") {
                        sendCommand()
                    }
                    .disabled(!viewModel.isConnected || commandInput.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
        }
        .navigationTitle("SSH Terminal")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(viewModel.isConnected ? "Disconnect" : "Connect") {
                    Task {
                        if viewModel.isConnected {
                            await viewModel.disconnect()
                        } else {
                            await viewModel.connect(config: config)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Connect automatically when view appears
            Task {
                await viewModel.connect(config: config)
            }
        }
        .onDisappear {
            // Disconnect when view disappears
            Task {
                await viewModel.disconnect()
            }
        }
    }
    
    private func sendCommand() {
        guard !commandInput.isEmpty && viewModel.isConnected else { return }
        let command = commandInput
        commandInput = ""
        
        Task {
            await viewModel.sendCommand(command)
        }
    }
}
