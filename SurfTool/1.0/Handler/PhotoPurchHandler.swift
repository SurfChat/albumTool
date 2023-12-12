//
//  PhotoPurchHandler.swift
//  SurfTool
//
//  Created by Phenou on 28/11/2023.
//

import Foundation
import SwiftyStoreKit
import StoreKit
import JFPopup

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

        JFPopupView.popup.loading()
        
        SwiftyStoreKit.purchaseProduct(model.productIdentifier, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                print("Purchase Success: \(product.productId)")
                share.checkOrder(detail: product) {
                    if let count = model.productIdentifier.components(separatedBy: ".").last {
                        var currentDate = Date()
                        var dateComponents = DateComponents()
                        dateComponents.month = 1 * (Int(count) ?? 0)
                       
                        let tillTime = PhotoKeychainHandly.vipTillTime()
                            // 之前购买过 在之前的日期上延长
                        currentDate = Date(timeIntervalSince1970: Double(tillTime) ?? 0)
                        
                      
                        if let futureDate = Calendar.current.date(byAdding: dateComponents, to: currentDate) {
                            let till = futureDate.timeIntervalSince1970
                            PhotoKeychainHandly.updateVipTillTime(timeInterva: "\(till)")
                            NotificationCenter.default.post(name: NSNotification.Name("rechargeSucNoti"), object: nil)
                        }
                    }
                }
            case .error(let error):
                DispatchQueue.main.async {
                    JFPopupView.popup.hideLoading()
                    JFPopupView.popup.toast(hit: "Purchase request failed", icon: .fail)
                }
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

        JFPopupView.popup.loading()
        
        SwiftyStoreKit.purchaseProduct(model.productIdentifier, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                share.checkOrder(detail: product) {
                    if let count = model.productIdentifier.components(separatedBy: ".").last {
                        let diamonds = Int(PhotoKeychainHandly.diamondsCount())

                        PhotoKeychainHandly.updateDiamondsCount(countStr: "\((diamonds ?? 0)+(Int(count) ?? 0))")
                       
                        NotificationCenter.default.post(name: NSNotification.Name("rechargeSucNoti"), object: nil)
                    }
                }
                print("Purchase Success: \(product.productId)")
            case .error(let error):
                DispatchQueue.main.async {
                    JFPopupView.popup.hideLoading()
                    JFPopupView.popup.toast(hit: "Purchase request failed", icon: .fail)
                }
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
    
    private func checkOrder(detail: PurchaseDetails, suc: @escaping(() -> Void)) {
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            if detail.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(detail.transaction)
            }
            DispatchQueue.main.async {
                JFPopupView.popup.hideLoading()
                switch result {
                case .success(_): do {
                    JFPopupView.popup.toast(hit: "Recharged Successfully", icon: .success)
                    suc()
                }
                case .error(let error): do {
                    JFPopupView.popup.toast(hit: "Recharge Failed", icon: .fail)
                    print("receiptData Error \(error.localizedDescription)")
                }
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
    
    static func restore() {
        JFPopupView.popup.loading()
        
        SwiftyStoreKit.restorePurchases { results in
            if results.restoreFailedPurchases.count > 0 {
                JFPopupView.popup.hideLoading()
                JFPopupView.popup.toast(hit: "Restore fail")
                
            } else if results.restoredPurchases.count > 0 {
                for restorePurch in results.restoredPurchases {
                    SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                        if restorePurch.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(restorePurch.transaction)
                        }
                        DispatchQueue.main.async {
                            JFPopupView.popup.hideLoading()
                            switch result {
                            case .success(_): do {
                                JFPopupView.popup.toast(hit: "Recharged Successfully", icon: .success)
                            }
                            case .error(let error): do {
                                JFPopupView.popup.toast(hit: "Recharge Failed", icon: .fail)
                                print("receiptData Error \(error.localizedDescription)")
                            }
                            }
                        }
                    }
                }
            } else {
                JFPopupView.popup.hideLoading()
                JFPopupView.popup.toast(hit: "Nothing to restore")
            }
        }
    }
}
