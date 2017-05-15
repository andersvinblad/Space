//
//  GameScene.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-05.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var weaponButton:SKSpriteNode!
    let displaySize: CGRect = UIScreen.main.bounds
    var displayWidth: CGFloat = 0.0
    var displayHeight: CGFloat = 0.0
    var restartButton = SKSpriteNode(imageNamed: "newAlienx3")
    var start = 0
    var starField:SKEmitterNode!
    var starField2:SKEmitterNode!
    var player:SKSpriteNode!
    var thruster:SKEmitterNode!
    var spaceship:SKSpriteNode!
    var currentWeapon:String!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var numberOfAliens = 0
    var bottomArea : SKSpriteNode!
    var gameTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3, NewAlienx3"]
    
    let bigAlienCategory:UInt32         = 0x1 << 3
    let bottomAreaCategory:UInt32       = 0x1 << 2
    let alienCategory:UInt32            = 0x1 << 1
    let photonTorpedoCategory:UInt32    = 0x1 << 0
    
    
    
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    
    
    override func sceneDidLoad() {
        print("sceneDidLoad")
        start += 1
        if start <= 1{
            startGame()
        }
    }
    
    func startGame(){
        //self.frame.size = self.displaySize
        self.displayWidth = self.displaySize.width
        self.displayHeight = self.displaySize.height
        self.displaySize.height
        starField = SKEmitterNode(fileNamed: "Starfield")
        starField.position = CGPoint(x: 0, y: 1400)
        starField.advanceSimulationTime(50)
        starField.zPosition = -1
        self.addChild(starField)
        
        starField2 = SKEmitterNode(fileNamed: "Starfield2")
        starField2.position = CGPoint(x: 0, y: 1400)
        starField2.advanceSimulationTime(50)
        starField2.zPosition = -1
        self.addChild(starField2)
        
        player = SKSpriteNode(imageNamed: "shuttle")
        //player.position = CGPoint(x: 0, y: (-self.frame.height/2))
        player.position = CGPoint(x: 0, y: (-self.displayHeight + 50))

        player.physicsBody?.isDynamic
        //self.addChild(player)
        //PLAYER
        
        
        spaceship = SKSpriteNode(imageNamed: "playerTestSprite")
        spaceship.position = CGPoint(x: 0, y: (-self.displayHeight + 300))
        //spaceship.size = player.size
        spaceship.physicsBody?.isDynamic
        self.addChild(spaceship)
        
        thruster = SKEmitterNode(fileNamed: "Thruster")
        thruster.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y - 40)
        self.addChild(thruster)
        
        //WEAPON
        currentWeapon = "laser"
        
        ///
        // SUPER WEAPON BUTTON
        weaponButton = SKSpriteNode(color: UIColor.red, size: CGSize(width: self.displayWidth/4, height: self.displayWidth/4))
        weaponButton.position = CGPoint(x: -self.displayWidth + 50, y: self.displayHeight - 50)
        self.addChild(weaponButton)
        
        ///
        print("MAKE THE SCORE LABEL")
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x:-self.frame.width, y: self.frame.height/2 - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        score = 0
        
        bottomArea = SKSpriteNode(color: UIColor.red, size: CGSize(width: self.frame.width, height: 10))
        bottomArea.position = CGPoint(x: 0, y: -self.displayHeight + 100)
        bottomArea.physicsBody = SKPhysicsBody(rectangleOf: bottomArea.size)
        bottomArea.physicsBody?.isDynamic = true
        bottomArea.physicsBody?.categoryBitMask = bottomAreaCategory
        bottomArea.physicsBody?.contactTestBitMask = alienCategory
        bottomArea.physicsBody?.collisionBitMask = 0
        bottomArea.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        
        self.addChild(bottomArea)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        // ADD INITIAL ALIENS
        
        for index in 0...10{
            //gameTimer = Timer.scheduledTimer(timeInterval: Double(GKRandomDistribution(lowestValue: 1, highestValue: 5))!, target: self, selector: #selector(addAlien), userInfo: nil, repeats: false)
            
        }
        if (numberOfAliens <= 10){
            //addAlien()
        }
     //   gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(addBigAlien), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fireTorpedo), userInfo: nil, repeats: true)

        //gameTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTorpedo), userInfo: nil, repeats: true)

        

        
    }
    
    
    func addAlien(){
        
        let alien = Aliens.init(normalAlien: "alien")
        let randomAlienPosition = GKRandomDistribution(lowestValue: (Int(-self.frame.width/2) + 50), highestValue: Int( self.frame.width/2) - 50)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + (alien.size.height))
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: (alien.size))
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 20
        
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.height/2), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
    }
    
    func addBigAlien(){
        let alien = Aliens.init(bigAlien: "BigB")
        let randomAlienPosition = GKRandomDistribution(lowestValue: (Int(-self.frame.width/2) + 50), highestValue: Int( self.frame.width/2) - 50)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + (alien.size.height))
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: (alien.size))
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 15
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.height/2), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    }
    
    
    
    func fireTorpedo(){
       // self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        let torpedoNode = Torpedo(weaponType: currentWeapon)
        
        
        torpedoNode.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + 40)
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration : TimeInterval = 0.6
        torpedoNode.run(SKAction.move(to: CGPoint(x: spaceship.position.x, y: self.frame.size.height), duration: animationDuration))
        
        var animationArray = [SKAction]()
        
        animationArray.append(SKAction.move(to: CGPoint(x:spaceship.position.x, y: frame.size.height/2 - 20), duration: animationDuration))
        animationArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(animationArray))
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        //fireTorpedo()
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if ( contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & photonTorpedoCategory) != 0) && ((secondBody.categoryBitMask & alienCategory) != 0 ){
            if ((firstBody.node != nil) && (secondBody.node != nil )){
                
            torpedoDidColideWithAlien(torpedoNode: firstBody.node as! Torpedo, alienNode: secondBody.node as! Aliens)
                
            }else{
                print("RIP, bodyNode = nil")
            }
            
        }
        if ((firstBody.categoryBitMask & alienCategory) != 0) && ((secondBody.categoryBitMask & bottomAreaCategory) != 0 ){
            lostGame()
        }

    }
    func lostGame(){
        let loseLabel = SKLabelNode()
        loseLabel.text = "YOU LOSE"
        loseLabel.position = CGPoint(x: 0, y: 0)
        loseLabel.fontSize = 60
        loseLabel.fontColor = UIColor.black
        loseLabel.fontName = "AmericanTypewriter-Bold"
        loseLabel.zPosition = 3
        
        var stopNode = SKSpriteNode()
        stopNode = SKSpriteNode(color: UIColor.red, size: self.frame.size)
        stopNode.position = CGPoint(x: 0, y: 0)
        stopNode.zPosition = 2
       
        
        let  scoreLabel1 = SKLabelNode(text: "Score: " + String(score))
        scoreLabel1.position = CGPoint(x:0, y: 150)
        scoreLabel1.fontName = "AmericanTypewriter-Bold"
        scoreLabel1.fontSize = 60
        scoreLabel1.fontColor = UIColor.white
        scoreLabel1.zPosition = 3
        
        self.removeAllChildren()
        self.addChild(loseLabel)
        self.addChild(stopNode)
        self.addChild(scoreLabel1)
        
        self.run(SKAction.wait(forDuration: 6)){
            self.removeAllChildren()
            self.startGame()
        }
    }
    
    func torpedoDidColideWithAlien(torpedoNode:Torpedo, alienNode:Aliens){
        let pointSize = CGSize(width: 50, height: 50)
        let extraPoints = SKSpriteNode(imageNamed: "+5Px3")
        extraPoints.position = alienNode.position
        extraPoints.size = pointSize
       // extraPoints.size.height = alienNode.size.height*0.5
       // extraPoints.size.width = alienNode.size.width*0.5
        extraPoints.zPosition = 3
        addChild(extraPoints)
        extraPoints.run(SKAction.scale(by: 2, duration: 0.3))
        extraPoints.run(SKAction.moveBy(x: 50, y: 50, duration: 1.5))
        alienNode.hp? -= 1
        torpedoNode.hp? -= 1
        if((alienNode.hp)! <= 0){
            
               // addChild(explosion!)
            if (alienNode.stringName == "normalAlien"){
                addAlien()
            }
            else if (alienNode.stringName == "bigAlien"){
                let explosion = SKEmitterNode(fileNamed: "Explosion")
                explosion?.position = alienNode.position
                self.addChild(explosion!)
                self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                self.run(SKAction.wait(forDuration: 1.5)){
                    explosion?.removeFromParent()
                    self.addBigAlien()
                }
            }
            
            let explosion = SKEmitterNode(fileNamed: "Explosion")
            explosion?.position = alienNode.position
            self.addChild(explosion!)
           // self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            self.run(SKAction.wait(forDuration: 0.5)){
                explosion?.removeFromParent()
            }
                alienNode.removeFromParent()
                self.score = self.score + 5
                self.scoreLabel.text = "Score: " + String(score)
                scoreLabel.position = CGPoint(x:-self.frame.width/2 + 100, y: self.frame.height/2 - 60)
            
            
        }
        
        if(torpedoNode.hp! <= 0){
            torpedoNode.removeFromParent()
        }
            else{
        }
        
        self.run(SKAction.wait(forDuration: 1)){
            extraPoints.removeFromParent()
        }
    }
        
    
    func explosionSound(){
     //   self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if (self.weaponButton.contains(pos)){
            currentWeapon = "bigLaser"

            self.run(SKAction.wait(forDuration: 6)){
                self.currentWeapon = "laser"
            }
            
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        spaceship.run(SKAction.move(to: CGPoint(x: pos.x, y: -self.displayHeight + 170), duration: 0))
        thruster.position = CGPoint(x: spaceship.position.x - 10, y: spaceship.position.y - 50)
        //spaceship.run(SKAction.moveTo(x: pos.x, duration: 0.2))
    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches{
        self.touchDown(atPoint:t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: self))
        }

    }
    
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
