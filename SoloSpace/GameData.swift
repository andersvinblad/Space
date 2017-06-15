//
//  GameData.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-22.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GameData {
    static let shared = GameData()
    var score = 0
    var difficulty = 1
    var attackRate = 0.3
    var currentWeapon = "wep2"
    var shipName = "ship2"

    //private init() { }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //COREDATA TESTS    //COREDATA TESTS    //COREDATA TESTS    //COREDATA TESTS    //COREDATA TESTS    //COREDATA TESTS
    
    
    
    
    var CDobject : NSManagedObject?
    
    func loadFromCD(data : NSManagedObject)
    {
        CDobject = data
    }
    
    func makeNew(name : String)
    {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "GameDataCD", in: managedContext)!
        
        self.CDobject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        self.CDobject!.setValue(name, forKeyPath: "score")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getscore() -> String
    {
        return CDobject!.value(forKeyPath: "score") as! String
    }
    func getamountunit() -> String
    {
        var amountUnitText = ""
        
        if let shopAmount = CDobject!.value(forKeyPath: "amount") as? Int
        {
            amountUnitText = String(shopAmount)
        }
        if let shopAmountType = CDobject!.value(forKeyPath: "amountUnit") as? String
        {
            amountUnitText = amountUnitText + " " + shopAmountType
        }
        return amountUnitText
    }
    
    func setBought(boughtValue : Bool)
    {
        /*
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        CDobject!.setValue(boughtValue, forKeyPath: "bought")
        
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
 */
    }
    
    
    func deleteMe()
    {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(self.CDobject!)
        
        do {
            try managedContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
        
    }

}
