//
//  StoreFrontVC.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-07.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit

class StoreFrontVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    

    @IBOutlet weak var foodzillaLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var subStatusLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        IAPService.instance.iapDelegate = self
        IAPService.instance.loadProduct()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(IapServiceRestoreNotification), object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.subscriptionStatusWasChange(_:)), name: Notification.Name(IAPSubInfoChangeNotification), object: nil)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IAPService.instance.isSubActive { (active) in
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func showAlert(){
        let alert = UIAlertController(title: "Success", message: "Your purchased were successfuly restored", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func subscriptionStatusWasChange(_ notification: Notification){
        guard let status = notification.object as? Bool else {
            return
        }
        DispatchQueue.main.async
                   {
        if status == true {
            self.foodzillaLbl.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.view.backgroundColor =  #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            self.collectionView.backgroundColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
            self.subStatusLbl.text = "SUB ACTIVE"
            self.subStatusLbl.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        } else {
         
            self.foodzillaLbl.textColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
            self.view.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.subStatusLbl.text = "SUB EXPIRED"
            self.subStatusLbl.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                    }
        }
    }
    

    @IBAction func subscribeBtnWasPressed(_ sender: Any) {
        IAPService.instance.attemptPurchaseForItemWith(productIndex: .montlySub)
    }
    
    
    @IBAction func questionBtnPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Restore purchases?", message: "Do you want to restore previuos purchases?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Restore", style: .default) { (action) in
            IAPService.instance.restorePurchase()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(action)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return foodItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "foodCell", for: indexPath) as? ItemCell else {
            return UICollectionViewCell()
        }
        let item = foodItems[indexPath.row]
        cell.configureCell(forItem: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? Detail_VC else { return  }
        
        let item = foodItems[indexPath.row]
        detailVC.intiData(forItem: item)
        present(detailVC, animated: true, completion: nil)
    }
}

extension StoreFrontVC: IAPServiceDelegate {
    func IAPProductsLoaded() {
        print("IAPProducts LOADED")
    }
    
    
}


