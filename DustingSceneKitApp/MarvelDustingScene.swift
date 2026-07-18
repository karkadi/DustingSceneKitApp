//
//  MarvelDustingScene.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 27/10/2025.
//

import SpriteKit

class MarvelDustingScene: SKScene {
    
    private struct Particle {
        let node: SKSpriteNode
        let origPoint: CGPoint
        var coordinate: Coordinate3D
        var chaosVelocity: Coordinate3D
        var layer: Int
        var hasStartedDisintegration: Bool
        var isReturning: Bool
        
        struct Coordinate3D {
            var x: CGFloat
            var y: CGFloat
            var z: CGFloat
        }
        
        init(node: SKSpriteNode, point: CGPoint, layer: Int) {
            self.node = node
            self.origPoint = point
            self.coordinate = .init(x: point.x, y: point.y, z: 0)
            self.chaosVelocity = .init(
                x: CGFloat.random(in: -0.01...0.01),
                y: CGFloat.random(in: -0.01...0.01),
                z: CGFloat.random(in: -0.01...0.01)
            )
            self.layer = layer
            self.hasStartedDisintegration = false
            self.isReturning = false
        }
    }
    
    private var particles: [Particle] = []
    private var disintegrationStarted = false
    private var targetPoint = CGPoint.zero
    private let totalLayers: Int = 16
    private let layerDelay = 0.1
    private var nextSceneButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        let titleLabel = SKLabelNode(text: "Marvel dusting disintegration")
        titleLabel.fontName = "Arial-BoldMT"
        titleLabel.fontSize = 12
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 20)
        addChild(titleLabel)
        
        targetPoint = CGPoint(x: size.width * 0.4 + size.width / 2, y: size.height * 0.4 + size.height / 2)
        createNextSceneButton()
        
        Task {
            await createParticlesFromImage(named: "lord", scale: 1.0)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Check if next scene button was tapped
        if touchedNode.name == "nextSceneButton" || touchedNode.name == "buttonLabel" {
            Task { await moveToNextScene() }
            return
        }
        
        if !disintegrationStarted {
            startDisintegration()
        } else {
            startIntegration()
        }
    }
    
    private func createNextSceneButton() {
        // Create button background
        nextSceneButton = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 20))
        nextSceneButton.position = CGPoint(x: 30, y: 20)
        nextSceneButton.name = "nextSceneButton"
        nextSceneButton.zPosition = 1000 // Ensure it's on top
        
        // Create button label
        let buttonLabel = SKLabelNode(text: "Next")
        buttonLabel.fontName = "Arial-BoldMT"
        buttonLabel.fontSize = 12
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.name = "buttonLabel"
        
        nextSceneButton.addChild(buttonLabel)
        addChild(nextSceneButton)
        
        // Add button animation to make it more visible
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        nextSceneButton.run(SKAction.repeatForever(pulse))
    }
    
    private func createParticlesFromImage(named imageName: String, scale: CGFloat = 1.0) async {
        
        guard let imageInfo = await ImageDecoder.decodeImageToPixels(named: imageName) else {
            print("Failed to decode Image")
            return
        }
        
        let visiblePixels = imageInfo.pixels.filter { pixel in
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            pixel.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return alpha > 0.7
        }
        
        print("Creating \(visiblePixels.count) particles from Image")
        
        let minY = visiblePixels.map { $0.y }.min() ?? 0
        let maxY = visiblePixels.map { $0.y }.max() ?? 1
        let layerHeight = Double(maxY - minY) / Double(totalLayers)
        
        for pixel in visiblePixels {
            let particleSize: CGFloat = 1.0
            let particle = SKSpriteNode(color: pixel.color, size: CGSize(width: particleSize, height: particleSize))
            
            let x = CGFloat(pixel.x - imageInfo.width / 2) * scale + size.width / 2
            let y = CGFloat(pixel.y - imageInfo.height / 2) * scale + size.height / 2
            particle.position = CGPoint(x: x, y: y)
            addChild(particle)
            
            let normalizedY = Double(pixel.y - minY)
            let layer = min(totalLayers - 1, Int(normalizedY / layerHeight))
            
            particles.append(
                Particle(node: particle, point: CGPoint(x: x, y: y), layer: layer)
            )
        }
        startDisintegration()
    }
    
    private func moveToNextScene() async {
        // Remove button pulse animation
        nextSceneButton.removeAllActions()
        
        // Create transition effect
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        await nextSceneButton.runAsync(fadeOut)
        
        await withTaskGroup(of: Void.self) { group in
            for particle in particles {
                group.addTask {
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    await particle.node.runAsync(fadeOut)
                }
            }
        }
        
        // Transition to a new scene
        let nextScene = RotatingDustingScene(size: self.size)
        nextScene.scaleMode = self.scaleMode
        let transition = SKTransition.fade(withDuration: 1.0)
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.view?.presentScene(nextScene, transition: transition)
            continuation.resume(returning: ())
        }
    }
    
    private func startDisintegration() {
        disintegrationStarted = true
        startLayeredDisintegration()
    }
    
    private func startIntegration() {
        disintegrationStarted = false
        startLayeredIntegration()
    }
    
    private func startLayeredDisintegration() {
        for layer in (0..<totalLayers).reversed() {
            let delay = TimeInterval(abs(layer - totalLayers + 1)) * layerDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.activateLayerForDisintegration(layer)
            }
        }
    }
    
    private func startLayeredIntegration() {
        // For integration, go from bottom to top (layer 0 to 4)
        for layer in 0..<totalLayers {
            let delay = TimeInterval(layer) * layerDelay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.activateLayerForIntegration(layer)
            }
        }
    }
    
    private func activateLayerForDisintegration(_ layer: Int) {
        for index in particles.indices where particles[index].layer == layer && !particles[index].hasStartedDisintegration {
            particles[index].hasStartedDisintegration = true
            particles[index].isReturning = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.startParticleMovementToTarget(particleIndex: index)
            }
        }
    }
    
    func activateLayerForIntegration(_ layer: Int) {
        for index in particles.indices where particles[index].layer == layer && particles[index].hasStartedDisintegration {
            particles[index].isReturning = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.startParticleReturnToOrigin(particleIndex: index)
            }
        }
    }
    
    private func startParticleReturnToOrigin(particleIndex: Int) {
        let particle = particles[particleIndex]
        let startPosition = particle.node.position
        
        // Stop any existing actions
        particle.node.removeAllActions()
        
        // Calculate return path with reverse spiral effect
        let returnAction = SKAction.customAction(withDuration: 3.0) { [weak self] node, elapsed in
            guard let self = self else { return }
            
            let progress = elapsed / 3.0
            let easeOut = 1.0 - pow(1.0 - progress, 2)
            
            // Reverse spiral effect
            let spiralAngle = (1.0 - progress) * .pi * 4
            let spiralStrength: CGFloat = 2.0
            let spiralX = cos(spiralAngle) * spiralStrength * (1.0 - progress)
            let spiralY = sin(spiralAngle) * spiralStrength * (1.0 - progress)
            
            // Decreasing chaos as particle approaches origin
            let chaosStrength: CGFloat = 1.5
            let currentChaos = chaosStrength * (1.0 - progress)
            let chaosX = CGFloat.random(in: -currentChaos...currentChaos)
            let chaosY = CGFloat.random(in: -currentChaos...currentChaos)
            
            // Interpolate from current position to original position
            let currentX = startPosition.x
            let currentY = startPosition.y
            let targetX = particle.origPoint.x
            let targetY = particle.origPoint.y
            
            let newX = currentX + (targetX - currentX) * easeOut + spiralX + chaosX
            let newY = currentY + (targetY - currentY) * easeOut + spiralY + chaosY
            
            // Fade in as particle returns
            node.alpha = progress
            
            // Update position
            node.position = CGPoint(x: newX, y: newY)
            
            // Update 3D coordinate (returning to original Z)
            if particleIndex < self.particles.count {
                self.particles[particleIndex].coordinate.z = (1.0 - progress) * 100
            }
        }
        
        // Sequence for return animation
        let wait = SKAction.wait(forDuration: Double.random(in: 0...0.3))
        let completeReturn = SKAction.run { [weak self] in
            // Final cleanup when return is complete
            if particleIndex < self?.particles.count ?? 0 {
                self?.particles[particleIndex].hasStartedDisintegration = false
                self?.particles[particleIndex].isReturning = false
                self?.particles[particleIndex].node.alpha = 1.0
                self?.particles[particleIndex].node.position = particle.origPoint
            }
        }
        
        let sequence = SKAction.sequence([wait, returnAction, completeReturn])
        particle.node.run(sequence)
    }
    
    private func startParticleMovementToTarget(particleIndex: Int) {
        let particle = particles[particleIndex]
        
        // Stop any existing actions
        particle.node.removeAllActions()
        
        let direction = CGVector(
            dx: targetPoint.x - particle.node.position.x,
            dy: targetPoint.y - particle.node.position.y
        )
        
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        let normalizedDirection = CGVector(
            dx: direction.dx / length,
            dy: direction.dy / length
        )
        
        let spiralStrength: CGFloat = 2.0
        let chaosStrength: CGFloat = 1.5
        
        let moveAction = SKAction.customAction(withDuration: 3.0) { [weak self] node, elapsed in
            guard let self = self else { return }
            
            let progress = elapsed / 3.0
            let easeOut = 1.0 - pow(1.0 - progress, 2)
            
            // Base movement toward target
            let baseX = particle.origPoint.x + normalizedDirection.dx * easeOut * 200
            let baseY = particle.origPoint.y + normalizedDirection.dy * easeOut * 200
            
            // Spiral effect
            let spiralAngle = progress * .pi * 4
            let spiralX = cos(spiralAngle) * spiralStrength * progress
            let spiralY = sin(spiralAngle) * spiralStrength * progress
            
            // Random chaos that decreases over time
            let currentChaos = chaosStrength * (1.0 - progress)
            let chaosX = CGFloat.random(in: -currentChaos...currentChaos)
            let chaosY = CGFloat.random(in: -currentChaos...currentChaos)
            
            // Final position
            let finalX = baseX + spiralX + chaosX
            let finalY = baseY + spiralY + chaosY
            
            // Fade out
            node.alpha = 1.0 - progress
            
            // Update position
            node.position = CGPoint(x: finalX, y: finalY)
            
            // Update particle coordinate for 3D effect
            if particleIndex < self.particles.count {
                self.particles[particleIndex].coordinate.z = progress * 100
            }
        }
        
        let wait = SKAction.wait(forDuration: Double.random(in: 0...0.5))
        let sequence = SKAction.sequence([wait, moveAction])
        
        particle.node.run(sequence)
    }
    
}
