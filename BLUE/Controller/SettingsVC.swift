//
//  SettingsVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 18/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import Purchases

protocol SettingsVCDelegate : class {
    func removeAds()
}

class SettingsVC: UIViewController, Storage, ErrorScreenPlayable {
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var isPremium: UILabel!
    @IBOutlet var pickers: [UISwitch]!
    @IBOutlet weak var buyPremiumButton: UIButton!
    @IBOutlet weak var premiumImage: UIImageView!
    weak var delegate : SettingsVCDelegate?
    var blur : UIVisualEffectView?
    var chosenDirectory = String(){
        didSet{
            var dir = URL(fileURLWithPath: chosenDirectory)
            dir.deleteLastPathComponent()
            defaults.set(dir, forKey: "externalPathToAutoSave")
            do{
                try copyToChosenExternalPath()
            }catch let er as SavingErrors{
                defaults.removeObject(forKey: "externalPathToAutoSave")
                defaults.removeObject(forKey: "autoSave")
                defaults.synchronize()
                pickers.forEach(){
                    if $0.tag == 2{
                        $0.isOn = false
                    }
                }
                let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                visualViewToBlur.frame = self.view.bounds
                visualViewToBlur.isHidden = true
                self.view.addSubview(visualViewToBlur)
                
                playErrorScreen(msg: er.rawValue, blurView: visualViewToBlur, mainViewController: self, alertToDismiss: nil)
            }catch{
                
            }
        }
    }
    let defaults = UserDefaults.standard
    
    //add premium functionality
    override func viewDidLoad() {
        popUpView.layer.cornerRadius = 10
        super.viewDidLoad()
        self.view.addSubview(popUpView)
        popUpView.alpha = 0
        popUpView.center = self.view.center
        popUpView.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.popUpView.alpha = 1
            self.popUpView.transform = CGAffineTransform.identity
        }
        if !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            isPremium.text = "premium"
            buyPremiumButton.isEnabled = false
            buyPremiumButton.backgroundColor = UIColor.gray
            restoreButton.isEnabled = false
            restoreButton.backgroundColor = UIColor.gray
            premiumImage.isHidden = true
            buyPremiumButton.isHidden = true
            restoreButton.isHidden = true
        }else{
            if let product = (UIApplication.shared.delegate as? AppDelegate)?.offer{
                let title = product.product.localizedTitle + " for " + product.localizedPriceString
                buyPremiumButton.setTitle(title, for: .normal)
            }else{
                buyPremiumButton.isEnabled = false
                buyPremiumButton.backgroundColor = UIColor.gray
                buyPremiumButton.setTitle("Purchase unavailable", for: .normal)
            }
            
            isPremium.text = "normal"
            pickers.forEach(){
                if $0.tag == 0 || $0.tag == 2{
                    $0.isEnabled = false
                    $0.setOn(false, animated: false)
                    $0.isOn = false
                    $0.onTintColor = UIColor.gray
                }
            }
        }
        
        pickers.forEach(){
            if $0.tag == 0 && !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
                if let val = defaults.bool(forKey: "longPress") as Bool?{
                    $0.isOn = val
                }else{
                    $0.isOn = false
                }
            }else if $0.tag == 1{
                if let val = defaults.bool(forKey: "animations") as Bool?{
                    $0.isOn = val
                }else{
                    $0.isOn = false
                }
            }else if $0.tag == 2{
                if let val = defaults.bool(forKey: "autoSave") as Bool?{
                    $0.isOn = val
                }else{
                    $0.isOn = false
                }
            }else{
                $0.isOn = false
            }
        }
    }
    
    @IBAction func closeWindow(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.popUpView.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.popUpView.alpha = 0
        }) { (success) in
            self.popUpView.removeFromSuperview()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //ADD documentPickerForAutoSaving
    @IBAction func switchPressed(_ sender: UISwitch) {
        if sender.tag == 0 && !(UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible{
            defaults.set(sender.isOn, forKey: "longPress")
        }else if sender.tag == 1{
            defaults.set(sender.isOn, forKey: "animations")
        }else if sender.tag == 2{
            defaults.set(sender.isOn, forKey: "icloudSave")
        }
    }

    @IBAction func buyPremium(_ sender: UIButton) {
        showBlur()
        guard let product = (UIApplication.shared.delegate as? AppDelegate)?.offer else {
            purchaseInfo(title: "Failed!", subtitle: "No subscription options are available now, please try again later", success: false)
            return
        }
        
        Purchases.shared.purchasePackage(product) {[weak self] (transaction, purchaserInfo, error, userCancelled) in
            if (purchaserInfo?.nonConsumablePurchases.count ?? -1) > 0{
                self?.purchaseInfo(title: "Succed!", subtitle: "Thank you for making a purchase!", success: true)
            }else{
                self?.purchaseInfo(title: "Failed!", subtitle: "Unable to proceed your purchase", success: false)
            }
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: Any) {
        showBlur()
        
        Purchases.shared.restoreTransactions { [weak self] (purchaserInfo, error) in
            if (purchaserInfo?.nonConsumablePurchases.count ?? -1) > 0{
                self?.purchaseInfo(title: "Succed!", subtitle: "Product restored!", success: true)
            }else{
                self?.purchaseInfo(title: "Failed!", subtitle: "No products to be restored", success: false)
            }
        }
    }
    
    private func showBlur(){
        blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blur?.frame = view.frame
        blur?.center = view.center
        let loader = UIActivityIndicatorView(style: .large)
        loader.center = blur!.center
        blur?.contentView.addSubview(loader)
        loader.startAnimating()
        blur?.alpha = 0.0
        view.addSubview(blur!)
        UIView.animate(withDuration: 0.2) {
            self.blur!.alpha = 1.0
        }
    }
    
    private func hideBlur(){
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.blur?.alpha = 0.0
        }) { [weak self] (_) in
            self?.blur?.removeFromSuperview()
        }
    }
    
    private func purchaseInfo(title: String, subtitle: String, success: Bool){
        let controller = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
            if success{
                (UIApplication.shared.delegate as! AppDelegate).adProvider.adsShouldBeVisible = false
                self?.defaults.set(true, forKey: "longPress")
                self?.delegate?.removeAds()
                self?.hideBlur()
            }
        }
        controller.addAction(ok)
        present(controller, animated: true)
    }
}

extension SettingsVC : UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        controller.allowsMultipleSelection = false
        chosenDirectory = urls[0].path
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        pickers.forEach(){
            if $0.tag == 2{
                $0.isOn = false
            }
        }
        defaults.removeObject(forKey: "externalPathToAutoSave")
        defaults.removeObject(forKey: "autoSave")
        defaults.synchronize()
    }
}
