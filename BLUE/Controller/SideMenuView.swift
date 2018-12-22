//
//  SideMenuView.swift
//  BLUE
//
//  Created by Karol Struniawski on 22/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

class SideMenuView: UITableViewController{
    
    var model = Model()
    var identities = ["toObservations","toPlots"]
    let sections = ["Observations", "Plots"]
    let options = ["Observations":["All","Selected"], "Plots":["X-Y plot"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        cell.textLabel?.text = options[sections[indexPath.section]]![indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let num = Int("\(indexPath.section)\(indexPath.row)")
        switch num {
            //All observations
        case 00:
            <#code#>
            //Selected observations
        case 01:
            <#code#>
            //
        case 10:
            <#code#>
        default: break
        }
    }
}
