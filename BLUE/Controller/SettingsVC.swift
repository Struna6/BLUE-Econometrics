//
//  SettingsVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 18/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, Storage, ErrorScreenPlayable {

    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var isPremium: UILabel!
    @IBOutlet var pickers: [UISwitch]!
    @IBOutlet weak var buyPremiumButton: UIButton!
    
    @IBOutlet weak var premiumImage: UIImageView!
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
                visualViewToBlur.frame = self.view.frame
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
        if defaults.bool(forKey: "premium"){
            isPremium.text = "premium"
            buyPremiumButton.isEnabled = false
            buyPremiumButton.backgroundColor = UIColor.gray
            premiumImage.isHidden = true
        }else{
            isPremium.text = "normal"
            pickers.forEach(){
                if $0.tag == 0{
                    $0.isEnabled = false
                    $0.setOn(false, animated: false)
                    $0.isOn = false
                    $0.onTintColor = UIColor.gray
                }
            }
        }
        
        pickers.forEach(){
            if $0.tag == 0 && defaults.bool(forKey: "premium"){
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
        if sender.tag == 0 && defaults.bool(forKey: "premium"){
            defaults.set(sender.isOn, forKey: "longPress")
        }else if sender.tag == 1{
            defaults.set(sender.isOn, forKey: "animations")
        }else if sender.tag == 2{
            defaults.set(sender.isOn, forKey: "autoSave")
            if sender.isOn{
                let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                documentPicker.delegate = self
                documentPicker.modalPresentationStyle = .formSheet
                present(documentPicker, animated: true, completion:  nil)
            }else{
                defaults.removeObject(forKey: "externalPathToAutoSave")
                defaults.removeObject(forKey: "autoSave")
                defaults.synchronize()
            }
        }
    }
    
    //add premium functionality
    @IBAction func buyPremium(_ sender: UIButton) {
        defaults.set(true, forKey: "premium")
        self.dismiss(animated: true, completion: nil)
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
