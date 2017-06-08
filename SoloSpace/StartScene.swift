//
//  GameScene.swift
//  SoloSpaceV2
//
//  Created by Anders Vinblad on 2017-05-09.
//  Copyright © 2017 Anders Vinblad. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreData

class StartScene: SKScene {
    var started = false
    let gameData = GameData.shared
    var level = [SKSpriteNode]()
    var backgroundMusic: SKAudioNode!
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var newGameButton :     SKSpriteNode!
    var levelSelectButton:  SKSpriteNode!
    var loadoutButton :     SKSpriteNode!
    var highScoreLabel:     SKLabelNode!
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var starField:SKEmitterNode!
    var starField2:SKEmitterNode!
    let displaySize: CGRect = UIScreen.main.bounds
    var menuItems = [SKSpriteNode]()
    var loadoutMenuItems = [SKSpriteNode]()
    override func sceneDidLoad() {
        if (started == false){
        
        
        
        loadShopping()
        startMenu()
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
        
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            }
        }
    }
    
    
    
    func loadShopping(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Shopitem")
        
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
    
    func startMenu(){
        var CD = ShopThing()
        CD.makeNew(name: String(gameData.score), amount: " ", amountUnit: " ", bought: true)
        print(CD.getname())
       // self.menuItems.removeAll()
        self.removeChildren(in: level)
        let pulseUp = SKAction.scale(to: 1.5, duration: 1.5)
        let pulseDown = SKAction.scale(to: 1, duration: 1.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        newGameButton = SKSpriteNode(imageNamed: "quickStart")
        self.newGameButton.position = CGPoint(x: 0, y: 250)
        self.newGameButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
        self.newGameButton.zPosition = 1
        self.newGameButton.run(repeatPulse)
        
        
        
        levelSelectButton = SKSpriteNode(imageNamed: "selectLevel")
        self.levelSelectButton.position = CGPoint(x: 0, y: 0)
        self.levelSelectButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
        self.levelSelectButton.zPosition = 1
        self.levelSelectButton.run(repeatPulse)
        
        loadoutButton = SKSpriteNode(imageNamed: "loadout")
        self.loadoutButton.position = CGPoint(x: 0, y: -250)
        self.loadoutButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
        self.loadoutButton.zPosition = 1
        self.loadoutButton.run(repeatPulse)
        
        highScoreLabel = SKLabelNode(text: "High Score: " + String(gameData.score))
       // highScoreLabel = SKLabelNode(text: String(GameData.getscore()))

        highScoreLabel.position = CGPoint(x:0, y: 450)
        highScoreLabel.fontName = "AmericanTypewriter-Bold"
        highScoreLabel.fontSize = 60
        highScoreLabel.fontColor = UIColor.white
        self.highScoreLabel.run(repeatPulse)
        if(started == false){
            menuItems.append(levelSelectButton)
            menuItems.append(newGameButton)
            menuItems.append(loadoutButton)
            self.addChild(highScoreLabel)
            started = true
        }
        
        print("STARTMENU")
        
        for levels in 0...menuItems.count-1{
        self.addChild(menuItems[levels])
        }
        
        
    }
    
    func levelSelect(){
        self.removeChildren(in: menuItems)
        self.highScoreLabel.removeFromParent()
        level.removeAll()
        //self.newGameButton.removeFromParent()
        //  self.levelSelectButton.removeFromParent()
        //self.removeAllChildren()
        let pulseUp = SKAction.scale(to: 1.08, duration: 1)
        let pulseDown = SKAction.scale(to: 1, duration: 1)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        for levels in 0...4{
            var tempLevel = SKSpriteNode(imageNamed: "level" + String(levels + 1))
            tempLevel.run(repeatPulse)
            level.append(tempLevel)
        }
        
        for levels in 0...level.count-1{
            level[levels].position = CGPoint(x: 0, y: (500 - 200 * levels))
            level[levels].size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
            level[levels].zPosition = 1
            self.addChild(level[levels])
        }
        
        
        
    }
    
    func loadoutMenu(){
        self.highScoreLabel.removeFromParent()
        self.removeChildren(in: menuItems)
       // self.menuItems.removeAll()
        //level.removeAll()
        //self.newGameButton.removeFromParent()
        //  self.levelSelectButton.removeFromParent()
        //self.removeAllChildren()
        let pulseUp = SKAction.scale(to: 2, duration: 1.5)
        let pulseDown = SKAction.scale(to: 1, duration: 1.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        for levels in 0...3{
            var tempLevel = SKSpriteNode(imageNamed: "ship" + String(levels + 1))
            tempLevel.run(repeatPulse)
            loadoutMenuItems.append(tempLevel)
        }
        
        for levels in 0...loadoutMenuItems.count-1{
            loadoutMenuItems[levels].position = CGPoint(x: 0, y: (500 - 200 * levels))
            loadoutMenuItems[levels].size = CGSize(width: self.displaySize.width / 1.5, height: self.displaySize.height / 12)
            loadoutMenuItems[levels].zPosition = 1
            self.addChild(loadoutMenuItems[levels])
        }
        
        
        
    }
    
    func startGame(){
        self.removeAllChildren()
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                // Present the scene
                if let view = self.view as! SKView? {
                    
                    view.presentScene(sceneNode, transition: SKTransition.flipHorizontal(withDuration: 1))
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                    
                }
            }
        }
    }
    
    
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    func touchDown(atPoint pos : CGPoint) {
        
        
        
        
        
        
        
    }
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
        
        if (self.newGameButton.contains(pos)){
            self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
            
            startGame()
            
        }
        if (self.levelSelectButton.contains(pos)){
            self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
            
            levelSelect()
            
            
        }
        if (self.loadoutButton.contains(pos)){
            loadoutMenu()
            self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
            
        }
        if level.count >= 1 {
            for levels in 0...level.count-1{
                if (level[levels].contains(pos)){
                    gameData.difficulty = (levels + 1) * 2
                    startGame()
                }
            }
        }
        if loadoutMenuItems.count >= 1 {
            for levels in 0...loadoutMenuItems.count-1{
                if (loadoutMenuItems[levels].contains(pos)){
                    gameData.shipName = "ship" + String(levels + 1)
                    self.run(SKAction.playSoundFileNamed("select", waitForCompletion: false))
                    self.run(SKAction.wait(forDuration: 0.2)){
                        self.startMenu()
                    }
                    self.removeChildren(in: loadoutMenuItems)
                }
            }
        }
        
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
            
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
        self.run(SKAction.moveBy(x: 100, y: 0, duration: 1))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
