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
    
    static func startBuyVip(model: SKProduct) {
        
        SwiftyStoreKit.purchaseProduct(model.productIdentifier, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                print("Purchase Success: \(product.productId)")
                share.checkOrder(detail: product)
                
                NotificationCenter.default.post(name: NSNotification.Name("rechargeSucNoti"), object: nil)
                
            case .error(let error):

                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    static func startBuyCoin(model: SKProduct) {
      
        SwiftyStoreKit.purchaseProduct(model.productIdentifier, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                share.checkOrder(detail: product)
                print("Purchase Success: \(product.productId)")
            case .error(let error):
               
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
    
    private func checkOrder(detail: PurchaseDetails) {
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            switch result {
            case .success(let receiptData): do {
                let receiptStr = receiptData.base64EncodedString(options: .endLineWithLineFeed)

            }
            case .error(let error): do {
//                FTYBaseHandler.hideLoadingFail(text: FTYLanguageHandler.fty_localizedString("Rechargefailed"))
                print("receiptData Error \(error.localizedDescription)")
            }
            }
        }
    }
    
    func purchesComplete() {
        SwiftyStoreKit.completeTransactions { purchases in
            print(purchases)
            if !purchases.isEmpty {
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored: do {
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                    }
                    case .deferred, .purchasing, .failed: break
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
}
