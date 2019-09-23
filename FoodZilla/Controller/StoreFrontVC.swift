//
//  StoreFrontVC.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-07.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit

class StoreFrontVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        IAPService.instance.delegate = self
        IAPService.instance.loadProduct()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showAlert), name: NSNotification.Name(IapServiceRestoreNotification), object: nil)
    }
    
    @objc func showAlert(){
        let alert = UIAlertController(title: "Success", message: "Your purchased were successfuly restored", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    @IBAction func subscribeBtnWasPressed(_ sender: Any) {
        
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


