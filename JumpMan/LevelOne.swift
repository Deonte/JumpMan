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
  
  private var levelBackgroundColor: UIColor = #colorLiteral(red: 0.4431372549, green: 0.8431372549, blue: 0.9529411765, alpha: 1)
  
  private let screenSize: CGRect = UIScreen.main.bounds
  
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
  }
  
  override func didMove(to view: SKView) {
    
    // Set the background color
    backgroundColor = levelBackgroundColor
    
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
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    
  }
  
  
  
  
}
