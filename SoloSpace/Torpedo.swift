//
//  Torpedo.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-14.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Torpedo: SKSpriteNode {
    var stringName:String?
    var hp:Int?
    var intSpeed:Int?
    var imageName:String?
    var actionArray = [SKAction]()
    
    
    
    init(weaponType:String){
        //textures
        if (weaponType == "laser"){
            hp = 1
        }
        else if (weaponType == "bigLaser"){
            hp = 3
        }
        stringName = weaponType
        let texture = SKTexture(imageNamed: weaponType)
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
