//
//  PhotoPurchHandler.swift
//  SurfTool
//
//  Created by Phenou on 28/11/2023.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class PhotoPurchHandler {
    static let share = PhotoPurchHandler()
    
    var vipDatas: [SKProduct] = []
    var diamondDatas: [SKProduct] = []
    
    init() {
        let vipIds = ["surf.live.vip.1", "surf.live.vip.12"]
        
        SwiftyStoreKit.retrieveProductsInfo(Set(vipIds)) { result in
//            print(result.invalidProductIDs,result.retrievedProducts)
            if !result.retrievedProducts.isEmpty {
                for vipId in vipIds {
                    if let produuct = result.retrievedProducts.first(where: {$0.productIdentifier == vipId}) {
                        self.vipDatas.append(produuct)
                    }
                }
            }
        }
        
        let coinIds = ["surf.live.diamonds.500",
                           "surf.live.diamonds.2000",
                           "surf.live.diamonds.3500",
                           "surf.live.diamonds.8500",
                           "surf.live.diamonds.23500",
                           "surf.live.diamonds.36000"]
        
        SwiftyStoreKit.retrieveProductsInfo(Set(coinIds)) { result in
//            print(result.invalidProductIDs,result.retrievedProducts)
            if !result.retrievedProducts.isEmpty {
                for coinId in coinIds {
                    if let produuct = result.retrievedProducts.first(where: {$0.productIdentifier == coinId}) {
                        self.diamondDatas.append(produuct)
                    }
                }
            }
        }
        
    }
}
