//
//  FirstViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 09/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

import Surge
import Tutti

class FirstViewController: UIViewController, Storage, PlayableLoadingScreen, ErrorScreenPlayable {
    @IBOutlet weak var helpView: UIImageView!
    
    @IBOutlet weak var newModel: UIButton!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var filesTab = [String]()
    var rootCatalogue = [String]()
    let defaults = UserDefaults.standard
    var canGoNext = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.separatorColor = UIColor.clear
        newButton.layer.cornerRadius = 10.0
        tableView.layer.cornerRadius = 5.0
        newButton.layer.borderWidth = 0.0
        tableView.layer.borderWidth = 0.5
        
        newButton.showHint(text: "Press here to make new model")
        tableView.showHint(text: "Here will be displayed list of your saved models")
        helpView.showHint(text: "Here you can proceed to tutorials about this application and econometrics")
        
        rootCatalogue = getListOfFilesRoot()
        checkIfFirstLoad()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMain"{
            let index = Int(tableView.indexPathForSelectedRow!.row)
            let fileName = filesTab[index]
            var modelFromFile = Model()
            do{
                modelFromFile =  try get(fileName: fileName) as Model
            }catch let er as SavingErrors{
                canGoNext = false
                let visualViewToBlur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                visualViewToBlur.frame = self.view.frame
                visualViewToBlur.isHidden = true
                self.view.addSubview(visualViewToBlur)
                
                playErrorScreen(msg: er.rawValue, blurView: visualViewToBlur, mainViewController: self, alertToDismiss: nil)
            }catch{
                
            }
            let destination = segue.destination as! UINavigationController
            let target = destination.topViewController as! ViewController
            target.model = modelFromFile
            target.newModel = false
            target.openedFileName = fileName
            
            let path : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let name = "/Saved Models/" + fileName + ".plist"
            let url = path.appendingPathComponent(name)
            target.openedFilePath = url.path
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if canGoNext{
            return true
        }else{
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
        filesTab = getListOfFiles()
        tableView.reloadData()
    }
    
    func checkIfFirstLoad(){
        if defaults.bool(forKey: "firstOpen"){
            if !rootCatalogue.contains("Saved Models") || !rootCatalogue.contains("Sample Models") || !rootCatalogue.contains("Import data"){
                createDirectories()
                filesTab = getListOfFiles()
            }else{
                filesTab = getListOfFiles()
            }
        }else{
            defaults.set(true, forKey: "firstOpen")
            //defaults.set(false, forKey: "longPress")
            defaults.set(true, forKey: "animations")
            createDirectories()
            filesTab = getListOfFiles()
            copyBundleSampleModels()
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
    
    func copyBundleSampleModels(){
        do{
            try copySampleModels(name: "sampleCity", type: ".csv")
        }catch let er as SavingErrors{
            print(er)
        }catch{}
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
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        var date = String()
        do{
            try date = formatter.string(from: fileModificationDate(name: filesTab[indexPath.row]))
        }
        catch let er as SavingErrors{
            print(er)
        }catch{}
        cell.detailTextLabel?.text = "Last save time: " + date
        return cell
    }
}
