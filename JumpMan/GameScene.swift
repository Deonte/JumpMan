//
//  GameScene.swift
//  JumpMan
//
//  Created by Deonte on 4/13/19.
//  Copyright © 2019 Deonte. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  private var bgImage = SKSpriteNode()
  private var bgImageTexture = SKTexture(imageNamed: "GameSceneUI.png")
  private var playGameButton = UIButton()
  private var playGameButtonImage = UIImage(named: "PlayButton")
  
  
  // Screen size detection
  private let screenSize: CGRect = UIScreen.main.bounds
  
    override func didMove(to view: SKView) {
      
      // Set the background image
      bgImage = SKSpriteNode(texture: bgImageTexture, size: CGSize(width: self.frame.size.width, height:  self.frame.size.height))
      bgImage.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.height / 2)
      bgImage.zPosition = -1
      self.addChild(bgImage)
      
      // Access current screen width
      let screenWidth = screenSize.width
      
      // Request UITraitCollection instance
      let deviceIdiom = UIScreen.main.traitCollection.userInterfaceIdiom
      
      // Create a button name playGameButton to start the game.
      playGameButton = UIButton(type: .custom)
      playGameButton.setImage(playGameButtonImage, for: .normal)
      
      // Check the idom for the device type
      
      switch deviceIdiom {
      // Set the playButton size and position in the scene based on the decvice type
      case .phone:
        switch screenWidth {
        case 0...667:
          // iPhone 8
          playGameButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height / 2, width: 35, height: 35)
        case 668...736:
          // iPhone 8 plus
          playGameButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height / 2, width: 40, height: 40)
        default:
          // Iphone X, XS Max, XR
          playGameButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height / 2, width: 60, height: 60)
        }
      case.pad:
        switch screenWidth {
        case 0...1024:
          // Non Pro ipads
          playGameButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height / 2, width: 70, height: 70)
        default:
          //iPad pro and above
          playGameButton.frame = CGRect(x: self.frame.size.width / 2, y: self.frame.size.height / 2, width: 100, height: 100)
        }
        
      default:
        break
      }
      
      playGameButton.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
      playGameButton.layer.zPosition = 0
      playGameButton.accessibilityIdentifier = "IDplayGameButton"
      
      // Make the play game button perform an action when it is touched
      playGameButton.addTarget(self, action: #selector(playGameButtonAction), for: .touchUpInside)
      view.addSubview(playGameButton)
      
  }
  
 @objc func playGameButtonAction(sender: UIButton) {
    // Start the game and remove old UI elements from the view
    startGame()
  }
  
  func removeStuffFromTheView() {
    
    // Removes the playGameButton from the view
    playGameButton.removeFromSuperview()
  }
  
  func startGame() {
    // Removes stuff from view before the transition
    removeStuffFromTheView()
    
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
 
}
