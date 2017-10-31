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
    //var intSpeed = 10
    var imageName:String?
    var actionArray = [SKAction]()

    
    
	init(normalAlien:String){
        //textures
        stringName = "normalAlien"
        var possibleAliens = ["alienCircle", "hex", "shooterAlien", "starAlien"]
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let texture = SKTexture(imageNamed: possibleAliens[0])
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        //MISC
        self.hp = (Int(GameData.shared.difficulty / 2) + 3)

    }
    
    init(bigAlien:String){
        stringName = bigAlien
        let texture = SKTexture(imageNamed: bigAlien)
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        hp = Int((GameData.shared.difficulty / 3) * Double(35))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
