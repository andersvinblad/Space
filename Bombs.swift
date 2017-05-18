//
//  Bombs.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-18.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import UIKit

import UIKit
import SpriteKit
import GameplayKit

class Bomb: SKSpriteNode {
    var stringName:String?
    var imageName = "playerTestSprite" // pickUpSprite needed
    init(){
        //textures
        stringName = imageName
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture:texture, color: SKColor.clear, size: texture.size())
        //MISC
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
