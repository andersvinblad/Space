//
//  BigAlien.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-10.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import GameKit

class BigAlien {
    var hp:Int?
    var alien:SKSpriteNode?
    
    init(){
        hp = 100
        alien = SKSpriteNode(imageNamed: "BigB")
        let alienCategory:UInt32            = 0x1 << 1
        let photonTorpedoCategory:UInt32    = 0x1 << 0
        
        
        alien?.physicsBody = SKPhysicsBody(rectangleOf: (alien?.size)!)
        alien?.physicsBody?.isDynamic = true
        
        alien?.physicsBody?.categoryBitMask = alienCategory
        alien?.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien?.physicsBody?.collisionBitMask = 0
        
       // self.addChild(alien)
        
        let animationDuration:TimeInterval = 15
        
        var actionArray = [SKAction]()
        
    }
}

