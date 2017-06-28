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
	
	var shipNames = [String]()
	var currentLevelRow = 1
    var currentLevelNr = 1
	var currentShipNr = 0
	let NrOfShips = 4
    var started = false
    let gameData = GameData.shared
    var level = [SKSpriteNode]()
    var backgroundMusic: SKAudioNode!
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
	var upgradeButton :		SKSpriteNode!
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
	var levelMenuItems = [SKSpriteNode]()
    override func sceneDidLoad() {
        //if (started == false){
        
        
        
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
		//gameData.saveData()
		gameData.loadData()
		if gameData.difficulty >= 5{
			currentLevelRow = Int(gameData.difficulty/5.0)
		}
       // self.menuItems.removeAll()
		
        self.removeChildren(in: level)
		self.removeChildren(in: levelMenuItems)
		self.removeChildren(in: loadoutMenuItems)
		level.removeAll()
		levelMenuItems.removeAll()
		loadoutMenuItems.removeAll()
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
		
		self.upgradeButton = SKSpriteNode(imageNamed: "UpgradeButton")
		self.upgradeButton.position = CGPoint(x: 0, y: -500)
		self.upgradeButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
		self.upgradeButton.zPosition = 1
		self.upgradeButton.run(repeatPulse)
		
        self.highScoreLabel = SKLabelNode(text: "Points: " + String(gameData.score))
        self.highScoreLabel.position = CGPoint(x:0, y: 450)
        self.highScoreLabel.fontName = "AmericanTypewriter-Bold"
        self.highScoreLabel.fontSize = 60
        self.highScoreLabel.fontColor = UIColor.white
        self.highScoreLabel.run(repeatPulse)

		
        if started == false{
            started = true
            menuItems.append(levelSelectButton)
            menuItems.append(newGameButton)
			menuItems.append(loadoutButton)
			menuItems.append(upgradeButton)

			//menuItems.append(self.highScoreLabel as! SKSpriteNode)
          //  self.addChild(self.highScoreLabel)
        }
		
        
        print("STARTMENU")
		self.removeChildren(in: menuItems)
		self.highScoreLabel.removeFromParent()
		if menuItems.count >= 1{
			for levels in 0...menuItems.count-1{
				self.addChild(menuItems[levels])
			}
			self.addChild(highScoreLabel)
		}
		
    }
	
    func levelSelect(){
        self.removeChildren(in: menuItems)
        self.highScoreLabel.removeFromParent()
		self.removeChildren(in: levelMenuItems)
		levelMenuItems.removeAll()
      //  level.removeAll()
        let pulseUp = SKAction.scale(to: 1.08, duration: 1)
        let pulseDown = SKAction.scale(to: 1, duration: 1)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        for levels in 0...4{
            //var tempLevel = SKSpriteNode(imageNamed: "level" + String(levels + 1))
			var tempLevel = SKSpriteNode(imageNamed: "EmptyButton")
            tempLevel.run(repeatPulse)
			tempLevel.position = CGPoint(x: 0, y: (500 - 200 * levels))
			tempLevel.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
			tempLevel.zPosition = 1
			var tempLevelLabel = SKLabelNode(text: "level " + String((levels + 1) + ((currentLevelRow-1)*5)))
			tempLevelLabel.fontName = "AmericanTypewriter"
			tempLevelLabel.fontColor = UIColor.black
			tempLevelLabel.fontSize = 45
			tempLevelLabel.position.y -= 20
			tempLevelLabel.zPosition = 2
			tempLevel.addChild(tempLevelLabel)
            levelMenuItems.append(tempLevel)
			level.append(tempLevel)
			self.addChild(tempLevel)
        }
		
		var backButton = SKSpriteNode(imageNamed: "ArrowLeft")
		backButton.position = CGPoint(x: -self.size.width/2 + 70, y: -self.size.height/2.8)
		levelMenuItems.append(backButton)
		self.addChild(backButton)
		
		var nextButton = SKSpriteNode(imageNamed: "ArrowRight")
		nextButton.position = CGPoint(x: self.size.width/2 - 70, y: -self.size.height/2.8)
		levelMenuItems.append(nextButton)
		self.addChild(nextButton)
		
		var backToMenuButton = SKSpriteNode(imageNamed: "backButton")
		backToMenuButton.position = CGPoint(x: 0, y: -self.size.height/2.8)
		self.addChild(backToMenuButton)
		levelMenuItems.append(backToMenuButton)

    }
	
	func loadoutMenu(){
		self.highScoreLabel.removeFromParent()
		self.removeChildren(in: menuItems)
		if loadoutMenuItems.isEmpty{
			let pulseUp = SKAction.scale(to: 2, duration: 1.5)
			let pulseDown = SKAction.scale(to: 1, duration: 1.5)
			let pulse = SKAction.sequence([pulseUp, pulseDown])
			let repeatPulse = SKAction.repeatForever(pulse)
			
			for names in 0...3{
				var shipName = String( "ship" + String(names + 1))
				//self.shipNames.append(shipName!)
			}
			self.shipNames.append("playerYellow")
			self.shipNames.append("playerBlue")
			self.shipNames.append("playerRed")
			self.shipNames.append("playerGreen")
			self.shipNames.append("playerWhite")

			
			
			var shipSprite = SKSpriteNode(imageNamed: shipNames[0])
			shipSprite.run(repeatPulse)
			shipSprite.position = CGPoint(x: 0, y: 0)
			shipSprite.size = CGSize(width: self.displaySize.width, height: self.displaySize.height / 2)
			shipSprite.zPosition = 1
			loadoutMenuItems.append(shipSprite)
			
			
			
			var backButton = SKSpriteNode(imageNamed: "ArrowLeft")
			backButton.position = CGPoint(x: -self.size.width/2 + 70, y: -self.size.height/2.8)
			loadoutMenuItems.append(backButton)
			
			var nextButton = SKSpriteNode(imageNamed: "ArrowRight")
			nextButton.position = CGPoint(x: self.size.width/2 - 70, y: -self.size.height/2.8)
			loadoutMenuItems.append(nextButton)
			
			var backToMenuButton = SKSpriteNode(imageNamed: "StartMenuButton")
			backToMenuButton.position = CGPoint(x: 0, y: -self.size.height/2.8)
			loadoutMenuItems.append(backToMenuButton)
		}
		
		for index in 0...loadoutMenuItems.count - 1{
			self.addChild(loadoutMenuItems[index])
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
                    
                    view.presentScene(sceneNode, transition: SKTransition.flipHorizontal(withDuration: 0.5))
                    view.ignoresSiblingOrder = true
                    
                   // view.showsFPS = true
                   // view.showsNodeCount = true
                    
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
			self.removeChildren(in: menuItems)
            startGame()
            
        }
        if (self.levelSelectButton.contains(pos)){
            self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
			self.removeChildren(in: menuItems)
            levelSelect()
            
            
        }
		if (self.loadoutButton.contains(pos)){
			loadoutMenu()
			self.removeChildren(in: menuItems)
			self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
			
		}
		
		if (self.upgradeButton.contains(pos)){

			if gameData.score >= Int64(50 / gameData.attackRate){
				gameData.score -= Int64(50 / gameData.attackRate)
				self.highScoreLabel.removeFromParent()
				self.highScoreLabel.text = "Points: " + String(gameData.score)
				self.addChild(highScoreLabel)
				gameData.attackRate = gameData.attackRate/1.2
			}
			self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
			
		}
        if level.count >= 1 {
            for levels in 0...level.count-1{
                if (level[levels].contains(pos)){
                    gameData.difficulty = Double((levels + 1) + (5 * currentLevelRow))
                    startGame()
                }
            }
			for levels in 5...levelMenuItems.count-1{
				if levelMenuItems[levels].contains(pos){
					self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
					switch levels {
						
					case 5:
						print("Left Arrow")
						if (currentLevelRow >= 2){
							currentLevelRow -= 1
							levelSelect()
						}
						
					case 6:
						print("Right Arrow")
						currentLevelRow += 1
						levelSelect()
						print(currentLevelRow)
					case 7:
						print("Middle")
						startMenu()
						self.removeChildren(in: levelMenuItems)
					default:
						startMenu()
						self.removeChildren(in: levelMenuItems)
					}
				}
				
			}

        }
        if menuItems.isEmpty == false{
            for levels in 0...menuItems.count-1{
                
            }
        }
		
		if loadoutMenuItems.count >= 1 {
			for levels in 0...loadoutMenuItems.count-1{
				if loadoutMenuItems[levels].contains(pos){
					switch levels {
						
					case 0:
						gameData.shipName = shipNames[currentShipNr]
						self.run(SKAction.playSoundFileNamed("select", waitForCompletion: false))
						self.run(SKAction.wait(forDuration: 0.2)){
							self.startMenu()
						}
						self.removeChildren(in: loadoutMenuItems)
						
					case 1:
						currentShipNr -= 1
						if currentShipNr <= -1{
							currentShipNr = NrOfShips - 1
						}
						currentShipNr = currentShipNr % NrOfShips
						print(currentShipNr)
						loadoutMenuItems[0].texture = SKTexture(imageNamed: shipNames[currentShipNr])
					case 2:
						currentShipNr += 1
						currentShipNr = currentShipNr % NrOfShips
						loadoutMenuItems[0].texture = SKTexture(imageNamed: shipNames[currentShipNr])
					case 3:
						startMenu()
						self.removeChildren(in: loadoutMenuItems)
					default:
						startMenu()
						self.removeChildren(in: loadoutMenuItems)
					}
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
