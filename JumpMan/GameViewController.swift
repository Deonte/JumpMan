//
//  GameViewController.swift
//  JumpMan
//
//  Created by Deonte on 4/13/19.
//  Copyright © 2019 Deonte. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
       
          // Configure the view
          let scene = GameScene(size: view.bounds.size)
          
          // Set the scale mode to scale to fit the window
          scene.scaleMode = .aspectFill
          scene.position = CGPoint(x: 0, y: 0)
          
          // Present the scene
          view.presentScene(scene)
          
          view.ignoresSiblingOrder = true
          
          view.showsFPS = false
          view.showsNodeCount = false
          view.showsPhysics = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
