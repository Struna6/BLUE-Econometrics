//
//  OtherProtocols.swift
//  BLUE
//
//  Created by Karol Struniawski on 24/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation
import UIKit
import Darwin
import Lottie
import SpreadsheetView


protocol QuantileCalculable{
    func quantile(n: Double, _ numbers: [Double]) -> Double
}
extension QuantileCalculable{
    func quantile(n: Double, _ numbers: [Double]) -> Double{
        var nums = numbers
        nums.sort(by: {$0 < $1})
        let n1 = Int(floor(Double(numbers.count)*n))
        let n2 = Int(floor(Double(numbers.count)*n))
        return (nums[n1]+nums[n2]) / 2
    }
}

protocol oddObservationQuantileSpotter : QuantileCalculable {
    func calculateNumberOfOddObservations() -> Int
}
extension oddObservationQuantileSpotter where Self==Model {
    func calculateNumberOfOddObservations() -> Int{
        var sum = 0
        for i in 0..<allObservations[0].observationArray.count{
            var tmp = [Double]()
            allObservations.forEach { (obs) in
                tmp.append(obs.observationArray[i])
            }
            let q1=quantile(n: 0.25, tmp)
            let q3=quantile(n: 0.75, tmp)
            tmp.forEach { (num) in
                if num > q3+(1.5*(q3-q1)) || num < q1-(1.5*(q3-q1)){
                    sum = sum + 1
                }
            }
        }
        return sum
    }
}

protocol Statisticable{
    func incompleteGammaF(s : Double, z : Double) -> Double
    func chiICDF(x : Double, k : Double) -> Double
    func betaValue(x : Double, a : Double, b : Double) -> Double
    func betaIncomplete(x : Double, a : Double, b : Double) -> Double
    func betaComplete(a : Double, b : Double) -> Double
    func betaRegularizedIncomplete(x : Double, a : Double, b : Double) -> Double
    func FSnedeccorCDF(f : Double, d1 : Double, d2 : Double) -> Double
    func TStudentCDF(t : Double, v : Double) -> Double
    func normalValue(x: Double) -> Double
    func normalCDF(x: Double) -> Double
    func normalInverseCDF(p : Double) -> Double
}

extension Statisticable{
    func incompleteGammaF(s : Double, z : Double) -> Double{
        var s = s
        if z < 0.0{
            return 0.0
        }
        var sc = 1.0 / s
        sc = sc * pow(z,s)
        sc = sc * exp(-z)
        
        var sum = 1.0
        var nom = 1.0
        var denom = 1.0
        
        for _ in 0..<200{
            nom = nom * z
            s = s + 1
            denom = denom * s
            if (nom/denom).isNaN{
                break
            }
            sum = sum + (nom/denom)
        }
        return sum * sc
    }
    
    func chiICDF(x : Double, k : Double) -> Double{
        let upper = incompleteGammaF(s: k/2, z: x/2)
        let result = upper/tgamma(k/2)
        return result > 1 ? 1 : result
    }
     
    func betaValue(x : Double, a : Double, b : Double) -> Double{
        return pow(x, (a - 1)) * pow((1 - x), (b - 1))
    }
    
    func betaIncomplete(x : Double, a : Double, b : Double) -> Double{
        let width = (x - 0) / 200
        var result : Double = 0
        var i : Double = 0
        while i < x{
            result = result + (betaValue(x: i, a: a, b: b) * width)
            i = i + width
        }
        return result
    }
    
    func betaComplete(a : Double, b : Double) -> Double{
        return (tgamma(a)*tgamma(b))/tgamma(a+b)
    }
    
    func betaRegularizedIncomplete(x : Double, a : Double, b : Double) -> Double{
        return betaIncomplete(x: x, a: a, b: b)/betaComplete(a: a, b: b)
    }
    
    func FSnedeccorCDF(f : Double, d1 : Double, d2 : Double) -> Double{
        let x = (d1*f)/((d1*f)+d2)
        let result = betaRegularizedIncomplete(x: x, a: d1/2, b: d2/2)
        return result > 1 ? 1 : result
    }
    
    func TStudentCDF(t : Double, v : Double) -> Double{
        let x = v/((t*t) + v)
        let result =  1 - 0.5*betaRegularizedIncomplete(x: x, a: v/2, b: 0.5)
        return result > 1 ? 1 : result
    }
    
