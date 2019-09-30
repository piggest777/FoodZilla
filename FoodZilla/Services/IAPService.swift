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

class IAPService: SKReceiptRefreshRequest, SKProductsRequestDelegate {
    
    static let instance = IAPService()
    
    var iapDelegate: IAPServiceDelegate?
    
    var products  = [SKProduct]()
    var productIds = Set<String>()
    var productRequest = SKProductsRequest()
    
    
    var expirationDate = UserDefaults.standard.value(forKey: "expirationDate") as? Date
    var nonConsumablePurchaseWasMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")
    
//    override init() {
//        super.init()
//        SKPaymentQueue.default().add(self)
//    }
    
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
            iapDelegate?.IAPProductsLoaded()
//            print(products[0].localizedTitle)
        }
    }
    
    func restorePurchase(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        uploadReceipt { (valid) in
            if valid {
                debugPrint("SUB VALID!")
//                check if sub still valid
                self.isSubActive { (active) in
                    if active {
                        debugPrint("SUB ACTIVE!")
                        self.sendNotifFor(status: .subscribe, withIdentifire: nil, orBoolean: true)
                        self.setNonConsumablePurchase(true)
                    } else {
                        debugPrint("SUB EXPIRED!")
                        self.sendNotifFor(status: .subscribe, withIdentifire: nil, orBoolean: false)
                        self.setNonConsumablePurchase(false)
                    }
                }
            } else {
                debugPrint("SUB INVALID!")
                    self.sendNotifFor(status: .subscribe, withIdentifire: nil, orBoolean: false)
                    self.setNonConsumablePurchase(false)
            }
        }
    }
    
    func isSubActive(completionHandler: @escaping (Bool) -> Void) {
        reloadExpiryDate()
        let nowDate = Date()
        debugPrint("Time remaining:", (expirationDate?.timeIntervalSinceNow)! / 60)
        guard let expirationDate = expirationDate else { return }
        if nowDate.isLessThan(expirationDate) {
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }
    
    func uploadReceipt(completionHandler: @escaping (Bool) -> Void){
        guard let receiptUrl = Bundle.main.appStoreReceiptURL, let receipt = try? Data(contentsOf: receiptUrl).base64EncodedString() else {
            debugPrint("No receipt URL")
            completionHandler(false)
            return
        }
        
//        print(receipt)
        
        let body = [
            "receipt-data": receipt,
            "password": appSecret
        ]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, responce, error) in
            if let error = error {
                debugPrint("ERROR: ", error)
                completionHandler(false)
            } else  if let responseData = responseData{
//                debugPrint(responseData.description)
                let json = try! JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! Dictionary<String, Any>
                let newExpirationDate = self.expirationDateFromResponce(jsonResponse: json )
                self.setExpiretion(forDate: newExpirationDate!)
//                debugPrint("New expiration date ", newExpirationDate!)
//                print(json)
                completionHandler(true)
            }
        }
        task.resume()
    }
    
    func expirationDateFromResponce (jsonResponse: Dictionary<String, Any>) -> Date? {
        if let reciepInfo: NSArray = jsonResponse["latest_receipt_info"] as? NSArray {
            let lastReciept = reciepInfo.lastObject as! Dictionary<String, Any>
            print("This is a \(lastReciept)")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            let expirationDate: Date  = (formatter.date(from: lastReciept["expires_date"] as! String)!)
            print(expirationDate)
            return expirationDate
        } else {
            return nil
        }
    }
    
    func setExpiretion(forDate date: Date) {
        UserDefaults.standard.set(date, forKey: "expirationDate")
    }
    
    func reloadExpiryDate() {
        expirationDate = UserDefaults.standard.value(forKey: "expirationDate") as? Date
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
                complete(transaction: transaction)
                 SKPaymentQueue.default().finishTransaction(transaction)
//                uploadReceipt { (valid) in
//
//                }
                debugPrint("Purchase was successful")
                
//                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                
                sendNotifFor(status: .failed, withIdentifire: nil, orBoolean: nil)
                SKPaymentQueue.default().finishTransaction(transaction)
                debugPrint("Purchase was failed", transaction.error)
                break
            case .deferred:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing:
                debugPrint("Purchasing...")
                break
                
            @unknown default:
                fatalError("Something goes wrong")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        sendNotifFor(status: .restore, withIdentifire: nil, orBoolean: nil)
        setNonConsumablePurchase(true)
    }
    
    
    func complete(transaction: SKPaymentTransaction) {
        switch transaction.payment.productIdentifier {
        case IAP_MEALTIME_MONTLY_SUB:
            sendNotifFor(status: .subscribe, withIdentifire: nil, orBoolean: true)
            setNonConsumablePurchase(true)
            break
        case IAP_MEAL_ID:
            sendNotifFor(status: .purchased, withIdentifire: transaction.payment.productIdentifier, orBoolean: nil)
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
    
    func sendNotifFor(status: PurchaseStatus, withIdentifire identifire: String?, orBoolean bool: Bool?){
        switch status {
        case .purchased:
            NotificationCenter.default.post(name: NSNotification.Name(IapServicePurchaseNotification), object: identifire)
            break
        case .restore:
            NotificationCenter.default.post(name: NSNotification.Name(IapServiceRestoreNotification), object: nil)
            break
        case .subscribe:
            NotificationCenter.default.post(name: NSNotification.Name(IAPSubInfoChangeNotification), object: bool)
            break
        default:
//            NotificationCenter.default.post(name: NSNotification.Name(IAPSubInfoChangeNotification), object: bool)
            break
        }
    }
    
    
}
