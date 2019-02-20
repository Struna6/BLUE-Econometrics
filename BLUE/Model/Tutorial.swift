//
//  Tutorial.swift
//  BLUE
//
//  Created by Karol Struniawski on 19/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import Foundation
import Tutti

extension UIView{
    var viewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let responder = responder as? UIViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
    
    func showHint(text : String){
        let hint = StandardHint(identifier: text, title: "Tutorial", text: text, userId: nil)
        let presenter = CalloutHintPresenter()
        presenter.present(hint, in: self.viewController!, from: self)
    }
}

extension UIBarButtonItem{
    func showHint(text : String, viewController : UIViewController){
        let hint = StandardHint(identifier: text, title: "Tutorial", text: text, userId: nil)
        let presenter = CalloutHintPresenter()
        presenter.present(hint, in: viewController, from: self)
    }
}




