//
//  IntroVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 21/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//
//przy pierwszym uruchomieniu dluzsza animacja
import UIKit

class IntroVC: UIViewController {

    @IBOutlet weak var appIcon: UIImageView!
    
    var multiplier = 1.0
    let defaults = UserDefaults.standard

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet var labelsCollection: [UILabel]!
    @IBOutlet weak var labels: UIStackView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.alpha = 0
        appIcon.showHint(text: "Thank you for downloading our application!")
        if !defaults.bool(forKey: "firstIntroLoad"){
            multiplier = 2.0
            defaults.set(true, forKey: "firstIntroLoad")
        }
        load()
    }
    
    func load(){
        mainView.transform = CGAffineTransform(translationX: -300.0, y: 0.0)
        UIView.animate(withDuration: 0.9*multiplier) {
            self.mainView.alpha = 1
            self.mainView.transform = CGAffineTransform.identity
        }
        
        UIView.animate(withDuration: 0.8*multiplier, animations:{
            self.mainView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }){(true) in
            sleep(1)
            self.dismiss()
        }
    }
    
    func dismiss(){
        UIView.animate(withDuration: 0.8*multiplier){
            self.mainView.transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.9*multiplier, animations: {
            self.mainView.alpha = 0.0
            self.mainView.transform = CGAffineTransform(translationX: 300.0, y: 0.0)
        }) { (true) in
            self.performSegue(withIdentifier: "toFirst", sender: self)
        }
    }
}
