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
		arr.append(currentWeapon)
		arr.append(shipName)
		defaults.set(arr, forKey: "SavedArray")
	}
}
