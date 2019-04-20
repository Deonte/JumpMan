//
//  LevelOne.swift
//  JumpMan
//
//  Created by Deonte on 4/13/19.
//  Copyright © 2019 Deonte. All rights reserved.
//

import Foundation
import SpriteKit

class LevelOne: SKScene, SKPhysicsContactDelegate {
  
  private let worldNode = SKNode()
  
  private let levelOneMap = JSTileMap(named: "DEMOMrJumpCourse.tmx")
  private let mountainsFG = JSTileMap(named: "DEMOMrJumpMountainsFG.tmx")
  private let mountainsBG = JSTileMap(named: "DEMOMrJumpMountainsBG.tmx")
  private let cloudsFG = JSTileMap(named: "DEMOMrJumpCloudsFG.tmx")
  private let cloudsBG = JSTileMap(named: "DEMOMrJumpCloudsBG.tmx")
  
  private var platform = SKNode()
  private var ceiling = SKNode()
  private var spike = SKNode()
  private var sidewall = SKNode()
  private var water = SKNode()
  private var finish = SKNode()
  
  private var scoreNode = SKNode()
  private var scoreNodeGroup = TMXObjectGroup()
  private var xPositionIndex = Int()
  
  // Creating mrjump
  private var mrJump = SKSpriteNode(imageNamed: "Character0.png")
  
  private var levelBackgroundColor: UIColor = #colorLiteral(red: 0.4431372549, green: 0.8431372549, blue: 0.9529411765, alpha: 1)
  private var uiBlurImage = UIImage(named: "UIBlurImage")
  private var uiBlurImageView = UIImageView()
  
  private var restartGameButton = UIButton()
  private var restartGameButtonImage = UIImage(named: "RestartGameButton")
  
  private let screenSize: CGRect = UIScreen.main.bounds
  
  private let mrJumpCategory: UInt32 = 1 << 0
  private let enemyCategory: UInt32 = 1 << 1
  private let scoreCategory: UInt32 = 1 << 2
  private let finishCategory: UInt32 = 1 << 3
  
  // Variable for side scroll
  private var levelOneSpeed: CGFloat = 4 // Change back to 6 to normal speed
  private var mountainsFGSpeed: CGFloat = 1
  private var mountainsBGSpeed: CGFloat = 0.5
  
  private var isAlive = Bool()
  