    func normalValue(x: Double) -> Double{
        return exp(-(x*x)/2)
    }
    
    func normalCDF(x: Double) -> Double{
        if x < -5{
            return 0
        }
        let width = (x + 5) / 200
        var result : Double = 0
        var i : Double = -5
        while i < x{
            result = result + (normalValue(x: i)*width)
            i = i + width
        }
        return result / (sqrt(2*Double.pi))
    }
    
    func normalInverseCDF(p : Double) -> Double{
        if p < 0 || p > 1{
            return Double.nan
        }
        let width : Double = 16 / 1000
        var i : Double = -8
        var result : Double = 0
        let pTmp = p * sqrt(2*Double.pi)
        while true{
            result = result + (normalValue(x: i)*width)
            if result >= pTmp{
                return i
            }
            i = i + width
        }
    }
}


protocol PlayableLoadingScreen{
    var ifCanPlay : Bool {get}
    
    func playLoadingAsync(tasksToDoAsync: @escaping () -> Void, tasksToMainBack: @escaping () -> Void, mainView : UIView)
    
    func playShortAnimationOnce(mainViewController : UIViewController, animationName : String?)
}

extension PlayableLoadingScreen{
    var ifCanPlay : Bool {
        get{
            let defaults = UserDefaults.standard
            return defaults.bool(forKey: "animations")
        }
    }
    
    func playLoadingAsync(tasksToDoAsync: @escaping () -> Void, tasksToMainBack: @escaping () -> Void, mainView : UIView){
        let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualViewToBlur.frame = mainView.frame
        visualViewToBlur.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.54, alpha:0.2)
        mainView.addSubview(visualViewToBlur)
        
        let animationView = LOTAnimationView(name: "loading")
        animationView.loopAnimation = true
        animationView.sizeToFit()
        animationView.layer.cornerRadius = 18.0
        animationView.clipsToBounds = true
        animationView.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.54, alpha:0.5)
        animationView.alpha = 0.7
        mainView.addSubview(animationView)
        animationView.frame = CGRect(x: mainView.bounds.midX, y: mainView.bounds.midY, width: 400, height: 400)
        animationView.center = CGPoint(x: mainView.bounds.midX, y: mainView.bounds.midY)
        animationView.play()
        Dispatch.DispatchQueue.global(qos: .utility).async {
            tasksToDoAsync()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    visualViewToBlur.backgroundColor = UIColor.clear
                }
                visualViewToBlur.removeFromSuperview()
                tasksToMainBack()
                animationView.stop()
                animationView.removeFromSuperview()
            }
        }
    }
    
    func playShortAnimationOnce(mainViewController : UIViewController, animationName : String? = "done"){
        if ifCanPlay{
            let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            visualViewToBlur.frame = mainViewController.view.frame
            visualViewToBlur.isHidden = true
            //visualViewToBlur.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.54, alpha:0.2)
            
            UIView.animate(withDuration: 0.05) {
                visualViewToBlur.isHidden = false
                mainViewController.view.addSubview(visualViewToBlur)
            }
            
            let animationView = LOTAnimationView(name: animationName!)
            mainViewController.view.addSubview(animationView)
            animationView.loopAnimation = false
            animationView.sizeToFit()
            animationView.layer.cornerRadius = 18.0
            animationView.autoReverseAnimation = false
            animationView.clipsToBounds = true
            animationView.animationSpeed = 1.5
            animationView.center = CGPoint(x: mainViewController.view.bounds.midX, y: mainViewController.view.bounds.midY)
            
            animationView.play(fromProgress: 0.0, toProgress: 0.7, withCompletion: { (complete: Bool) in
                animationView.stop()
                UIView.animate(withDuration: 0.05) {
                    visualViewToBlur.isHidden = true
                    visualViewToBlur.removeFromSuperview()
                    animationView.removeFromSuperview()
                }
            })
        }
    }
}

protocol ErrorScreenPlayable{
    func playErrorScreen(msg : String, blurView: UIVisualEffectView, mainViewController : UIViewController, alertToDismiss : UIAlertController?)
}

