//
//  IAPService.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-10.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import Foundation
import StoreKit

protocol IAPServiceDelegate {
    func IAPProductsLoaded()
}

class IAPService: NSObject, SKProductsRequestDelegate {
    
    static let instance = IAPService()
    
    var delegate: IAPServiceDelegate?
    
    var products  = [SKProduct]()
    var productIds = Set<String>()
    var productRequest = SKProductsRequest()
    
    var nonConsumablePurchaseWasMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func loadProduct () {
        productIdsToSet()
        requestProduct(forIds: productIds)
//        print(productIds)
    }
    
    func productIdsToSet(){
        let productIds = [IAP_MEAL_ID, IAP_HIDE_ADDS, IAP_MEALTIME_MONTLY_SUB]
        for id in productIds {
             self.productIds.insert(id)
        }
       
    }
    
    func requestProduct (forIds ids: Set<String>) {
        productRequest.cancel()
        productRequest = SKProductsRequest(productIdentifiers: ids)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        self.products = response.products
//        print( "Something wrong\(response.invalidProductIdentifiers)")
//        print(products[0])
        
        if products.count == 0 {
            requestProduct(forIds: productIds)
            print("Something goes wrong")
        } else {
            delegate?.IAPProductsLoaded()
//            print(products[0].localizedTitle)
        }
    }
    
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func attemptPurchaseForItemWith(productIndex: Product){
//        print([productIndex.rawValue])
        let product = products[productIndex.rawValue]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState{
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                complete(transaction: transaction)
                sendNotifFor(status: .purchased, withIdentifire: transaction.payment.productIdentifier)
                debugPrint("Purchase was successful")
                
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                sendNotifFor(status: .failed, withIdentifire: nil)
                debugPrint("Purchase was failed")
                break
            case .deferred:
                break
            case .purchasing:
                break
                
            @unknown default:
                fatalError("Something goes wrong")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        sendNotifFor(status: .restore, withIdentifire: nil)
        setNonConsumablePurchase(true)
    }
    
    
    func complete(transaction: SKPaymentTransaction) {
        switch transaction.payment.productIdentifier {
        case IAP_MEAL_ID:
            break
        case IAP_HIDE_ADDS:
            setNonConsumablePurchase(true)
            break
        default:
            break
        }
    }
    
    func setNonConsumablePurchase(_ status: Bool){
        UserDefaults.standard.set(status, forKey: "nonConsumablePurchaseWasMade")
    }
    
    func sendNotifFor(status: PurchaseStatus, withIdentifire identifire: String?){
        switch status {
        case .purchased:
            NotificationCenter.default.post(name: NSNotification.Name(IapServicePurchaseNotification), object: identifire)
            break
        case .restore:
            NotificationCenter.default.post(name: NSNotification.Name(IapServiceRestoreNotification), object: nil)
            break
        default:
            NotificationCenter.default.post(name: NSNotification.Name(IapServiceFailureNotification), object: nil)
            break
        }
    }
    
    
}
