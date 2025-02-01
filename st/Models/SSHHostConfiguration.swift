//
//  SSHHostConfiguration.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//

import Foundation

struct SSHHostConfiguration: Codable, Identifiable {
    var id = UUID()
    let hostname: String
    let username: String
    let password: String
    let port: Int
    
    // Add validation
    var isValid: Bool {
        !hostname.isEmpty &&
        !username.isEmpty &&
        !password.isEmpty &&
        port > 0 && port <= 65535
    }
    
    static let example = SSHHostConfiguration(
        hostname: "localhost",
        username: "0x00daemon",
        password: "your-password",
        port: 22
    )
}
