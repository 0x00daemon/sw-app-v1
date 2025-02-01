//
//  SSHConfigurationStore.swift
//  st
//
//  Created by xdaem0n on 1/31/25.
//

import Foundation

class SSHConfigurationStore {
    private let defaults = UserDefaults.standard
    private let key = "ssh_configurations"
    
    func saveConfiguration(_ config: SSHHostConfiguration) {
        var configs = getAllConfigurations()
        configs.append(config)
        
        if let encoded = try? JSONEncoder().encode(configs) {
            defaults.set(encoded, forKey: key)
        }
    }
    
    func getAllConfigurations() -> [SSHHostConfiguration] {
        guard let data = defaults.data(forKey: key),
              let configs = try? JSONDecoder().decode([SSHHostConfiguration].self, from: data) else {
            return []
        }
        return configs
    }
}
