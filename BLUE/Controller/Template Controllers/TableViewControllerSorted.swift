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
    
    @IBOutlet var popUpWindow: UIView!
    @IBOutlet weak var viewToBlur: UIVisualEffectView!
    @IBOutlet weak var textHelpWindow: UILabel!
    @IBOutlet weak var imageHelpWindow: UIImageView!
    @IBOutlet weak var labelHelpWindow: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    let tableSections = ["Critical","Warning","Normal","Uncalculable","Uncategorised"]
    var mainModelParameter = [ModelParameters]()
    var parametersResults = [ModelParametersShort]()
    var criticalParameters : [ModelParametersShort]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Critical"})
        }
    }
    var warningParameters : [ModelParametersShort]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Warning"})
        }
    }
    var normalParameters : [ModelParametersShort]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Normal"})
        }
    }
    var nanParameters : [ModelParametersShort]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Nan"})
        }
    }
    var otherParameters : [ModelParametersShort]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Other"})
        }
    }
    var parametersCategorized : [[ModelParametersShort]]{
        get{
            var tmp = [[ModelParametersShort]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
            tmp.append(nanParameters)
            tmp.append(otherParameters)
            return tmp
        }
    }
    var textTopLabel = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topLabel.text = textTopLabel
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(TableViewControllerSorted.helpImageTapped))
        helpImage.addGestureRecognizer(tapOnImage)
        let tapOnImageToPlay = UITapGestureRecognizer(target: self, action: #selector(TableViewControllerSorted.imageTappedtoPlay))
        imageHelpWindow.addGestureRecognizer(tapOnImageToPlay)
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
        labelHelpWindow.text = mainModelParameter[0].name
        textHelpWindow.text = mainModelParameter[0].description
        imageHelpWindow.image = UIImage(named: mainModelParameter[0].imageName)
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

extension TableViewControllerSorted : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parametersCategorized[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
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
        default:break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSections[section]
    }

}
