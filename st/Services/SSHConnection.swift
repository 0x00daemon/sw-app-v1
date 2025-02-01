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
        }
    }
}

class SSHConnection {
    var client: SSHClient?
    
    func connect(host: String, username: String, password: String, port: Int = 22) async throws {
        print("[SSH Debug] Starting connection to \(host):\(port) as \(username)")
        
        do {
            // Create a more detailed authentication method
            let authMethod = SSHAuthenticationMethod.passwordBased(
                username: username,
                password: password
            )
            
            print("[SSH Debug] Attempting authentication with method: password")
            
            // Configure client with updated settings
            client = try await SSHClient.connect(
                host: host,
                port: port,
                authenticationMethod: authMethod,
                hostKeyValidator: .acceptAnything(),
                reconnect: .never,
                connectTimeout: .seconds(30)
            )
            
            print("[SSH Debug] Successfully connected and authenticated")
            
        } catch let error as CitadelError {
            print("[SSH Debug] Citadel error: \(error)")
            throw SSHError.authenticationFailed("Authentication failed - Please check your username and password")
            
        } catch let error as NIOSSHError {
            print("[SSH Debug] NIOSSH error: \(error)")
            if error.localizedDescription.contains("authentication") {
                throw SSHError.authenticationFailed("All authentication methods failed - Please verify your credentials")
            } else {
                throw SSHError.connectionFailed("SSH Connection error: \(error.localizedDescription)")
            }
            
        } catch {
            print("[SSH Debug] Unexpected error: \(error)")
            throw SSHError.connectionFailed("Unexpected error: \(error.localizedDescription)")
        }
    }
    
    func executeCommand(_ command: String) async throws -> String {
        guard let client = client else {
            throw SSHError.notConnected
        }
        
        print("[SSH Debug] Executing command: \(command)")
        let result = try await client.executeCommand(command)
        return String(buffer: result)
    }
    
    func disconnect() async throws {
        print("[SSH Debug] Disconnecting SSH session")
        try await client?.close()
        client = nil
    }
}
