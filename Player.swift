//
//  Player.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-18.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    var stringName:String?
    var hp:Int?
    var nrOfBombs = 3
    var imageName = "playerTestSprite"
    var currentWeapon = "laser"
    
    
    
    init(playerImageName:String){
        //textures
        stringName = playerImageName
        let texture = SKTexture(imageNamed: playerImageName)
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        //MISC
        hp = 3
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
