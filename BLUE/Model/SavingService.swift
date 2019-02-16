//
//  SavingService.swift
//  BLUE
//
//  Created by Karol Struniawski on 08/12/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import Foundation

protocol Storage{
    var path : URL {get}
    func save<T: Encodable>(object: T, fileName : String?, pathExternal : String?)
    func get<T: Decodable>(fileName : String) -> T
    func get<T: Decodable>(path : String) -> T
    func remove(fileName : String)
    func exists(fileName : String) -> Bool
    func getListOfFiles() -> [String]
    func getListOfFilesRoot() -> [String]
}

extension Storage{
    var path : URL{
        get{
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    func save<T: Encodable>(object: T, fileName : String? = nil, pathExternal : String? = nil){
        let url : URL
        if (pathExternal != nil){
            let index = pathExternal!.firstIndex(of: ".")!
            let result : String = String(pathExternal![..<index])
            url = URL(fileURLWithPath: result)
        }else{
            let name = "/Saved Models/" + fileName! + ".plist"
            url = path.appendingPathComponent(name)
        }
        print(url)
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(object)
            try data.write(to: url)
        } catch {
            print("error saving!")
        }
    }
    func get<T: Decodable>(fileName : String) -> T{
        let url = path.appendingPathComponent("/Saved Models/" + fileName)
        let decoder = PropertyListDecoder()
        let modelOutput : Model
        do{
            let data = try Data(contentsOf: url)
            modelOutput = try decoder.decode(Model.self, from: data)
        }catch{
            fatalError(error.localizedDescription)
        }
        return modelOutput as! T
    }
    func get<T: Decodable>(path : String) -> T{
        let decoder = PropertyListDecoder()
        let modelOutput : Model
        do{
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            modelOutput = try decoder.decode(Model.self, from: data)
        }catch{
            fatalError(error.localizedDescription)
        }
        return modelOutput as! T
    }
    func remove(fileName : String){
        let name = fileName + ".plist"
        let url = path.appendingPathComponent(name)
        if exists(fileName: fileName) {
            do{
                try FileManager.default.removeItem(at: url)
            }catch{
                fatalError(error.localizedDescription)
            }
        }
    }
    func exists(fileName : String) -> Bool{
        let name = fileName + ".plist"
        let url = path.appendingPathComponent(name).path
        if FileManager.default.fileExists(atPath: url) {
            return true
        }else{
            return false
        }
    }
    func getListOfFiles() -> [String]{
        var tabTmp = [String]()
        do{
            tabTmp = try FileManager.default.contentsOfDirectory(atPath: path.path + "/Saved Models")
        }catch{
            fatalError(error.localizedDescription)
        }
        let tab = tabTmp.filter{$0.contains(".plist") && $0.count>6}
        return tab
    }
    
    func getListOfFilesRoot() -> [String]{
        var tabTmp = [String]()
        do{
            tabTmp = try FileManager.default.contentsOfDirectory(atPath: path.path)
        }catch{
            fatalError(error.localizedDescription)
        }
        let tab = tabTmp.filter{$0.contains(".plist") && $0.count>6}
        return tab
    }
}

