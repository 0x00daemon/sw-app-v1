//
//  SSHConnection.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//

import Foundation
import Citadel
import NIOSSH
import NIO

enum SSHError: LocalizedError {
    case notConnected
    case connectionFailed(String)
    case authenticationFailed(String)
    case networkError(String)
    case ttyError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Not connected to SSH server"
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .ttyError(let reason):
            return "TTY Error: \(reason)"
        }
    }
}

class SSHConnection {
    var client: SSHClient?
    
    func connect(host: String, username: String, password: String, port: Int = 22) async throws {
        print("[SSH Debug] Starting connection to \(host):\(port) as \(username)")
        
        do {
            let authMethod = SSHAuthenticationMethod.passwordBased(
                username: username,
                password: password
            )
            
            client = try await SSHClient.connect(
                host: host,
                port: port,
                authenticationMethod: authMethod,
                hostKeyValidator: .acceptAnything(),
                reconnect: .never,
                connectTimeout: .seconds(30)
            )
            
            // Test connection with a simple command
            _ = try await executeCommand("echo 'Connection established'")
            
            print("[SSH Debug] Successfully connected and authenticated")
        } catch {
            print("[SSH Debug] Connection error: \(error)")
            throw SSHError.connectionFailed(error.localizedDescription)
        }
    }
    
    func executeCommand(_ command: String) async throws -> String {
        guard let client = client else {
            throw SSHError.notConnected
        }
        
        print("[SSH Debug] Executing command: \(command)")
        
        do {
            // Execute command
            let result = try await client.executeCommand(command)
            return String(buffer: result)
        } catch {
            print("[SSH Debug] Command execution error: \(error)")
            throw SSHError.connectionFailed(error.localizedDescription)
        }
    }
    
    func disconnect() async throws {
        if let client = client {
            try await client.close()
            self.client = nil
            print("[SSH Debug] Disconnected")
        }
    }
}
