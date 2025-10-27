//
//  GameViewController.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 24/10/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = MarvelDustingScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .fill
        
        // Present the scene
        guard let skView = self.view as? SKView else { return }
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
