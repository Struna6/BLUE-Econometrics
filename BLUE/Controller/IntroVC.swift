//
//  IntroVC.swift
//  BLUE
//
//  Created by Karol Struniawski on 21/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import Lottie

class IntroVC: UIViewController {

    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var whiteView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        appIcon.showHint(text: "Thank you for downloading our application!")
        
    }
}
