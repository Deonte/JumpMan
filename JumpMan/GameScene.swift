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
  
    override func didMove(to view: SKView) {
      
      // Set the background image
      bgImage = SKSpriteNode(texture: bgImageTexture, size: CGSize(width: self.frame.size.width, height:  self.frame.size.height))
      bgImage.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.height / 2)
      bgImage.zPosition = -1
      self.addChild(bgImage)
    }
    
 
}
