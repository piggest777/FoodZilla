//
//  Detail VC.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-10.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit

class Detail_VC: UIViewController {
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var buyItemBtn: UIButton!
    @IBOutlet weak var hideAddButton: UIButton!
    
    public private(set) var item: Item!
    private var hiddenStatus: Bool = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseWasMade")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImageView.image = item.image
        itemNameLbl.text = item.name
        itemPriceLbl.text = String(describing: item.price)
        buyItemBtn.setTitle("You can buy this food for $ \(item.price)", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchase(_:)), name: NSNotification.Name(IapServicePurchaseNotification), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(handleFailure), name: NSNotification.Name(IapServiceFailureNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showOrHideAdds()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func showOrHideAdds()  {
        addView.isHidden = hiddenStatus
        hideAddButton.isHidden = hiddenStatus
    }
    
    @objc func handlePurchase(_ notif: Notification)  {
        guard  let productID = notif.object as? String else {
            return
        }
        
        switch productID {
        case IAP_MEAL_ID:
            buyItemBtn.isEnabled = true
            debugPrint("Meal succesfully purchased.")
            break
        case IAP_HIDE_ADDS:
            addView.isHidden = true
            hideAddButton.isHidden = true
            break
        default:
            break
        }
        
    }
    
    @objc func handleFailure() {
        buyItemBtn.isEnabled = true
    
        print("Purchase failed")
    
    }
    
    func intiData(forItem item: Item){
      self.item = item
    }
    
    @IBAction func buyItemBtnPressed(_ sender: Any) {
        buyItemBtn.isEnabled = false
        IAPService.instance.attemptPurchaseForItemWith(productIndex: .meal)
    }
    

    @IBAction func hideAdsBtnPressed(_ sender: Any) {
        IAPService.instance.attemptPurchaseForItemWith(productIndex: .hideAdds)
        
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
