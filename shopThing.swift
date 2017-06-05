//
//  shopThing.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-06-05.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ShopThing
    
{
    var CDobject : NSManagedObject?
    
    func loadFromCD(data : NSManagedObject)
    {
        CDobject = data
    }
    
    func makeNew(name : String, amount : String, amountUnit : String, bought : Bool)
    {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Shopitem", in: managedContext)!
        
        self.CDobject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        self.CDobject!.setValue(name, forKeyPath: "name")
        self.CDobject!.setValue(bought, forKeyPath: "bought")
        self.CDobject!.setValue(amountUnit, forKeyPath: "amountUnit")
        
        let shopAmount = Int(amount)
        
        self.CDobject!.setValue(shopAmount, forKeyPath: "amount")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getname() -> String
    {
        return CDobject!.value(forKeyPath: "name") as! String
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
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        CDobject!.setValue(boughtValue, forKeyPath: "bought")
        
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
