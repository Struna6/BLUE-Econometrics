//
//  SideMenuView.swift
//  BLUE
//
//  Created by Karol Struniawski on 22/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

class SideMenuView: UITableViewController{
    
    let sections = ["Observations", "Plots", "Tests"]
    let options = ["Observations":["All","Selected"], "Plots":[], "Tests":[]]
    
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
        //cell.detailTextLabel?.text = options[sections[indexPath.section]]![indexPath.row]
        return cell
    }
}
