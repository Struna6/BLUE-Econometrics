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
    func save<T: Encodable>(object: T, fileName : String?, pathExternal : String?) throws
    func copyToChosenExternalPath() throws
    func get<T: Decodable>(fileName : String) throws -> T
    func get<T: Decodable>(path : String) throws -> T
    func remove(fileName : String)
    func remove(path : URL)
    func exists(fileName : String) -> Bool
    func getListOfFiles() -> [String]
    func getListOfFilesRoot() -> [String]
    func copySampleModels(name : String, type : String) throws
    func fileModificationDate(name: String) throws -> Date
}

enum SavingErrors : String, Error{
    case savingError = "Unable to save!"
    case autoSavingError = "Unable to copy to selected path!"
    case cannotLoadModel = "Unable to import file!"
    case cannotInitializeSampleModels = "Unable to initialize sample models"
    case cannotGetDate = "Unable to get date of last saved!"
}

extension Storage{
    var path : URL{
        get{
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    func save<T: Encodable>(object: T, fileName : String? = nil, pathExternal : String? = nil) throws{
        let url : URL
        if (pathExternal != nil){
            let index = pathExternal!.firstIndex(of: ".")!
            let result : String = String(pathExternal![..<index])
            url = URL(fileURLWithPath: result+".plist")
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
            throw SavingErrors.savingError
        }
        do{
            try copyToChosenExternalPath()
        }catch{
            throw SavingErrors.autoSavingError
        }
        
    }
    func copyToChosenExternalPath() throws{
        let defaults = UserDefaults.standard
        if let toPath = defaults.url(forKey: "externalPathToAutoSave"){
            let fileMenager = FileManager.default
            let loc1 = path
            //let loc1 = path.appendingPathComponent("/Saved Models")
            let loc2 = toPath.appendingPathComponent("/BLUE Documents")
            if fileMenager.fileExists(atPath: loc2.path){
                do{
                    try fileMenager.removeItem(at: loc2)
                    try fileMenager.copyItem(atPath: loc1.path, toPath: loc2.path)
                }catch{
                    remove(path: loc2)
                    throw SavingErrors.autoSavingError
                }
            }else{
                do{
                    try fileMenager.copyItem(atPath: loc1.path, toPath: loc2.path)
                }catch{
                    remove(path: loc2)
                    throw SavingErrors.autoSavingError
                }
            }
        }
    }
    func get<T: Decodable>(fileName : String) throws -> T{
        let url = path.appendingPathComponent("/Saved Models/" + fileName)
        let decoder = PropertyListDecoder()
        let modelOutput : Model
        do{
            let data = try Data(contentsOf: url)
            modelOutput = try decoder.decode(Model.self, from: data)
        }catch{
            throw SavingErrors.cannotLoadModel
        }
        return modelOutput as! T
    }
    func get<T: Decodable>(path : String) throws -> T{
        let decoder = PropertyListDecoder()
        let modelOutput : Model
        do{
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            modelOutput = try decoder.decode(Model.self, from: data)
        }catch{
            throw SavingErrors.cannotLoadModel
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
    func remove(path : URL){
        do{
            try FileManager.default.removeItem(at: path)
        }catch{
            print("cannot remove")
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
        if let index = tabTmp.firstIndex(of: ".Trash"){
            tabTmp.remove(at: index)
        }
        return tabTmp
    }
    func copySampleModels(name : String, type : String) throws{
        let fileMenager = FileManager.default
        let bundlePath = Bundle.main.path(forResource: name, ofType: type)
        let toPath = path.appendingPathComponent("/Sample Models/" + name + type)
        if let _ = bundlePath{
            do{
                try fileMenager.copyItem(at: URL(fileURLWithPath: bundlePath!), to: toPath)
            }
            catch{
                throw SavingErrors.cannotInitializeSampleModels
            }
        }
    }
    func fileModificationDate(name: String) throws -> Date{
        do {
            let url = path.appendingPathComponent("/Saved Models/" + name)
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as! Date
        } catch {
            throw SavingErrors.cannotGetDate
        }
    }
}