extension ErrorScreenPlayable{
    func playErrorScreen(msg : String, blurView: UIVisualEffectView, mainViewController : UIViewController, alertToDismiss : UIAlertController?){
        if (alertToDismiss != nil){
            alertToDismiss!.dismiss(animated: true, completion: nil)
        }
        let alertController = UIAlertController.init(title: "Error", message: msg, preferredStyle: .alert)
        mainViewController.present(alertController,animated: true,completion: {
            sleep(1)
            alertController.dismiss(animated: true) {
                blurView.effect = nil
                blurView.isHidden = true
            }
        })
    }
}

class LongTappableToSaveContext : NSObject, Storage, ErrorScreenPlayable, PlayableLoadingScreen{
    var object : AnyObject?
    var viewToBlur : UIVisualEffectView?
    var targetViewController : UIViewController?
    
    override init(){
        self.object = nil
        self.viewToBlur = nil
        self.targetViewController = nil
    }
    init(newObject : AnyObject, toBlur : UIVisualEffectView, targetViewController : UIViewController){
        super.init()
        self.object = newObject
        self.viewToBlur = toBlur
        self.targetViewController = targetViewController
    }
    
    @objc func longTapOnObject(sender: UIGestureRecognizer){
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "longPress"){
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            button.center = self.object!.center
            button.backgroundColor = UIColor(red:0.78, green:0.76, blue:0.98, alpha: 0.8)
            button.layer.borderWidth = 1.0
            let image = UIImage.init(named: "upload")
            let imageFilled = UIImage.init(named: "upload_filled")
            button.setImage(image, for: .normal)
            button.setImage(imageFilled, for: .selected)
            button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 25, right: 20)
            addActionsToButton(btn : button)
            
