//
//  TableViewControllerSorted.swift
//  BLUE
//
//  Created by Karol Struniawski on 03/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit
import AVKit

class TableViewControllerSorted: UIViewController {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var popUpWindow: UIView!
    @IBOutlet weak var viewToBlur: UIVisualEffectView!
    @IBOutlet weak var textHelpWindow: UILabel!
    @IBOutlet weak var imageHelpWindow: UIImageView!
    @IBOutlet weak var labelHelpWindow: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    var pickerSections = [String]()
    var selectedVariable = "All"
    var selectedParameterSection = 0
    var selectedParameterPosition = 0
    let tableSections = ["Critical","Warning","Normal","Uncalculable","Uncategorised"]
    var isShortParameters = true
    //  IF SHORT PARAMETERS
    //Main parameter
    var mainModelParameter = [ModelParameters]()
    //Short parameters
    var parametersResultsShort = [ModelParametersShort]()
    var criticalParametersShort : [ModelParametersShort]{
        get{
            return self.parametersResultsShort.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Critical"
                }else{
                    return $0.category.rawValue == "Critical" && $0.variable == selectedVariable
                }
            })
        }
    }
    var warningParametersShort : [ModelParametersShort]{
        get{
            return self.parametersResultsShort.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Warning"
                }else{
                    return $0.category.rawValue == "Warning" && $0.variable == selectedVariable
                }
            })
        }
    }
    var normalParametersShort : [ModelParametersShort]{
        get{
            return self.parametersResultsShort.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Normal"
                }else{
                    return $0.category.rawValue == "Normal" && $0.variable == selectedVariable
                }
            })
        }
    }
    var nanParametersShort : [ModelParametersShort]{
        get{
            return self.parametersResultsShort.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Nan"
                }else{
                    return $0.category.rawValue == "Nan" && $0.variable == selectedVariable
                }
            })
        }
    }
    var otherParametersShort : [ModelParametersShort]{
        get{
            return self.parametersResultsShort.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Other"
                }else{
                    return $0.category.rawValue == "Other" && $0.variable == selectedVariable
                }
            })
        }
    }
    var parametersCategorizedShort : [[ModelParametersShort]]{
        get{
            var tmp = [[ModelParametersShort]]()
            tmp.append(criticalParametersShort)
            tmp.append(warningParametersShort)
            tmp.append(normalParametersShort)
            tmp.append(nanParametersShort)
            tmp.append(otherParametersShort)
            return tmp
        }
    }
    
    // NORMAL PARAMETERS
    var parametersResults = [ModelParameters]()
    var criticalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Critical"
                }else{
                    return $0.category.rawValue == "Critical" && $0.variable == selectedVariable
                }
            })
        }
    }
    var warningParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Warning"
                }else{
                    return $0.category.rawValue == "Warning" && $0.variable == selectedVariable
                }
            })
        }
    }
    var normalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Normal"
                }else{
                    return $0.category.rawValue == "Normal" && $0.variable == selectedVariable
                }
            })
        }
    }
    var nanParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Nan"
                }else{
                    return $0.category.rawValue == "Nan" && $0.variable == selectedVariable
                }
            })
        }
    }
    var otherParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({
                if selectedVariable == "All"{
                    return $0.category.rawValue == "Other"
                }else{
                    return $0.category.rawValue == "Other" && $0.variable == selectedVariable
                }
            })
        }
    }
    var parametersCategorized : [[ModelParameters]]{
        get{
            var tmp = [[ModelParameters]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
            tmp.append(nanParameters)
            tmp.append(otherParameters)
            return tmp
        }
    }
    
    var isHiddenPicker = false
    // IF Complete Parameters
    
    var textTopLabel = String()
    
    var selectObjectForTableView = LongTappableToSaveContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpWindow.layer.cornerRadius = 10
        if isHiddenPicker{
            pickerView.isHidden = true
        }
        
        topLabel.text = textTopLabel
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(TableViewControllerSorted.helpImageTapped))
        helpImage.addGestureRecognizer(tapOnImage)
        let tapOnImageToPlay = UITapGestureRecognizer(target: self, action: #selector(TableViewControllerSorted.imageTappedtoPlay))
        imageHelpWindow.addGestureRecognizer(tapOnImageToPlay)
        
        selectObjectForTableView = LongTappableToSaveContext(newObject: self.tableView, toBlur: self.viewToBlur, targetViewController: self)
        
        let longTapOnTableView = UILongPressGestureRecognizer(target: selectObjectForTableView, action: #selector(selectObjectForTableView.longTapOnObject(sender:)))
        tableView.addGestureRecognizer(longTapOnTableView)
        
        if mainModelParameter.count == 0{
            helpImage.isUserInteractionEnabled = false
            helpImage.isHidden = true
            isShortParameters = false
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.popUpWindow.transform = CGAffineTransform(translationX: 0.0, y: 300)
            self.popUpWindow.alpha = 0
            self.tableView.isHidden = false
            self.viewToBlur.effect = nil
        }) { (success) in
            self.popUpWindow.removeFromSuperview()
        }
    }
    
    func loadParametersView(){
        if isShortParameters{
            labelHelpWindow.text = mainModelParameter[0].name
            textHelpWindow.text = mainModelParameter[0].description
            imageHelpWindow.image = UIImage(named: mainModelParameter[0].imageName)
        }else{
            labelHelpWindow.text = parametersCategorized[selectedParameterSection][selectedParameterPosition].name
            textHelpWindow.text = parametersCategorized[selectedParameterSection][selectedParameterPosition].description
            imageHelpWindow.image = UIImage(named: (parametersCategorized[selectedParameterSection][selectedParameterPosition].imageName))
        }
        
        self.view.addSubview(popUpWindow)
        popUpWindow.alpha = 0
        popUpWindow.center = self.view.center
        popUpWindow.transform = CGAffineTransform(translationX: 0.0, y: 300)
        UIView.animate(withDuration: 0.4) {
            self.tableView.isHidden = true
            self.viewToBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            self.popUpWindow.alpha = 1
            self.popUpWindow.transform = CGAffineTransform.identity
        }
    }
    
    //change name of video
    @objc func imageTappedtoPlay(){
        if let path = Bundle.main.path(forResource: "sampleVideo", ofType: "mp4"){
            let video = AVPlayer(url: URL(fileURLWithPath: path))
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            present(videoPlayer, animated: true, completion: {
                video.play()
            })
        }
    }
    
    @objc func helpImageTapped(){
        loadParametersView()
    }
}

