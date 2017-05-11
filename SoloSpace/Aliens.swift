//
//  Aliens.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-11.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Aliens: SKSpriteNode {
    var stringName:String?
    var hp:Int?
    var intSpeed:Int?
    var imageName:String?
    var actionArray = [SKAction]()

    
    
    init(normalAlien:String){
        //textures
        stringName = "normalAlien"
        var possibleAliens = ["alien", "alien2", "alien3"]
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let texture = SKTexture(imageNamed: possibleAliens[0])
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        //MISC
        hp = 1

    }
    
    init(bigAlien:String){
        stringName = "bigAlien"
        let texture = SKTexture(imageNamed: bigAlien)
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        hp = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