  // Save User Settings
  private let userSettingsDefaults: UserDefaults = .standard
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonThingsToInit()
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    commonThingsToInit()
  }
  
  func commonThingsToInit() {
    
    // Add the mountainsBG map to the scene
    mountainsBG?.zPosition = -4
    worldNode.addChild(mountainsBG!)
    
    // Add the cloudsBG map to the scene
    cloudsBG?.zPosition = -3
    worldNode.addChild(cloudsBG!)
    
    // Add the mountains fg to the scene
    mountainsFG?.zPosition = -2
    worldNode.addChild(mountainsFG!)
    
    // Add the cloudsFG map to the scene
    cloudsFG?.zPosition = -1
    worldNode.addChild(cloudsFG!)
    
    // Adding the level one map to the world Node
    levelOneMap?.zPosition = 0
    worldNode.addChild(levelOneMap!)
    
    // Gravity Properties
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -11)
    physicsWorld.contactDelegate = self
    
    // MARK: Mr Jump
    // Setup mrJump Character
    let startLocation = CGPoint(x: self.frame.size.width / 4 , y: 250)
    mrJump.position = startLocation
    mrJump.size = CGSize(width: mrJump.frame.size.width, height: mrJump.frame.size.height)
    
    // Set up the path for the SKPhysics body
    let mrJumpOffsetX = CGFloat(mrJump.frame.size.width * mrJump.anchorPoint.x)
    let mrJumpOffsetY = CGFloat(mrJump.frame.size.width * mrJump.anchorPoint.y)
    let mrJumpPath = CGMutablePath()
    mrJumpPath.move(to: CGPoint(x: 3 - mrJumpOffsetX, y: 0 - mrJumpOffsetY))
    mrJumpPath.addLine(to: CGPoint(x: 15 - mrJumpOffsetX, y: 0 - mrJumpOffsetY))
    mrJumpPath.addLine(to: CGPoint(x: 15 - mrJumpOffsetX, y: 48 - mrJumpOffsetY))
    mrJumpPath.addLine(to: CGPoint(x: 3 - mrJumpOffsetX, y: 48 - mrJumpOffsetY))
    mrJumpPath.closeSubpath()
    mrJump.physicsBody = SKPhysicsBody(polygonFrom: mrJumpPath)
    mrJump.physicsBody?.allowsRotation = false
    mrJump.physicsBody?.isDynamic = true
    mrJump.physicsBody?.friction = 0.0
    mrJump.physicsBody?.restitution = 0.0
    
    // Add mrJump to its own category
    mrJump.physicsBody?.categoryBitMask = mrJumpCategory
    
    // mrJump can collide with the enemyCategory
    mrJump.physicsBody?.collisionBitMask = enemyCategory
    
    // Notification is made when mrJump collides with the enemy
    mrJump.physicsBody?.contactTestBitMask = enemyCategory
    
    // Animate mrJump to make him run
    var mrJumpRunning = [SKTexture]()
    for i in 0...7 {
      mrJumpRunning.append(SKTexture(imageNamed: "Character\(i)"))
    }
    
    let runningAction = SKAction.animate(with: mrJumpRunning, timePerFrame: 0.1)
    mrJump.run(SKAction.repeatForever(runningAction))
    
    // Add mrJump to the worldNode
    worldNode.addChild(mrJump)
    
    //MARK: Platforms
    // Accessing the object layer in the tmx file to get all the platform data
    let platformGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Platform"))! // The group name is case sensitive
    
    for object in 0..<platformGroup.objects.count {
      let platformObject = platformGroup.objects.object(at: object) as! NSDictionary
      
      let width = platformObject.object(forKey: "width") as! String
      let height = platformObject.object(forKey: "height") as! String
      let platformSize = CGSize(width: Int(width)!, height: Int(height)!)
      let platforms = SKSpriteNode(color: .clear, size: platformSize)
      let y = platformObject.object(forKey: "y") as! Int
      let x = platformObject.object(forKey: "x") as! Int
      
      platforms.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      platforms.physicsBody = SKPhysicsBody(rectangleOf: platformSize)
      platforms.physicsBody?.isDynamic = false
      platforms.physicsBody?.friction = 0.0
      platforms.physicsBody?.restitution = 0.0
      
      // Add the node platforms to the node and continue to the loop through the group and access the next platformObject in the group
      platform.addChild(platforms)
    }
    
    // Add the node platform to the worldNode
    worldNode.addChild(platform)
    
    //MARK: Ceiling
    // Accessing the object layer in the tmx file to get all the ceiling data
    let ceilingGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Ceiling"))! // The group name is case sensitive
    
    for object in 0..<ceilingGroup.objects.count {
      let ceilingObject = ceilingGroup.objects.object(at: object) as! NSDictionary
      
      let width = ceilingObject.object(forKey: "width") as! String
      let height = ceilingObject.object(forKey: "height") as! String
      let ceilingSize = CGSize(width: Int(width)!, height: Int(height)!)
      let ceilings = SKSpriteNode(color: .clear, size: ceilingSize)
      let y = ceilingObject.object(forKey: "y") as! Int
      let x = ceilingObject.object(forKey: "x") as! Int
      
      ceilings.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      ceilings.physicsBody = SKPhysicsBody(rectangleOf: ceilingSize)
      ceilings.physicsBody?.isDynamic = false
      ceilings.physicsBody?.friction = 0.0
      ceilings.physicsBody?.restitution = 0.0
      
      // Add the node ceilings to the node and continue to the loop through the group and access the next ceilingObject in the group
      ceiling.addChild(ceilings)
    }
    // Add the node ceiling to the worldNode
    worldNode.addChild(ceiling)
    
    //MARK: Spikes
    // Accessing the object layer in the tmx file to get all the spike data
    let spikeGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Spikes"))! // The group name is case sensitive
    
    for object in 0..<spikeGroup.objects.count {
      let spikeObject = spikeGroup.objects.object(at: object) as! NSDictionary
      
      let width = spikeObject.object(forKey: "width") as! String
      let height = spikeObject.object(forKey: "height") as! String
      let spikeSize = CGSize(width: Int(width)!, height: Int(height)!)
      let spikes = SKSpriteNode(color: .clear, size: spikeSize)
      let y = spikeObject.object(forKey: "y") as! Int
      let x = spikeObject.object(forKey: "x") as! Int
      
      spikes.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      spikes.physicsBody = SKPhysicsBody(rectangleOf: spikeSize)
      spikes.physicsBody?.isDynamic = false
      // Add the spikes to its own category
      spikes.physicsBody?.categoryBitMask = enemyCategory
      // Notification is made when Jump Man cololides with the spikes
      spikes.physicsBody?.contactTestBitMask = mrJumpCategory
      
      // Add the node spikes to the node and continue to the loop through the group and access the next spikeObject in the group
      spike.addChild(spikes)
    }
    // Add the node spike to the worldNode
    worldNode.addChild(spike)
    
    //MARK: SideWall
    // Accessing the object layer in the tmx file to get all the sidewall data
    let sidewallGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Sidewall"))! // The group name is case sensitive
    
    for object in 0..<sidewallGroup.objects.count {
      let sidewallObject = sidewallGroup.objects.object(at: object) as! NSDictionary
      
      let width = sidewallObject.object(forKey: "width") as! String
      let height = sidewallObject.object(forKey: "height") as! String
      let sidewallSize = CGSize(width: Int(width)!, height: Int(height)!)
      let sidewalls = SKSpriteNode(color: .clear, size: sidewallSize)
      let y = sidewallObject.object(forKey: "y") as! Int
      let x = sidewallObject.object(forKey: "x") as! Int
      
      sidewalls.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      sidewalls.physicsBody = SKPhysicsBody(rectangleOf: sidewallSize)
      sidewalls.physicsBody?.isDynamic = false
      // Add the spikes to its own category
      sidewalls.physicsBody?.categoryBitMask = enemyCategory
      // Notification is made when Jump Man cololides with the spikes
      sidewalls.physicsBody?.contactTestBitMask = mrJumpCategory
      
      // Add the node sidewalls to the node and continue to the loop through the group and access the next sidewallObject in the group
      sidewall.addChild(sidewalls)
    }
    // Add the node sidewall to the worldNode
    worldNode.addChild(sidewall)
    
    //MARK: Water
    // Accessing the object layer in the tmx file to get all the water data
    let waterGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Water"))! // The group name is case sensitive
    
    for object in 0..<waterGroup.objects.count {
      let waterObject = waterGroup.objects.object(at: object) as! NSDictionary
      
      let width = waterObject.object(forKey: "width") as! String
      let height = waterObject.object(forKey: "height") as! String
      let waterSize = CGSize(width: Int(width)!, height: Int(height)!)
      let waters = SKSpriteNode(color: .clear, size: waterSize)
      let y = waterObject.object(forKey: "y") as! Int
      let x = waterObject.object(forKey: "x") as! Int
      
      waters.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      waters.physicsBody = SKPhysicsBody(rectangleOf: waterSize)
      waters.physicsBody?.isDynamic = false
      // Add the water to its own category
      waters.physicsBody?.categoryBitMask = enemyCategory
      // Notification is made when Jump Man cololides with the water
      waters.physicsBody?.contactTestBitMask = mrJumpCategory
      
      // Add the node waters to the node and continue to the loop through the group and access the next waterObject in the group
      water.addChild(waters)
    }
    // Add the node water to the worldNode
    worldNode.addChild(water)
    
    //MARK: Finish
    // Accessing the object layer in the tmx file to get all the finish data
    let finishGroup: TMXObjectGroup = (self.levelOneMap?.groupNamed("Finish"))! // The group name is case sensitive
    
    for object in 0..<finishGroup.objects.count {
      let finishObject = finishGroup.objects.object(at: object) as! NSDictionary
      
      let width = finishObject.object(forKey: "width") as! String
      let height = finishObject.object(forKey: "height") as! String
      let finishSize = CGSize(width: Int(width)!, height: Int(height)!)
      let finishes = SKSpriteNode(color: .clear, size: finishSize)
      let y = finishObject.object(forKey: "y") as! Int
      let x = finishObject.object(forKey: "x") as! Int
      
      finishes.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      finishes.physicsBody = SKPhysicsBody(rectangleOf: finishSize)
      finishes.physicsBody?.isDynamic = false
      // Add the spikes to its own category
      finishes.physicsBody?.categoryBitMask = finishCategory
      // Notification is made when Jump Man cololides with the finish node
      finishes.physicsBody?.contactTestBitMask = mrJumpCategory
      
      // Add the node finishes to the node and continue to the loop through the group and access the next finishObject in the group
      finish.addChild(finishes)
    }
    // Add the node finishes to the worldNode
    worldNode.addChild(finish)
    
    //MARK: Score
    // Accessing the object layer in the tmx file to get all the score data
    scoreNodeGroup = (levelOneMap?.groupNamed("Score"))! // The group name is case sensitive
    
    for object in 0..<scoreNodeGroup.objects.count {
      let scoreObject = scoreNodeGroup.objects.object(at: object) as! NSDictionary
      
      let width = scoreObject.object(forKey: "width") as! String
      let height = scoreObject.object(forKey: "height") as! String
      let scoreSize = CGSize(width: Int(width)!, height: Int(height)!)
      let scoreNodes = SKSpriteNode(color: .clear, size: scoreSize)
      let y = scoreObject.object(forKey: "y") as! Int
      let x = scoreObject.object(forKey: "x") as! Int
      
      scoreNodes.position = CGPoint(x: x + Int(width)!/2, y: y + Int(height)!/2)
      scoreNodes.physicsBody = SKPhysicsBody(rectangleOf: scoreSize)
      scoreNodes.physicsBody?.isDynamic = false
      // Add the spikes to its own category
      scoreNodes.physicsBody?.categoryBitMask = scoreCategory
      // Notification is made when Jump Man cololides with the finish node
      scoreNodes.physicsBody?.contactTestBitMask = mrJumpCategory
      
      // Add the node scoreNode to the node and continue to the loop through the group and access the next scoreObject in the group
      scoreNode.addChild(scoreNodes)
    }
    // Add the node scoreNode to the worldNode
    worldNode.addChild(scoreNode)
    
  }
  
  override func didMove(to view: SKView) {
    
    // Set the background color
    backgroundColor = levelBackgroundColor
    
    // Enable a trigger to allow the scene to move and pause when the player has been destroyed
    isAlive = true
    
    // Retrieve the highScore level Completion point from userDefaults
    kLevelOneHighScore = userSettingsDefaults.float(forKey: "LevelOneHighScore")
    
    // Add the world node to the screen and then scale it to fit the device widths/size
    addChild(worldNode)
    
    // Access the current screen width
    let screenWidth = screenSize.width
    
    // Request a UITraitCollection instance
    let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
    
    // Check the idiom for the device type
    switch deviceIdiom {
    case .phone:
      switch screenWidth {
      case 0...667:
        // iPhone 8
        worldNode.setScale(0.6)
      case 668...736:
        // iPhone 8 plus
        worldNode.setScale(0.7)
      default:
        // Iphone X, XS Max, XR
        worldNode.setScale(0.7)
      }
    case.pad:
      switch screenWidth {
      case 0...1024:
        // Non Pro ipads
        worldNode.setScale(1.2)
      default:
        //iPad pro and above
        worldNode.setScale(1.8)
      }
      
    default:
      break
    }
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // When touch ends return mrJump to the ground (platform)
    mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 0))
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    // Only allow mrJump to jump if he is on the ground (platform - zero y velocity)
    if mrJump.physicsBody?.velocity.dy == 0 {
      
      // Access the current screen width
      let screenWidth = screenSize.width
      
      // Request a UITraitCollection instance
      let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
      
      // Check the idiom for the device type
      switch deviceIdiom {
        // Apply the correct impulse for the device widths
      case .phone:
        switch screenWidth {
        case 0...667:
          // iPhone 8
          mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 16))
        case 668...736:
          // iPhone 8 plus
            mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 116))
        default:
          // Iphone X, XS Max, XR
            mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 16))
        }
      case.pad:
        switch screenWidth {
        case 0...1024:
          // Non Pro ipads
          mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 24))

        default:
          //iPad pro and above
          mrJump.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 28))
        }
        
      default:
        break
      }
      
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    // Check to see if mr jump isAlive
    if isAlive {
      
      // Setting up the functionality to move things from the right to the left (platform)
      let s = (((levelOneMap?.position.x)! - speed) - self.frame.width) * -1.0
      let w = CGFloat((levelOneMap?.mapSize.width)!) * CGFloat((levelOneMap?.tileSize.width)!) - CGFloat((levelOneMap?.mapSize.width)! + 400)
      levelOneSpeed = s > w ? 0 : levelOneSpeed
      // MARK: HAVE TO FIND BETTER LOGIC TO STOP MAP WHEN TILE MAP ENDED
      
      // Setting up the functionality to move things from the right to the left (MountainsFG and Clouds FG)
      let ss = (((mountainsFG?.position.x)! - speed) - self.frame.width) * 1.0
      let ww = CGFloat((mountainsFG?.mapSize.width)!) * CGFloat((mountainsFG?.tileSize.width)!)
      mountainsFGSpeed = ss > ww ? 0 : mountainsFGSpeed
      
      // moving the mountainsFG and the CloudsFG
      mountainsFG?.position.x -= mountainsFGSpeed
      cloudsFG?.position.x -= mountainsFGSpeed
      
      // Setting up the functionality to move things from the right to the left (MountainsBG and Clouds BG)
      let sss = (((mountainsBG?.position.x)! - speed) - self.frame.width) * 1.0
      let www = CGFloat((mountainsBG?.mapSize.width)!) * CGFloat((mountainsBG?.tileSize.width)!)
      mountainsBGSpeed = sss > www ? 0 : mountainsBGSpeed
      
      // moving the mountainsBG and the CloudsBG
      mountainsBG?.position.x -= mountainsBGSpeed
      cloudsBG?.position.x -= mountainsBGSpeed
      
      // Moving the levelOneMap, Spike, Ceiling, and the platform physics
      levelOneMap?.position.x -= levelOneSpeed
      platform.position.x -= levelOneSpeed
      ceiling.position.x -= levelOneSpeed
      spike.position.x -= levelOneSpeed
      sidewall.position.x -= levelOneSpeed
      water.position.x -= levelOneSpeed
      finish.position.x -= levelOneSpeed
      scoreNode.position.x -= levelOneSpeed
      
      
    }
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    
    switch contactMask {
      
    case scoreCategory | mrJumpCategory:
      // Passed a score milestone, percentage of level completed needs to increse by 1
      kScore += 2
      
      print("Passed another milestone: \(kScore)%")
      
    case mrJumpCategory | enemyCategory:
      print("enemy")
      // Stop the scene from moving as mrJump is dead
      isAlive = false
      /* Get the x position of the scoreNode object,
       we need to look into the object layer in the tile map called Score,
       kScore holds an Int that represents the amount of scoreNodeObjects passed through */
    
      // This is to account for the fact that we need to start by pulling out the first object in the scoreNodeGroup array (0 not 1)
      
      if kScore >= 1 {
        // 0 not 1
        xPositionIndex = Int(kScore - 1)
      } else {
        // We are ok after 1
        xPositionIndex = Int(kScore)
      }
      
      // Get the latest scoreNodeObject MrJump has passed through from the scoreNodeGroup array using xPositionIndex
      let scoreNodeObject = scoreNodeGroup.objects.object(at: xPositionIndex) as! NSDictionary
      
      // Access the x position in the scoreNodeObject and use that to compare it to see if it is the highest (Do that in saveTheXPosition function)
      kNodeXPosition = scoreNodeObject.object(forKey: "x") as! CGFloat
      
      // Call the game overlay with a delay
      delay(delay: kLevelTransitionDelay) {
        // Blur the background
        self.uiBlurImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.uiBlurImageView.image = self.uiBlurImage
        self.uiBlurImageView.layer.zPosition = 0
        self.uiBlurImageView.accessibilityIdentifier = "IDuiBlurImageView"
        self.view?.addSubview(self.uiBlurImageView)
        
        // Create a button called restartGameButton
        self.restartGameButton = UIButton(type: .custom)
        self.restartGameButton.setImage(self.restartGameButtonImage, for: .normal)
        
        // TODO: 10:00 min mark in video course
    
        // Access the current screen width
        let screenWidth = self.screenSize.width
        
        // Request a UITraitCollection instance
        let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
        
        // Check the idiom for the device type
        switch deviceIdiom {
        // Apply the correct impulse for the device widths
        case .phone:
          switch screenWidth {
          case 0...667:
            // iPhone 8
            self.restartGameButton.frame = CGRect(x: self.frame.size.width + self.restartGameButton.frame.size.width, y: self.frame.size.height / 2, width: 100, height: 115)
          case 668...736:
            // iPhone 8 plus
            self.restartGameButton.frame = CGRect(x: self.frame.size.width + self.restartGameButton.frame.size.width, y: self.frame.size.height / 2, width: 115, height: 115)
          default:
            // Iphone X, XS Max, XR
            self.restartGameButton.frame = CGRect(x: self.frame.size.width + self.restartGameButton.frame.size.width, y: self.frame.size.height / 2, width: 130, height: 150)
          }
        case.pad:
          switch screenWidth {
          case 0...1024:
            // Non Pro ipads
            self.restartGameButton.frame = CGRect(x: self.frame.size.width + self.restartGameButton.frame.size.width, y: self.frame.size.height / 2, width: 150, height: 170)
          default:
            //iPad pro and above
            self.restartGameButton.frame = CGRect(x: self.frame.size.width + self.restartGameButton.frame.size.width, y: self.frame.size.height / 2, width: 280, height: 300)
          }
          
        default:
          break
        }
        
        self.restartGameButton.layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.restartGameButton.layer.zPosition = 2
        self.restartGameButton.accessibilityIdentifier = "IDrestartGameButton"
        
        self.restartGameButton.addTarget(self, action: #selector(self.restartGameButtonAction), for: .touchUpInside)
        self.view?.addSubview(self.restartGameButton)
        
        // Animate the restart game button
        UIView.animate(withDuration: kSceneAnimationTime, animations: {
          self.restartGameButton.layer.position.x = self.frame.size.width - self.restartGameButton.frame.size.width
        })
        
      }
      
      // Save the score (completion point) to userDefaults
      
    case mrJumpCategory | finishCategory:
      print("finish")
    default:
      break
    }
  }
  
  func delay(delay: Double, closure: @escaping ()-> ()) {
    let deadlineTime = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: closure)
    //DispatchQueue.main.asyncAfter(deadline: DISPATCH_TIME_NOW(Int64(delay * Double(NSEC_PER_SEC))), execute: closure)
    
  }
  
  private func saveTheScore() {
    // If kScore is higher than kLevelOneHighScore (userDefaults) then make kLevelOneHighScore the same as kScore and save it again to UserDefaults
    
    if kScore > kLevelOneHighScore {
      
      // Make kLevelOneHighScore the same as kScore
      kLevelOneHighScore = kScore
      
      // Save kLevelOneHighScore to userDefaults
      userSettingsDefaults.set(kLevelOneHighScore, forKey: "LevelOneHighScore")
    }
    
  }
  
  @objc private func restartGameButtonAction(sender: UIButton!) {
    
    // Call the func to restart the game with a delay
    delay(delay: 0.2) {
      self.restartGame()
    }
  }
  
  private func removeStuffFromTheView() {
    // Removes the uiBlurImageView from the view
    uiBlurImageView.removeFromSuperview()
    
    // Removes the restartGameButton from the view
    restartGameButton.removeFromSuperview()
    
    // Remove scene before transition
    scene?.removeFromParent()
    
    // Create teh scene to transition to
    let skView  = self.view! as SKView
    skView.ignoresSiblingOrder = true
    
    // Transition effect
    let transition = SKTransition.moveIn(with: .down, duration: kLevelTransitionDelay)
    
    // Variable holding levelOne class
    var scene: LevelOne!
    scene = LevelOne(size: skView.bounds.size)
    
    // Setting the scene to filll the screen
    scene.scaleMode = .aspectFill
    
    // Presenting the scene with the transition effect
    skView.presentScene(scene, transition: transition)
    
  }
  
  private func restartGame() {
    // Remove all the UIElements from the view first
    removeStuffFromTheView()
  }
  
}
