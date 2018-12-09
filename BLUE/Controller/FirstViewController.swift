//
//  FirstViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 09/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, Storage {

    @IBOutlet weak var tableView: UITableView!
    var filesTab = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        filesTab = getListOfFiles()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMain"{
            let index = Int(tableView.indexPathForSelectedRow!.row)
            let fileName = filesTab[index]
            let modelFromFile = get(fileName: fileName) as Model
            let destination = segue.destination as! UINavigationController
            let target = destination.topViewController as! ViewController
            target.model = modelFromFile
            target.newModel = false
        }
    }
}

extension FirstViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesTab.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID")! as UITableViewCell
        let text = filesTab[indexPath.row]
        cell.textLabel?.text = String(text[..<text.index(text.endIndex, offsetBy: -6)])
        return cell
    }
}
