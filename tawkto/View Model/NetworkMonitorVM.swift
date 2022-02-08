//
//  NetworkMonitorVM.swift
//  tawkto
//
//  Created by mac on 08/02/2022.
//

import Foundation
import Network

class NetworkMonitorVM {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    var isActive = DynamicBox<Bool>(false)
    var isExpensive = false
    var isConstrained = false
    var connectionType = NWInterface.InterfaceType.other
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isActive.value = path.status == .satisfied
            self.isExpensive = path.isExpensive
            if #available(iOS 13.0, *) {
                self.isConstrained = path.isConstrained
            } else {
                // Fallback on earlier versions
            }
            
            let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
            self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
        }
        
        monitor.start(queue: queue)
    }
}
