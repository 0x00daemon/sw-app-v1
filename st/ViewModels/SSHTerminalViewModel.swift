//
//  SSHTerminalViewModel.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//

import SwiftUI

@MainActor
class SSHTerminalViewModel: ObservableObject {
    private var connection = SSHConnection()
    @Published var output: String = ""
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    
    func connect(config: SSHHostConfiguration) async {
        guard !isConnected && !isConnecting else { return }
        
        isConnecting = true
        output += "Connecting to \(config.hostname)...\n"
        
        do {
            try await connection.connect(
                host: config.hostname,
                username: config.username,
                password: config.password,
                port: config.port
            )
            
            isConnected = true
            output += "Connected to \(config.hostname)\n$ "
        } catch {
            output += "Error: \(error.localizedDescription)\n"
        }
        
        isConnecting = false
    }
    
    func sendCommand(_ command: String) async {
        guard isConnected else { return }
        
        output += "\(command)\n"
        
        do {
            let result = try await connection.executeCommand(command)
            output += "\(result)$ "
        } catch {
            output += "Error executing command: \(error.localizedDescription)\n$ "
        }
    }
    
    func disconnect() async {
        guard isConnected else { return }
        
        do {
            try await connection.disconnect()
            output += "Disconnected\n"
        } catch {
            output += "Error disconnecting: \(error.localizedDescription)\n"
        }
        
        isConnected = false
    }
}
