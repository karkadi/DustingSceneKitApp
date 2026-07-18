//
//  ContentView.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 18/07/2026.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    var scene: SKScene {
        let scene = MarvelDustingScene()
        scene.size = CGSize(width: 300, height: 300)
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            SpriteView(scene: scene)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