extension TableViewControllerSorted : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShortParameters{
            return parametersCategorizedShort[section].count
        }else{
            return parametersCategorized[section].count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as UITableViewCell
        if isShortParameters{
            let par = parametersCategorizedShort[indexPath.section][indexPath.row]
            cell.textLabel?.text = par.name + " = " + String(format:"%.3f",Double(par.value))
            switch indexPath.section{
            case 0:
                cell.imageView?.image = UIImage.init(named: "critical")
            case 1:
                cell.imageView?.image = UIImage.init(named: "warning")
            case 2:
                cell.imageView?.image = UIImage.init(named: "ok")
            case 3:
                cell.textLabel?.text = par.name
                cell.textLabel?.textColor = UIColor.red
                cell.imageView?.image = UIImage.init(named: "nan")
            case 4:
                cell.imageView?.image = nil
            default:break
            }
            return cell
        }
        else{
            let par = parametersCategorized[indexPath.section][indexPath.row]
            cell.textLabel?.text = par.name + " = " + String(format:"%.3f",Double(par.value))
            switch indexPath.section{
            case 0:
                cell.imageView?.image = UIImage.init(named: "critical")
            case 1:
                cell.imageView?.image = UIImage.init(named: "warning")
            case 2:
                cell.imageView?.image = UIImage.init(named: "ok")
            case 3:
                cell.textLabel?.text = par.name
                cell.textLabel?.textColor = UIColor.red
                cell.imageView?.image = UIImage.init(named: "nan")
            case 4:
                cell.imageView?.image = nil
            default:break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if !isShortParameters{
            selectedParameterSection = indexPath.section
            selectedParameterPosition = indexPath.row
            loadParametersView()
        }
    }
}

extension TableViewControllerSorted : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSections.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVariable = pickerSections[row]
        tableView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerSections[row]
    }
}
