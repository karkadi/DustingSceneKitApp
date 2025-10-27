//
//  SKNode+Extension.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 27/10/2025.
//

import SpriteKit

// Extension to handle async SKNode operations
extension SKNode {
    @MainActor
    func runAsync(_ action: SKAction) async {
        await withCheckedContinuation { continuation in
            run(action) {
                continuation.resume()
            }
        }
    }
}
