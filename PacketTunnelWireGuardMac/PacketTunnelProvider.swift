//
//  PacketTunnelProvider.swift
//  PacketTunnelWireGuardMac
//
//  Copyright © AtomSDKBySecure 2026 Atom. All rights reserved.
//

import NetworkExtension
import AtomWireGuardAppExtension

class PacketTunnelProvider: WireGuardTunnelProvider {

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        super.startTunnel(options: options, completionHandler: completionHandler)
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        super.stopTunnel(with: reason, completionHandler: completionHandler)
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        super.handleAppMessage(messageData, completionHandler: completionHandler)
    }
}
