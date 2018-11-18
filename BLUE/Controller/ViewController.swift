//
//  ViewController.swift
//  BLUE
//
//  Created by Karol Struniawski on 12/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var model = Model()
    let withHeaders = false
    let observationLabeled = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.observations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        var text = ""
        model.observations[indexPath.row].observationArray.forEach { (element) in
            text +=  String(element) + "   "
        }
        cell.textLabel?.text = text
        return cell
    }

    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let k = FilesService.createModelFromFile(withHeaders: withHeaders, observationLabeled: observationLabeled)
        model = k
        print("SSR= \(k.SSR)")
        print("Se= \(k.se)")
        print("R^2= \(k.squareR)")
        print("Fi^2= \(k.squereFi)")
    }
    

}

