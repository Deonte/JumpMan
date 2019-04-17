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
  
  private var platform = SKNode()
  private var ceiling = SKNode()
  private var spike = SKNode()
  private var sidewall = SKNode()
  private var water = SKNode()
  private var finish = SKNode()
  
  private var scoreNode = SKNode()
  private var scoreNodeGroup = TMXObjectGroup()
  
  private var levelBackgroundColor: UIColor = #colorLiteral(red: 0.4431372549, green: 0.8431372549, blue: 0.9529411765, alpha: 1)
  private let screenSize: CGRect = UIScreen.main.bounds
  
  private let mrJumpCategory: UInt32 = 1 << 0
  private let enemyCategory: UInt32 = 1 << 1
  private let scoreCategory: UInt32 = 1 << 2
  private let finishCategory: UInt32 = 1 << 3
  
  // Variable for side scroll
  private var levelOneSpeed: CGFloat = 6
  private var isAlive = Bool()
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonThingsToInit()
  }
  
  override init(size: CGSize) {
    super.init(size: size)
    commonThingsToInit()
  }
  
  func commonThingsToInit() {
    
    // Adding the level one map to the world Node
    levelOneMap?.zPosition = 0
    worldNode.addChild(levelOneMap!)
    
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
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    // Check to see if mr jump isAlive
    if isAlive {
      
      // Setting up the functionality to move things from the right to the left (platform)
      let s = (((levelOneMap?.position.x)! - speed) - self.frame.width) * -1.0
      let w = CGFloat((levelOneMap?.mapSize.width)!) * CGFloat((levelOneMap?.tileSize.width)!)
      levelOneSpeed = s > w ? 0 : levelOneSpeed
      // MARK: HAVE TO FIND BETTER LOGIC TO STOP MAP WHEN TILE MAP ENDED

      // Moving the levelOneMap, Spike, Ceiling, and the platform physics
      levelOneMap?.position.x -= levelOneSpeed
    
    }
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
  }
  
  
  
  
}
