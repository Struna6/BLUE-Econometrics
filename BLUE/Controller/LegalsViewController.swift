//
//  LegalsViewController.swift
//  BLUE
//
//  Created by Karol on 25/01/2020.
//  Copyright © 2020 Karol Struniawski. All rights reserved.
//

import UIKit

class LegalsViewController : UIViewController{
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsOfUseButton: UIButton!
    @IBOutlet weak var iconsButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        privacyButton.layer.cornerRadius = 10.0
        termsOfUseButton.layer.cornerRadius = 10.0
    }
    
    @IBAction func privacyPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "http://dodocode.pl/en/index.php/econometrics-polityka-prywatnosci/")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func termsOfUsePressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "http://dodocode.pl/en/index.php/econometrics-warunki-uzytkowania/")!, options: [:], completionHandler: nil)
    }
    
    @IBAction func iconsPressed(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "https://icons8.com")!, options: [:], completionHandler: nil)
    }
    
}