            //button.imageView?.contentMode = UIView.ContentMode.center
            if sender.state == .began{
                sender.isEnabled = false
                let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
                pulseAnimation.duration = 1.2
                pulseAnimation.toValue = NSNumber(value: 1.08)
                pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                pulseAnimation.autoreverses = true
                pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.object!.layer.borderWidth = 0.8
                    self.object!.layer.opacity = 0.8
                })
                self.targetViewController!.view.bringSubviewToFront(object! as! UIView)
                self.object!.layer.add(pulseAnimation, forKey: "scale")
                self.targetViewController!.view.addSubview(button)
                
                Dispatch.DispatchQueue.global(qos: .background).async {
                    sleep(3)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 1.0, animations: {
                            button.alpha = 0.0
                            self.object!.layer.borderWidth = 0.0
                            self.object!.layer.opacity = 1.0
                        })
                        self.object!.layer.removeAllAnimations()
                        sender.isEnabled = true
                        self.targetViewController!.view.subviews.forEach(){
                            if $0 is UIButton{
                                $0.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func addActionsToButton(btn : UIButton){
        btn.isUserInteractionEnabled = true
        if object is UILabel{
            let tapToSave = UITapGestureRecognizer(target: self, action: #selector(self.saveFromLabel))
            btn.addGestureRecognizer(tapToSave)
        }else if object is UITableView{
            let tapToSave = UITapGestureRecognizer(target: self, action: #selector(self.saveFromTable))
            btn.addGestureRecognizer(tapToSave)
        }else if object is SpreadsheetView{
            let tapToSave = UITapGestureRecognizer(target: self, action: #selector(self.saveFromSpreadsheet))
            btn.addGestureRecognizer(tapToSave)
        }else if object is UIView{
            let tapToSave = UITapGestureRecognizer(target: self, action: #selector(self.saveFromChart))
            btn.addGestureRecognizer(tapToSave)
        }
    }
    
    @objc func saveFromLabel(){
        inputPopUp {
            let label = self.object as! UILabel
            label.backgroundColor = UIColor.white
            label.alpha = 1.0
            label.layer.opacity = 1.0
            label.layer.borderWidth = 0.0
            let result = UIImage.imageWithLabel(label: label)
            return result
        }
    }
    
    @objc func saveFromTable(){
        inputPopUp {
            let tableView = self.object as! UITableView
            tableView.backgroundColor = UIColor.white
            tableView.alpha = 1.0
            tableView.layer.opacity = 1.0
            tableView.layer.borderWidth = 0.0
            if (tableView.indexPathForSelectedRow != nil){
                tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
            }
            let result = UITableView.saveWholeTable(tableView: tableView)
            return result
        }
    }
    
    @objc func saveFromSpreadsheet(){
        inputPopUp {
            let sp = self.object as! SpreadsheetView
            sp.backgroundColor = UIColor.white
            sp.deselectItem(at: sp.indexPathForSelectedItem!, animated: false)
            sp.alpha = 1.0
            sp.layer.opacity = 1.0
            sp.layer.borderWidth = 0.0
            let result = UIView.save(view: sp)
            return result
        }
    }
    
    @objc func saveFromChart(){
        inputPopUp {
            let chart = self.object as! UIView
            chart.backgroundColor = UIColor.white
            chart.alpha = 1.0
            chart.layer.opacity = 1.0
            let picker = chart.viewWithTag(2)
            chart.subviews.forEach(){
                if $0 is UIButton{
                    $0.removeFromSuperview()
                }
            }
            chart.layer.borderWidth = 0.0
            picker?.isHidden = true
            let result = UIView.save(view: chart)
            picker?.isHidden = false
            return result
        }
    }
    
    private func inputPopUp(toDo : @escaping () -> UIImage){
        let alertInput = UIAlertController(title: "File name", message: "Image saved to clipboard, if you want to save it to file give it a file name:", preferredStyle: .alert)
        alertInput.addTextField(configurationHandler: nil)
        let image = toDo()
        
        let alertInputOK = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            if let newText = alertInput.textFields![0].text{
                if newText.count > 0{
                    image.save(newText+".png")
                    self.playShortAnimationOnce(mainViewController: self.targetViewController!)
                }else{
                    self.playErrorScreen(msg: "Wrong format of data!", blurView: self.viewToBlur!, mainViewController: self.targetViewController!, alertToDismiss : alertInput)
                }
            }
        })
        alertInput.addAction(alertInputOK)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { alert in
            self.copyToClipboard(image)
        })
        alertInput.addAction(cancelAction)
        
        targetViewController!.present(alertInput,animated: true, completion: nil)
    }
    
    private func copyToClipboard(_ image : UIImage){
        //UIPasteboard.general.image = image
        UIPasteboard.typeListImage.adding(image)
    }
}


extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func save(_ name: String){
        let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let url = URL(fileURLWithPath: path).appendingPathComponent("/Saved Models/Screenshots/" + name)
        try! self.pngData()?.write(to: url)
        print("saved image at \(url)")
    }
}

extension UITableView{
    class func saveWholeTable(tableView : UITableView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize(width:tableView.contentSize.width, height:tableView.contentSize.height),false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        let previousFrame = tableView.frame
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.contentSize.width, height: tableView.contentSize.height)
        tableView.layer.render(in: context!)
        tableView.frame = previousFrame
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

extension UIScrollView{
    class func saveWholeView(scrollView : UIScrollView) -> UIImage?
    {
        UIGraphicsBeginImageContext(scrollView.contentSize)
        
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame
        
        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIView{
    class func save(view : UIView) -> UIImage{
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImage(cgImage: image!.cgImage!)
    }
}

extension String {
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_[]{}@#$%^&*\n \t;")
        return self.filter {okayChars.contains($0) }
    }
}

//make storyboard option to edit rounded edges
@IBDesignable extension UIButton{
    @IBInspectable var cordnerRadius : CGFloat{
        set{
            layer.cornerRadius = newValue
        }
        get{
            return layer.cornerRadius
        }
    }
    @IBInspectable var cornerWidth : CGFloat{
        set{
            layer.borderWidth = newValue
        }
        get{
            return layer.borderWidth
        }
    }
}


import Surge
import Accelerate

//MY INV TO IGNORE nonsingular MATRIXES and make them invertible anyway

public func myInv(_ x : Matrix<Double>) -> Matrix<Double> {
    precondition(x.rows == x.columns, "Matrix must be square")
    var results = x
    
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CDouble](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var mc = __CLPK_integer(x.columns)
    var nc = __CLPK_integer(x.rows)
    var lda = __CLPK_integer(x.columns)
    
    dgetrf_(&mc, &nc, &(results.grid), &lda, &ipiv, &error)
    
    if error == 1{
        var tmp = Array(repeating: Array(repeating: 0.0, count: x.rows), count: x.rows)
        for i in 0..<x.rows{
            tmp[i][i] = 0.0001
        }
        let newX = add(x, y: Matrix(tmp))
        return myInv(newX)
    }else{
        dgetri_(&nc, &(results.grid), &lda, &ipiv, &work, &lwork, &error)
        return results
    }
}
