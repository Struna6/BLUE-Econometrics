//
//  FirstViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 09/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, Storage, PlayableLoadingScreen {

    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var filesTab = [String]()
    var rootCatalogue = [String]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.separatorColor = UIColor.clear
        newButton.layer.cornerRadius = 10.0
        tableView.layer.cornerRadius = 5.0
        newButton.layer.borderWidth = 0.0
        tableView.layer.borderWidth = 0.5
        //createDirectories()
        rootCatalogue = getListOfFilesRoot()
        checkIfFirstLoad()
        
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
            target.openedFileName = fileName
            let path : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let name = fileName + ".plist"
            let url = path.appendingPathComponent(name)
            target.openedFilePath = url.path
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    func checkIfFirstLoad(){
        if defaults.bool(forKey: "firstOpen"){
            if !rootCatalogue.contains("Saved Models") || !rootCatalogue.contains("Sample Models") || !rootCatalogue.contains("Import data"){
                createDirectories()
                filesTab = getListOfFiles()
            }else{
                filesTab = getListOfFiles()
                if !filesTab.contains("Screenshots"){
                    createDirectories()
                }
            }
        }else{
            defaults.set(true, forKey: "firstOpen")
            defaults.set(true, forKey: "longPress")
            defaults.set(true, forKey: "animations")
            createDirectories()
            filesTab = getListOfFiles()
        }
    }
    
    func createDirectories(){
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
        do{
            try FileManager.default.createDirectory(atPath: url+"/Saved Models", withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: url+"/Sample Models", withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: url+"/Import data", withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: url+"/Saved Models/Screenshots", withIntermediateDirectories: true, attributes: nil)
        }catch {
            fatalError("unable to create")
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
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = String(text[..<text.index(text.endIndex, offsetBy: -6)])
        return cell
    }
}
