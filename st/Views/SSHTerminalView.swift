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
                        .font(.custom("Menlo", size: 14))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .id("output")
                }
                .background(Color.black)
                .onChange(of: viewModel.output) { _ in
                    withAnimation {
                        proxy.scrollTo("output", anchor: .bottom)
                    }
                }
            }
            
            // Command Input Area
            HStack(spacing: 4) {
                Text(viewModel.prompt)
                    .font(.custom("Menlo", size: 14))
                    .foregroundColor(.green)
                
                TextField("", text: $commandInput)
                    .font(.custom("Menlo", size: 14))
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.green)
                    .accentColor(.green)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isInputFocused)
                    .disabled(!viewModel.isConnected)
                    .onSubmit {
                        sendCommand()
                    }
                    .onAppear {
                        isInputFocused = true
                    }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black)
        }
        .navigationTitle("SSH Terminal")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black)
        .onAppear {
            Task {
                await viewModel.connect(config: config)
            }
        }
        .onDisappear {
            Task {
                await viewModel.disconnect()
            }
        }
    }
    
    private func sendCommand() {
        guard !commandInput.isEmpty else { return }
        let command = commandInput
        commandInput = ""
        
        Task {
            await viewModel.sendCommand(command)
        }
    }
}

// Preview Provider for SwiftUI Canvas
struct SSHTerminalView_Previews: PreviewProvider {
    static var previews: some View {
        SSHTerminalView(config: SSHHostConfiguration(
            hostname: "example.com",
            username: "user",
            password: "password",
            port: 22
        ))
    }
}
