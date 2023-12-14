//
//  PhotoKeychainHandly.swift
//  SurfTool
//
//  Created by Phenou on 12/12/2023.
//

import Foundation
import KeychainAccess

let VipTillTimeKey = "sadAlbumVipTill"
let DiamondCountKey = "sadAlbumDiamondsBalance"
let KeychainService = "comSurfChatTool"

class PhotoKeychainHandly {
    
    /// vip过期时间 时间戳
    static func updateVipTillTime(timeInterva: String) {
        let keychain = Keychain(service:KeychainService)
        try? keychain.set(timeInterva, key: VipTillTimeKey)
    }
    
    static func updateDiamondsCount(countStr: String) {
        let keychain = Keychain(service:KeychainService)
        try? keychain.set(countStr, key: DiamondCountKey)
    }
    
    static func vipTillTime() -> String {
        let keychain = Keychain(service:KeychainService)
        if let value = try? keychain.get(VipTillTimeKey) {
            return value
        } else {
            return "0"
        }
        
    }
    
    static func diamondsCount() -> String {
        let keychain = Keychain(service:KeychainService)
        if let value = try? keychain.get(DiamondCountKey) {
            return value
        } else {
            return "0"
        }
    }
    
    static func deleteVipInfo() {
        let keychain = Keychain(service:KeychainService)
        try? keychain.remove(VipTillTimeKey)
    }
}
