//
//  TableViewControllerSorted.swift
//  BLUE
//
//  Created by Karol Struniawski on 03/02/2019.
//  Copyright © 2019 Karol Struniawski. All rights reserved.
//

import UIKit

class TableViewControllerSorted: UIViewController {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewToBlur: UIVisualEffectView!
    @IBOutlet weak var textHelpWindow: UILabel!
    @IBOutlet weak var imageHelpWindow: UIImageView!
    @IBOutlet weak var labelHelpWindow: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    let tableSections = ["Critical","Warning","Normal","Uncalculable"]
    var parametersResults = [ModelParameters]()
    var criticalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Critical"})
        }
    }
    var warningParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Warning"})
        }
    }
    var normalParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Normal"})
        }
    }
    var nanParameters : [ModelParameters]{
        get{
            return self.parametersResults.filter({$0.category.rawValue == "Nan"})
        }
    }
    
    var parametersCategorized : [[ModelParameters]]{
        get{
            var tmp = [[ModelParameters]]()
            tmp.append(criticalParameters)
            tmp.append(warningParameters)
            tmp.append(normalParameters)
            tmp.append(nanParameters)
            return tmp
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
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

}
