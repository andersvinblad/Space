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
	let defaults = UserDefaults.standard
    var score = Int64(199)
    var difficulty = 1.0
    var attackRate = 0.3
    var currentWeapon = "wep2"
    var shipName = "playerRed"
	
    //private init() { }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
	func loadData(){
		
		let arr = defaults.object(forKey:"SavedArray") as? [String] ?? [String]()
		if arr.isEmpty == false{
			score = Int64(arr[0])!
			difficulty = Double(arr[1])!
			attackRate = Double(arr[2])!
			currentWeapon = arr[3]
			shipName = arr[4]
		}


		
		
		
	}
	func saveData(){
		var arr = [String]()
		arr.append(String(score))
		arr.append(String(difficulty))
		arr.append(String(attackRate))
		arr.append("wep2")
		arr.append("playerRed")
		defaults.set(arr, forKey: "SavedArray")
	}
	
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
