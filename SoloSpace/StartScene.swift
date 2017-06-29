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
	
	
	var hasPickedLevel = false
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
	var pointsNeeded:		SKLabelNode!
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    var starField:SKEmitterNode!
    var starField2:SKEmitterNode!
    let displaySize: CGRect = UIScreen.main.bounds
    var menuItems = [SKSpriteNode]()
    var loadoutMenuItems = [SKSpriteNode]()
	var loadoutMenuLabels = [SKLabelNode]()				////
	var levelMenuItems = [SKSpriteNode]()
	var shipMenuItems = [SKSpriteNode]()
	var weaponMenuItems = [SKSpriteNode]()
	var boostMenuItems = [SKSpriteNode]()

    override func sceneDidLoad() {
        if (started == false){
			
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
			
		}
    }
    
    func startMenu(){
		if (highScoreLabel != nil){
			highScoreLabel.removeFromParent()
		}
		self.run(SKAction.wait(forDuration: 0.5)){
		//gameData.saveData()
		self.hasPickedLevel = false
		self.gameData.loadData()
		if self.gameData.difficulty >= 5{
			self.currentLevelRow = Int(self.gameData.difficulty/5.0)
		}
       // self.menuItems.removeAll()
		
        self.removeChildren(in: self.level)
		self.removeChildren(in: self.levelMenuItems)
		self.removeChildren(in: self.loadoutMenuItems)
		self.removeChildren(in: self.shipMenuItems)
		self.level.removeAll()
		self.levelMenuItems.removeAll()
		self.loadoutMenuItems.removeAll()
        let pulseUp = SKAction.scale(to: 1.5, duration: 1.5)
        let pulseDown = SKAction.scale(to: 1, duration: 1.5)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
		
        self.newGameButton = SKSpriteNode(imageNamed: "quickStart")
        self.newGameButton.position = CGPoint(x: 0, y: 250)
        self.newGameButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
        self.newGameButton.zPosition = 1
        self.newGameButton.run(repeatPulse)
        
		
        self.levelSelectButton = SKSpriteNode(imageNamed: "selectLevel")
        self.levelSelectButton.position = CGPoint(x: 0, y: 0)
        self.levelSelectButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
        self.levelSelectButton.zPosition = 1
        self.levelSelectButton.run(repeatPulse)
        
		self.loadoutButton = SKSpriteNode(imageNamed: "loadout")
		self.loadoutButton.position = CGPoint(x: 0, y: -250)
		self.loadoutButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
		self.loadoutButton.zPosition = 1
		self.loadoutButton.run(repeatPulse)
		
		self.upgradeButton = SKSpriteNode(imageNamed: "UpgradeButton")
		self.upgradeButton.position = CGPoint(x: 0, y: -500)
		self.upgradeButton.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
		self.upgradeButton.zPosition = 1
		self.upgradeButton.run(repeatPulse)
		
			if (self.highScoreLabel == nil){
		self.highScoreLabel = SKLabelNode(text: "Upgrade-Points: " + String(self.gameData.score))
		self.highScoreLabel.position = CGPoint(x:0, y: 450)
		self.highScoreLabel.fontName = "AmericanTypewriter-Bold"
		self.highScoreLabel.fontSize = 40
		self.highScoreLabel.fontColor = UIColor.white
		self.highScoreLabel.run(repeatPulse)
		
		self.pointsNeeded = SKLabelNode(text: "Points needed: " + String(Int64(50 / self.gameData.attackRate)))
		self.pointsNeeded.position = CGPoint(x:0, y: 400)
		self.pointsNeeded.fontName = "AmericanTypewriter-Bold"
		self.pointsNeeded.fontSize = 30
		self.pointsNeeded.fontColor = UIColor.white
		self.pointsNeeded.run(repeatPulse)

		}
        if self.started == false{
            self.started = true
            self.menuItems.append(self.newGameButton)
			self.menuItems.append(self.levelSelectButton)
			self.menuItems.append(self.loadoutButton)
			self.menuItems.append(self.upgradeButton)

			//menuItems.append(self.highScoreLabel as! SKSpriteNode)
          //  self.addChild(self.highScoreLabel)
        }
		
        
			print("STARTMENU")
			self.removeChildren(in: self.menuItems)
			self.highScoreLabel.removeFromParent()
			self.pointsNeeded.removeFromParent()
			if self.menuItems.count >= 1{
				for levels in 0...self.menuItems.count-1{
					self.addChild(self.menuItems[levels])
				}
				self.addChild(self.highScoreLabel)
				self.addChild(self.pointsNeeded)
				//self.removeChildren(in: self.menuItems)
				//self.menuItems.removeAll()
			}
		}
    }
	
    func levelSelect(){
		self.run(SKAction.wait(forDuration: 0.5)){
        self.removeChildren(in: self.menuItems)
        self.highScoreLabel.removeFromParent()
		self.pointsNeeded.removeFromParent()
		self.removeChildren(in: self.levelMenuItems)
		self.levelMenuItems.removeAll()
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
			let tempLevelLabel = SKLabelNode(text: "level " + String((levels + 1) + ((self.currentLevelRow-1)*5)))
			tempLevelLabel.fontName = "AmericanTypewriter"
			tempLevelLabel.fontColor = UIColor.black
			tempLevelLabel.fontSize = 45
			tempLevelLabel.position.y -= 20
			tempLevelLabel.zPosition = 2
			tempLevel.addChild(tempLevelLabel)
            self.levelMenuItems.append(tempLevel)
			self.level.append(tempLevel)
			self.addChild(tempLevel)
        }
		
		var backButton = SKSpriteNode(imageNamed: "ArrowLeft")
		backButton.position = CGPoint(x: -self.size.width/2 + 70, y: -self.size.height/2.8)
		self.levelMenuItems.append(backButton)
		self.addChild(backButton)
		
		var nextButton = SKSpriteNode(imageNamed: "ArrowRight")
		nextButton.position = CGPoint(x: self.size.width/2 - 70, y: -self.size.height/2.8)
		self.levelMenuItems.append(nextButton)
		self.addChild(nextButton)
		
		var backToMenuButton = SKSpriteNode(imageNamed: "backButton")
		backToMenuButton.position = CGPoint(x: 0, y: -self.size.height/2.8)
		self.addChild(backToMenuButton)
		self.levelMenuItems.append(backToMenuButton)
		}
		
    }
	
	
	func loadoutMenu(){
		self.run(SKAction.wait(forDuration: 0.5)){

		self.highScoreLabel.removeFromParent()
		self.pointsNeeded.removeFromParent()
		self.removeChildren(in: self.menuItems)
		if self.loadoutMenuItems.isEmpty{
			self.loadoutMenuLabels.removeAll()
			let pulseUp = SKAction.scale(to: 1.3, duration: 1.5)
			let pulseDown = SKAction.scale(to: 1, duration: 1.5)
			let pulse = SKAction.sequence([pulseUp, pulseDown])
			let repeatPulse = SKAction.repeatForever(pulse)
			
		
		
			
				for levels in 0...4{
					//var tempLevel = SKSpriteNode(imageNamed: "level" + String(levels + 1))
					var tempLevel = SKSpriteNode(imageNamed: "EmptyButton")
					tempLevel.run(repeatPulse)
					tempLevel.position = CGPoint(x: 0, y: (500 - 200 * levels))
					tempLevel.size = CGSize(width: self.displaySize.width / 1.3, height: self.displaySize.height / 7)
					tempLevel.zPosition = 1
					var tempLevelLabel = SKLabelNode(text: "level ")
					tempLevelLabel.fontName = "AmericanTypewriter"
					tempLevelLabel.fontColor = UIColor.black
					tempLevelLabel.fontSize = 45
					tempLevelLabel.position.y -= 20
					tempLevelLabel.zPosition = 2
					//self.addChild(tempLevel)
					tempLevel.addChild(tempLevelLabel)
					self.loadoutMenuItems.append(tempLevel)
					self.loadoutMenuLabels.append(tempLevelLabel)
				}
		
			self.loadoutMenuLabels[0].text = "Reset"
			self.loadoutMenuLabels[1].text = "Weapon"
			self.loadoutMenuLabels[2].text = "Ship"
			self.loadoutMenuLabels[3].text = "Bomb"
			
			
			
			/*
			
			
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
		
		
*/
		}
		for index in 0...self.loadoutMenuItems.count - 1{
			self.addChild(self.loadoutMenuItems[index])
		}
		}
    }
	
	func shipSelect(){
		self.run(SKAction.wait(forDuration: 0.5)){
			self.highScoreLabel.removeFromParent()
			self.pointsNeeded.removeFromParent()
			//self.removeChildren(in: self.menuItems)
			//self.removeChildren(in: self.loadoutMenuItems)
			let pulseUp = SKAction.scale(to: 1.3, duration: 1.5)
			let pulseDown = SKAction.scale(to: 1, duration: 1.5)
			let pulse = SKAction.sequence([pulseUp, pulseDown])
			let repeatPulse = SKAction.repeatForever(pulse)
			
			
			for names in 0...3{
				var shipName = String( "ship" + String(names + 1))
			}
			self.shipNames.append("playerYellow")
			self.shipNames.append("playerBlue")
			self.shipNames.append("playerRed")
			self.shipNames.append("playerGreen")
			self.shipNames.append("playerWhite")
			
			
			
			var shipSprite = SKSpriteNode(imageNamed: self.shipNames[0])
			shipSprite.run(repeatPulse)
			shipSprite.position = CGPoint(x: 0, y: 0)
			shipSprite.size = CGSize(width: self.displaySize.width, height: self.displaySize.height / 2)
			shipSprite.zPosition = 1
			self.shipMenuItems.append(shipSprite)
			
			var backButton = SKSpriteNode(imageNamed: "ArrowLeft")
			backButton.position = CGPoint(x: -self.size.width/2 + 70, y: -self.size.height/2.8)
			self.shipMenuItems.append(backButton)
			
			var nextButton = SKSpriteNode(imageNamed: "ArrowRight")
			nextButton.position = CGPoint(x: self.size.width/2 - 70, y: -self.size.height/2.8)
			self.shipMenuItems.append(nextButton)
			
			var backToMenuButton = SKSpriteNode(imageNamed: "StartMenuButton")
			backToMenuButton.position = CGPoint(x: 0, y: -self.size.height/2.8)
			self.shipMenuItems.append(backToMenuButton)
			
			
			for index in 0...self.shipMenuItems.count - 1{
				self.addChild(self.shipMenuItems[index])
			}
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
		
    }
    func touchDown(atPoint pos : CGPoint) {
        
        
        
        
        
        
        
    }
    func touchUp(atPoint pos : CGPoint) {
		
		if  menuItems.isEmpty == false{
			
			if (menuItems[0].contains(pos)){
				self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
				self.removeChildren(in: menuItems)
				self.highScoreLabel.removeFromParent()
				self.pointsNeeded.removeFromParent()
				startGame()
				
			}
			if (menuItems[1].contains(pos)){
				self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
				self.removeChildren(in: menuItems)
				self.highScoreLabel.removeFromParent()
				self.pointsNeeded.removeFromParent()
				levelSelect()
				
				
			}
			if (menuItems[2].contains(pos)){
				
				self.removeChildren(in: menuItems)
				self.highScoreLabel.removeFromParent()
				self.pointsNeeded.removeFromParent()
				self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
				loadoutMenu()
				
			}
			
			if (menuItems[3].contains(pos)){ //UPGRADE
				if gameData.score >= Int64(50 / gameData.attackRate){
					self.gameData.score -= Int64(50 / gameData.attackRate)
					self.gameData.attackRate = gameData.attackRate/1.2
					self.gameData.saveData()
				}
				self.highScoreLabel.removeFromParent()
				self.pointsNeeded.removeFromParent()
				self.highScoreLabel.text = "Points: " + String(gameData.score)
				self.pointsNeeded.text = "Points needed: " + String(Int64(50 / self.gameData.attackRate))
				self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
				self.highScoreLabel.removeFromParent()
				self.pointsNeeded.removeFromParent()
				startMenu()
				
			}
		}
		if level.count >= 1 {
			for levels in 0...level.count-1{
				if (level[levels].contains(pos)){
					if(hasPickedLevel == false){
						hasPickedLevel = true
						self.gameData.difficulty = Double((levels + 1) + ((5 * currentLevelRow)) - 5)
						print("current Row: " + String(currentLevelRow))
						print("current Difficulty: " + String(self.gameData.difficulty))
						
						gameData.saveData()
						print(gameData.difficulty)
						print(currentLevelRow)
						startGame()
					}
				}
			}
			for levels in 5...levelMenuItems.count-1{
				if levelMenuItems.isEmpty == false{
					if levelMenuItems[levels].contains(pos){
						self.run(SKAction.playSoundFileNamed("select.wav", waitForCompletion: true))
						switch levels {
							
						case 5:
							print("Left Arrow")
							if (currentLevelRow >= 2){
								currentLevelRow -= 1
								print("current Row: " + String(currentLevelRow))
								levelSelect()
							}
							
						case 6:
							print("Right Arrow")
							currentLevelRow += 1
							levelSelect()
							print("current Row: " + String(currentLevelRow))
						case 7:
							print("Middle")
							startMenu()
							self.removeChildren(in: levelMenuItems)
						default:
							print("default levelMenuItems")
							startMenu()
							self.removeChildren(in: levelMenuItems)
						}
					}
				}
				
				
			}
			
		}
		if loadoutMenuItems.count >= 3 {
			for levels in 0...loadoutMenuItems.count-1{
				if loadoutMenuItems.isEmpty == false{
					if loadoutMenuItems[levels].contains(pos){
						switch levels {
						case 0:
							////RESET
							gameData.attackRate = 1
							self.run(SKAction.wait(forDuration: 0.2)){
								self.startMenu()
							}
							self.removeChildren(in: loadoutMenuItems)
							loadoutMenuItems.removeAll()
							
						case 1:
							//WEAPON
							startMenu()
							self.removeChildren(in: loadoutMenuItems)
							loadoutMenuItems.removeAll()
						case 2:
							//SHIPMENU
							self.removeChildren(in: loadoutMenuItems)
							loadoutMenuItems.removeAll()
							shipSelect()
							
						case 3:
							//BOMB
							startMenu()
							self.removeChildren(in: loadoutMenuItems)
							loadoutMenuItems.removeAll()
						default:
							print("default loadoutMenuItems")
						}
					}
					
				}
				
				
			}
		} //ok
		if shipMenuItems.count >= 1 {
			
			for levels in 0...shipMenuItems.count-1{
				if shipMenuItems.isEmpty == false{
					if shipMenuItems[levels].contains(pos){
						switch levels {
							
						case 0:
							gameData.shipName = shipNames[currentShipNr]
							self.run(SKAction.playSoundFileNamed("select", waitForCompletion: false))
							self.run(SKAction.wait(forDuration: 0.2)){
								self.startMenu()
							}
							self.removeChildren(in: shipMenuItems)
							shipMenuItems.removeAll()
							
						case 1:
							currentShipNr -= 1
							if currentShipNr <= -1{
								currentShipNr = NrOfShips - 1
							}
							currentShipNr = currentShipNr % NrOfShips
							print(currentShipNr)
							shipMenuItems[0].texture = SKTexture(imageNamed: shipNames[currentShipNr])
						case 2:
							currentShipNr += 1
							currentShipNr = currentShipNr % NrOfShips
							shipMenuItems[0].texture = SKTexture(imageNamed: shipNames[currentShipNr])
						case 3:
							startMenu()
							self.removeChildren(in: shipMenuItems)
						default:
							//startMenu()
							//self.removeChildren(in: shipMenuItems)
							print("default shiMenuItems")
						}
					}
				}
				
				
			}
		} // ok
		
		
		
		
    }
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let label = self.label {
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
