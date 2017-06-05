//
//  GameScene.swift
//  SoloSpace
//
//  Created by Anders Vinblad on 2017-05-05.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var progressBarFrame : SKShapeNode!
    var progressBar : SKSpriteNode!
    //
    
    var gameData = GameData.shared
    var difficulty = 1
    var lives = 3
    var music : SKAudioNode!
    var alienQueue = 30
    var currentNrOfAliens = 0
    var weaponButton:SKSpriteNode!
    var menuButton:SKSpriteNode!
    var bombButton:SKSpriteNode!
    let displaySize: CGRect = UIScreen.main.bounds
    var displayWidth: CGFloat = 0.0
    var displayHeight: CGFloat = 0.0
    var restartButton = SKSpriteNode(imageNamed: "NewAlienx3")
    var start = 0
    var starField:SKEmitterNode!
    var starField2:SKEmitterNode!
    var weapons = [SKSpriteNode]()
    var thruster:SKEmitterNode!
    var spaceship:Player!
    var weaponSprite: SKSpriteNode!
    var currentWeapon:String!
    var scoreLabel:SKLabelNode!
    var weaponSprite1: SKSpriteNode!
    var weaponSprite2: SKSpriteNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
        
    }
    var bottomArea : SKSpriteNode!
    var gameTimer:Timer!
    
    var possibleAliens = ["alien", "alien2", "alien3, NewAlienx3"]
    
    let bigAlienCategory:UInt32         = 0x1 << 3
    let bottomAreaCategory:UInt32       = 0x1 << 2
    let alienCategory:UInt32            = 0x1 << 1
    let photonTorpedoCategory:UInt32    = 0x1 << 0
    let bombCategoryBitMask:UInt32      = 0x1 << 4
    let playerCategoryBitMask:UInt32    = 0x1 << 5
    let pickUpCategoryBitMask:UInt32    = 0x1 << 6

    
    
    override func sceneDidLoad() {
        print("sceneDidLoad")
        
        start += 1
        if start <= 1{
            startGame(attackRate: gameData.attackRate)
        }
    }
    func loadShopping()
    {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameData")
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let resultPredicate = NSPredicate(format: "bought = false")
        fetchRequest.predicate = resultPredicate
        
        do {
            var shoplistCD : [NSManagedObject] = try managedContext.fetch(fetchRequest)
            
            for CDObject in shoplistCD
            {
                let nShopThing = ShopThing()
                
                nShopThing.loadFromCD(data: CDObject)
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        let fetchRequestBought = NSFetchRequest<NSManagedObject>(entityName: "Shopitem")
        
        fetchRequestBought.sortDescriptors = sortDescriptors
        
        let resultPredicateBought = NSPredicate(format: "bought = true")
        fetchRequestBought.predicate = resultPredicateBought
        
        do {
            var shoplistBoughtCD : [NSManagedObject] = try managedContext.fetch(fetchRequestBought)
            
            for CDObject in shoplistBoughtCD
            {
                let nShopThing = ShopThing()
                
                nShopThing.loadFromCD(data: CDObject)
                
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    
    func startGame(attackRate: Double){

        self.alienQueue = 30
        var difficulty = gameData.difficulty
        startMusic()
        if difficulty == nil{
            difficulty = 1
        }
        print("start Diff" + String(difficulty))
        //SET DIFFICULTY
        self.alienQueue         *= Int(difficulty)
        self.currentNrOfAliens  *= Int(difficulty)

        //
        print(displaySize)
        self.displayWidth = self.displaySize.width
        self.displayHeight = self.displaySize.height
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
        
        
        //self.addChild(player)
        //PLAYER
        
        setupPlayer()
        
        //WEAPON
        currentWeapon = "laser"
        
        ///
        // SUPER WEAPON BUTTON
        weaponButton = SKSpriteNode(color: UIColor.red, size: CGSize(width: self.displayWidth/4, height: self.displayWidth/4))
        weaponButton.position = CGPoint(x:-self.frame.width/2 + 100, y: self.frame.height/2 - 60)
        self.addChild(weaponButton)
        ///
        // SUPER BOMB BUTTON
        bombButton = SKSpriteNode(color: UIColor.blue, size: CGSize(width: self.displayWidth/4, height: self.displayWidth/4))
        bombButton.position = CGPoint(x:+self.frame.width/2 - 100, y: -self.frame.height/7 - 60)
        self.addChild(bombButton)
        ///
        
        menuButton = SKSpriteNode(color: UIColor.blue, size: CGSize(width: self.displayWidth/4, height: self.displayWidth/4))
        menuButton.position = CGPoint(x:self.frame.width/2 - 100, y: self.frame.height/2 - 60)
        self.addChild(menuButton)

        print("MAKE THE SCORE LABEL")
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x:-self.frame.width, y: self.frame.height/2 - 60)
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        self.addChild(scoreLabel)
        score = 0
        
        bottomArea = SKSpriteNode(color: UIColor.clear, size: CGSize(width: self.frame.width, height: 10))
        bottomArea.position = CGPoint(x: 0, y: -self.frame.height/2 + 100)
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
        
        
        
        
        
        
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(addBigAlien), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: (TimeInterval(10.0 / Double(gameData.difficulty * 5))), target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        gameTimer = Timer.scheduledTimer(timeInterval: gameData.attackRate, target: self, selector: #selector(fireTorpedo), userInfo: nil, repeats: true)

        gameTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(addPickUp), userInfo: nil, repeats: true)

        //gameTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(fireTorpedo), userInfo: nil, repeats: true)

        
        self.progressBar = SKSpriteNode(color: UIColor.yellow, size: CGSize(width: 1, height: 20))
        self.progressBar.position = CGPoint(x: 0, y: self.frame.height/2 - 50)
        self.addChild(progressBar)
        progressBarFrame = SKShapeNode(rectOf: CGSize(width: 300, height: progressBar.size.height))
       // progressBarFrame.frame.width = 300
        progressBarFrame.position = progressBar.position
        progressBarFrame.fillColor = UIColor.clear
        progressBarFrame.strokeColor = UIColor.cyan

        self.addChild(progressBarFrame)

       // gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progress), userInfo: nil, repeats: true)


    }
    
    
    func progress(){
        if (progressBar.size.width <= progressBarFrame.frame.width){
            self.progressBar.size.width += 3
        }
        else {
            boostWeapon()
            progressBar.size.width = 1
        }
        
        
    }
    
    
    
    func setupPlayer(){
        spaceship = Player(playerImageName: gameData.shipName, weaponName: gameData.currentWeapon)
        spaceship.position = CGPoint(x: 0, y: (-self.displayHeight + 200))
        //spaceship.size = player.size
        spaceship.physicsBody?.isDynamic
        self.addChild(spaceship)
        spaceship.physicsBody?.categoryBitMask = playerCategoryBitMask
        spaceship.physicsBody?.contactTestBitMask = pickUpCategoryBitMask
        spaceship.position = CGPoint(x: spaceship.size.width/4, y: 0)
        
        
        weaponSprite1 = SKSpriteNode(imageNamed: gameData.currentWeapon)
        weaponSprite2 = SKSpriteNode(imageNamed: gameData.currentWeapon)

        
       

        weaponSprite1.position = CGPoint(x: spaceship.size.width/4, y: 0)
        weaponSprite2.position = CGPoint(x: -spaceship.size.width/4, y: 0)
        
        weapons.append(weaponSprite1)
        weapons.append(weaponSprite2)
        spaceship.addChild(weapons[0])
        spaceship.addChild(weapons[1])
        
        
        thruster = SKEmitterNode(fileNamed: "Thruster")
        thruster.position = CGPoint(x: 0, y: 0 - 40)
        spaceship.addChild(thruster)
        
        
    }
    
    
    
    func fireBomb(){
        spaceship.nrOfBombs -= 1
        let bomb = SKEmitterNode(fileNamed: "BombExplosion")
        bomb?.position = CGPoint(x: 0, y: 0)
        self.addChild(bomb!)
        self.run(SKAction.wait(forDuration: 2.0)){
            bomb?.removeFromParent()
        }
        let texture = SKTexture(imageNamed: "torpedo")
        let bombHitBox = SKSpriteNode(color: UIColor.clear, size: self.frame.size)
        
        bombHitBox.position = CGPoint(x: 0, y: 0)
        bombHitBox.position.y += 5
        
        bombHitBox.physicsBody = SKPhysicsBody(circleOfRadius: bombHitBox.size.width)
        bombHitBox.physicsBody?.isDynamic = true
        bombHitBox.physicsBody?.categoryBitMask = bombCategoryBitMask
        bombHitBox.physicsBody?.contactTestBitMask = alienCategory
        bombHitBox.physicsBody?.collisionBitMask = 0
        bombHitBox.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bombHitBox)
        self.run(SKAction.wait(forDuration: 1.0)){
           bombHitBox.removeFromParent()
        }
    }
    
    func addAlien(){
        if (alienQueue >= 1 && currentNrOfAliens <= (5 * self.gameData.difficulty)){
        self.alienQueue -= 1

        self.currentNrOfAliens += 1
        let alien = Aliens.init(normalAlien: "alien")
        let randomAlienPosition = GKRandomDistribution(lowestValue: (Int(-self.frame.width/2) + 50), highestValue: Int( self.frame.width/2) - 50)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height/2 + (alien.size.height))
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: (alien.size))
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        alien.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -100))
            self.run(SKAction.wait(forDuration: 10)){
                if (alien.hp!>=1){
                    self.removeAliens(Alien: alien)
                }
            }
    
        }
        else if alienQueue <= 0 && currentNrOfAliens <= 0{
            winScreen()
        }
        print("Alien QUEUE: " + String(alienQueue))
        print("Current number of Aliens: " + String(currentNrOfAliens))
        

    }
    
    func addBigAlien(){
        if (alienQueue >= 1){
        alienQueue -= 1
        currentNrOfAliens += 1
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
            
        //alien.run(SKAction.sequence(actionArray))
        
        
        }
    }
    func addPickUp(){
        
        
        let pulseUp = SKAction.scale(to: 2, duration: 1.5)
        let pulseDown = SKAction.scale(to: 0.5, duration: 1.5)
        let rotate = SKAction.rotate(byAngle: 1, duration: 1)
        let pulse = SKAction.sequence([pulseUp, pulseDown, rotate])
        let repeatPulse = SKAction.repeatForever(pulse)
        
            let pickUp = Bomb.init(type: "blueX")
            let randomAlienPosition = GKRandomDistribution(lowestValue: (Int(-self.frame.width/2) + 50), highestValue: Int( self.frame.width/2) - 50)
            let position = CGFloat(randomAlienPosition.nextInt())
            
            pickUp.position = CGPoint(x: position, y: self.frame.size.height + (pickUp.size.height))
            
            pickUp.physicsBody = SKPhysicsBody(rectangleOf: (pickUp.size))
            //alien.physicsBody?.isDynamic = true
            
            pickUp.physicsBody?.categoryBitMask = pickUpCategoryBitMask
            pickUp.physicsBody?.contactTestBitMask = photonTorpedoCategory
            pickUp.physicsBody?.collisionBitMask = 0
            pickUp.physicsBody?.isDynamic = true
            pickUp.physicsBody?.usesPreciseCollisionDetection = true
        
            self.addChild(pickUp)
            pickUp.run(repeatPulse)

            let animationDuration:TimeInterval = 15
            
            var actionArray = [SKAction]()
            
            
            actionArray.append(SKAction.move(to: CGPoint(x: position, y: -self.frame.height/2), duration: animationDuration))
            actionArray.append(SKAction.removeFromParent())
            
            pickUp.run(SKAction.sequence(actionArray))
        
    }

    
    
    func fireTorpedo(){
        self.run(SKAction.playSoundFileNamed("pew.wav", waitForCompletion: true))
        let torpedoNode = Torpedo(weaponType: currentWeapon)
        
        
        torpedoNode.position = CGPoint(x: self.spaceship.position.x + 50, y: spaceship.position.y + 60)
        torpedoNode.position.y += 5
        
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        torpedoNode.physicsBody?.isDynamic = true
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let torpedoNode2 = Torpedo(weaponType: currentWeapon)
        
        
        torpedoNode2.position = CGPoint(x: self.spaceship.position.x - 50, y: spaceship.position.y + 60)
        torpedoNode2.position.y += 5
        
        torpedoNode2.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        torpedoNode2.physicsBody?.isDynamic = true
        torpedoNode2.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode2.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode2.physicsBody?.collisionBitMask = 0
        torpedoNode2.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode2)
        
       
        let animationDuration : TimeInterval = 0.6
       // torpedoNode.run(SKAction.move(to: CGPoint(x: self.spaceship.position.x + 50, y: self.frame.size.height), duration: animationDuration))
      //  torpedoNode2.run(SKAction.move(to: CGPoint(x: self.spaceship.position.x - 50, y: self.frame.size.height), duration: animationDuration))

        var animationArray = [SKAction]()
        
        animationArray.append(SKAction.move(to: CGPoint(x:spaceship.position.x + 50, y: frame.size.height/2 - 20), duration: animationDuration))
        animationArray.append(SKAction.removeFromParent())
        torpedoNode.run(SKAction.sequence(animationArray))
        animationArray[0] = SKAction.move(to: CGPoint(x:spaceship.position.x - 50, y: frame.size.height/2 - 20), duration: animationDuration)
        torpedoNode2.run(SKAction.sequence(animationArray))
        
        
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

        //BOTTOMAREA Got HIT
        if ((firstBody.categoryBitMask & alienCategory) != 0) && ((secondBody.categoryBitMask & bottomAreaCategory) != 0 ){
            self.lives -= 1
            removeAliens(Alien: firstBody.node as! Aliens)
            if (self.lives <= 0 ){
                loseScreen()
            }
            if ((firstBody.node != nil) && (secondBody.node != nil )){
                
                bombDidColideWithAlien(bombNode: secondBody.node as! SKSpriteNode, alienNode: firstBody.node as! Aliens)
                
            }else{
                print("RIP, bodyNode = nil")
            }
        }
        
        
        //BOMB
        if ((firstBody.categoryBitMask & alienCategory) != 0) && ((secondBody.categoryBitMask & bombCategoryBitMask) != 0 ){
            
            if ((firstBody.node != nil) && (secondBody.node != nil )){
                
                bombDidColideWithAlien(bombNode: secondBody.node as! SKSpriteNode, alienNode: firstBody.node as! Aliens)
                
            }else{
                print("RIP, bodyNode = nil")
            }
        }
        
        //pickup
        if ((firstBody.categoryBitMask & photonTorpedoCategory) != 0) && ((secondBody.categoryBitMask & pickUpCategoryBitMask) != 0 ){
            if ((firstBody.node != nil) && (secondBody.node != nil )){
                
                currentWeapon = "bigLaser"
                torpedoDidColideWithPickup(torpedoNode: firstBody.node as! Torpedo, pickUpNode: secondBody.node as! Bomb)
            
            }else{
                print("RIP, bodyNode = nil")
            }
            
        }
        

    }
    func loseScreen(){
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
       
        gameData.score = score

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
            if let scene = GKScene(fileNamed: "StartScenen") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! StartScene? {
                    
                    // Copy gameplay related content over to the scene
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    if let view = self.view as! SKView? {
                        view.presentScene(sceneNode)
                        
                        view.ignoresSiblingOrder = true
                        
                        view.showsFPS = true
                        view.showsNodeCount = true
                    }
                }
            }
        }
    }
    
    func torpedoDidColideWithAlien(torpedoNode:Torpedo, alienNode:Aliens){
        //self.scene?.removeFromParent()
        //  fireTorpedo()
        //let pointSize = CGSize(width: 50, height: 50)
        progress()
        let extraPoints = SKLabelNode(text: "+5")
        extraPoints.fontName = "AmericanTypewriter-Bold"
        extraPoints.fontSize = 38
        extraPoints.fontColor = UIColor.black
        extraPoints.position = alienNode.position
        extraPoints.zPosition = 3
        let outline = SKLabelNode(text: "+5")
        outline.fontName = "AmericanTypewriter-Bold"
        outline.fontSize = 30
        outline.fontColor = UIColor.yellow
        //  outline.position = alienNode.position
        outline.zPosition = 4
        addChild(extraPoints)
        extraPoints.addChild(outline)
        extraPoints.run(SKAction.scale(by: 2, duration: 0.3))
        extraPoints.run(SKAction.moveBy(x: 50, y: 150, duration: 1.5))
        alienNode.hp? -= 1
        alienNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        self.run(SKAction.wait(forDuration: 0.2)){
            alienNode.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -30))
        }
        torpedoNode.hp? -= 1
        if((alienNode.hp)! <= 0){
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            removeAliens(Alien: alienNode as! Aliens)
            print ("CurrentNrOfAliens" + String(currentNrOfAliens))
            if (alienNode.stringName == "normalAlien"){
               // addAlien()
            }
            else if (alienNode.stringName == "bigAlien"){
                let explosion = SKEmitterNode(fileNamed: "Explosion")
                explosion?.position = alienNode.position
                self.addChild(explosion!)
                // self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                self.run(SKAction.wait(forDuration: 1.5)){
                    explosion?.removeFromParent()
                    // self.addBigAlien()
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
        if (currentNrOfAliens <= 0 && alienQueue <= 0){
            winScreen()
        }
    }
    
    
    func torpedoDidColideWithPickup(torpedoNode:Torpedo, pickUpNode:Bomb){
        pickUpNode.removeFromParent()
        torpedoNode.removeFromParent()
        self.currentWeapon = "bigLaser"
        self.run(SKAction.wait(forDuration: 1.5)){
            self.currentWeapon = "laser"
            }
        
    }
    func bombDidColideWithAlien(bombNode:SKSpriteNode, alienNode:Aliens){
        print("BOMB")
        
        
        alienNode.hp? -= 100
        if((alienNode.hp)! <= 0){
            
            
            removeAliens(Alien: alienNode as! Aliens)
            self.score = self.score + 5
            self.scoreLabel.text = "Score: " + String(score)
            scoreLabel.position = CGPoint(x:-self.frame.width/2 + 100, y: self.frame.height/2 - 60)
            
            
        }
        
        self.run(SKAction.wait(forDuration: 1)){
        }
    }
    
    func boostWeapon(){
        currentWeapon = "bigLaser"
        
        self.run(SKAction.wait(forDuration: 6)){
            self.currentWeapon = "laser"
        }
        
    }
    
    
    
    func winScreen(){
        let winLabel = SKLabelNode()
        winLabel.text = "YOU WIN!"
        winLabel.position = CGPoint(x: 0, y: 0)
        winLabel.fontSize = 60
        winLabel.fontColor = UIColor.black
        winLabel.fontName = "AmericanTypewriter-Bold"
        winLabel.zPosition = 3
        
        var stopNode = SKSpriteNode()
        stopNode = SKSpriteNode(color: UIColor.green, size: self.frame.size)
        stopNode.position = CGPoint(x: 0, y: 0)
        stopNode.zPosition = 2
    
        
        gameData.score = score
        let  scoreLabel1 = SKLabelNode(text: "Score: " + String(score))
        scoreLabel1.position = CGPoint(x:0, y: 150)
        scoreLabel1.fontName = "AmericanTypewriter-Bold"
        scoreLabel1.fontSize = 60
        scoreLabel1.fontColor = UIColor.white
        scoreLabel1.zPosition = 3
        
        self.removeAllChildren()
        self.gameTimer.invalidate()
        self.addChild(winLabel)
        self.addChild(stopNode)
        self.addChild(scoreLabel1)
        
        self.run(SKAction.wait(forDuration: 6)){
            self.startMenu()
        }
    }
    func startMenu(){
        if let scene = GKScene(fileNamed: "StartScenen") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! StartScene? {
                
                // Copy gameplay related content over to the scene
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        if (self.weaponButton.contains(pos)){
            

            boostWeapon()
            
        }
        if (self.bombButton.contains(pos)){
            
            if (spaceship.nrOfBombs >= 1){
                fireBomb()
            }
        }
        if (self.menuButton.contains(pos)){
            for node in self.children as [SKNode] {
                node.isPaused = true
            }
            startMenu()
            removeAllAliens()
            self.removeFromParent()
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        spaceship.run(SKAction.move(to: CGPoint(x: pos.x, y: -self.frame.height/2 + 300), duration: 0))
       // thruster.position = CGPoint(x: spaceship.position.x - 10, y: spaceship.position.y - 50)
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
    
    
    func startMusic(){
        music = SKAudioNode(fileNamed: "music.mp3")
        self.run(SKAction.repeatForever(SKAction.playSoundFileNamed("soloSpaceOst", waitForCompletion: true)))
        print("Music!")
    }
    func removeAliens(Alien : SKSpriteNode){
        //self.alienQueue -= 1
        self.currentNrOfAliens -= 1
        Alien.run(SKAction.removeFromParent())
        
    }
    func removeAllAliens(){
        alienQueue = 0
        self.removeAllChildren()
        
    }
    
    func quit(){
        
    }
    func pause(){
        
    }
    func resume(){
    
    }
    
}
