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
    private var config: SSHHostConfiguration?
    @Published var output: String = ""
    @Published var isConnected: Bool = false
    @Published var isConnecting: Bool = false
    @Published var prompt: String = "$ "
    
    private var commandHistory: [String] = []
    private var historyIndex: Int = 0
    
    func connect(config: SSHHostConfiguration) async {
        guard !isConnected && !isConnecting else { return }
        
        self.config = config
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
            output += "Connected to \(config.hostname)\n"
            
            // Get initial working directory
            await sendCommand("pwd")
        } catch {
            output += "Error: \(error.localizedDescription)\n"
        }
        
        isConnecting = false
    }
    
    func sendCommand(_ command: String) async {
        guard isConnected, let config = self.config else { return }
        
        // Add command to history
        commandHistory.append(command)
        historyIndex = commandHistory.count
        
        do {
            if command.hasPrefix("sudo ") {
                // Handle sudo with password
                let sudoCommand = "echo '\(config.password)' | sudo -S \(command.dropFirst(5))"
                let result = try await connection.executeCommand(sudoCommand)
                let trimmedResult = result.trimmingCharacters(in: .whitespacesAndNewlines)
                output += trimmedResult
                if !trimmedResult.hasSuffix(prompt) {
                    output += "\n\(prompt)"
                }
            } else {
                let result = try await connection.executeCommand(command)
                let trimmedResult = result.trimmingCharacters(in: .whitespacesAndNewlines)
                output += trimmedResult
                if !trimmedResult.hasSuffix(prompt) {
                    output += "\n\(prompt)"
                }
            }
        } catch {
            output += "Error executing command: \(error.localizedDescription)\n\(prompt)"
        }
    }
    
    func getPreviousCommand() -> String? {
        guard !commandHistory.isEmpty && historyIndex > 0 else { return nil }
        historyIndex -= 1
        return commandHistory[historyIndex]
    }
    
    func getNextCommand() -> String? {
        guard !commandHistory.isEmpty && historyIndex < commandHistory.count - 1 else {
            historyIndex = commandHistory.count
            return ""
        }
        historyIndex += 1
        return commandHistory[historyIndex]
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
        config = nil
    }
}
