//
//  RotatingDustingScene.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 27/10/2025.
//
import SpriteKit

@MainActor
class RotatingDustingScene: SKScene {
    
    private struct Particle {
        let node: SKSpriteNode
        var origPoint: CGPoint
        var coordinate: Coordinate3D
        var chaosVelocity: Coordinate3D
        var yRotation: CGFloat
        var yRotationSpeed: CGFloat

        struct Coordinate3D {
            var x: CGFloat
            var y: CGFloat
            var z: CGFloat
        }
        
        init(node: SKSpriteNode, point: CGPoint) {
            self.node = node
            self.origPoint = point
            self.coordinate = .init(x: point.x, y: point.y, z: 0)
            self.chaosVelocity = .init(
                x: CGFloat.random(in: -0.1...0.1),
                y: CGFloat.random(in: -0.1...0.1),
                z: CGFloat.random(in: -0.1...0.1)
            )
            self.yRotation = 0
            self.yRotationSpeed = CGFloat.random(in: -0.004...0.004)
        }
        
        mutating func reset() {
            self.coordinate = .init(x: self.origPoint.x, y: self.origPoint.y, z: 0)
            self.chaosVelocity = .init(
                x: CGFloat.random(in: -0.1...0.1),
                y: CGFloat.random(in: -0.1...0.1),
                z: CGFloat.random(in: -0.1...0.1)
            )
            self.yRotation = 0
            self.yRotationSpeed = CGFloat.random(in: -0.004...0.004)
        }
    }
    
    private var particles: [Particle] = []
    private var backButton: SKSpriteNode!
    private var isDisintegrating = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        let titleLabel = SKLabelNode(text: "Rotating dusting desintegration")
        titleLabel.fontName = "Arial-BoldMT"
        titleLabel.fontSize = 12
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 20)
        addChild(titleLabel)
        
        createBackButton()
        
        Task {
            await createParticlesFromImage(named: "lord", scale: 1.0)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isDisintegrating else { return }
        updateParticlePositions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode.name == "backButton" || touchedNode.name == "buttonLabel" {
            Task { await goBackToPreviousScene() }
            return
        }
        
        Task {
            if isDisintegrating {
                await startIntegration()
            } else {
                startDisintegration()
            }
        }
    }
    
    private func createBackButton() {
        backButton = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 20))
        backButton.position = CGPoint(x: 30, y: size.height - 20)
        backButton.name = "backButton"
        backButton.zPosition = 1000
        
        let buttonLabel = SKLabelNode(text: "Back")
        buttonLabel.fontName = "Arial-BoldMT"
        buttonLabel.fontSize = 12
        buttonLabel.fontColor = .white
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.name = "buttonLabel"
        
        backButton.addChild(buttonLabel)
        addChild(backButton)
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        backButton.run(SKAction.repeatForever(pulse))
    }
    
    private func goBackToPreviousScene() async {
        backButton.removeAllActions()
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        await backButton.runAsync(fadeOut)
        
        await withTaskGroup(of: Void.self) { group in
            for particle in particles {
                group.addTask {
                    let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                    await particle.node.runAsync(fadeOut)
                }
            }
        }
        
        let previousScene = MarvelDustingScene(size: self.size)
        previousScene.scaleMode = self.scaleMode
        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.view?.presentScene(previousScene, transition: transition)
            continuation.resume(returning: ())
        }
    }
    
    private func createParticlesFromImage(named imageName: String, scale: CGFloat = 1.0) async {
        guard let imageInfo = await ImageDecoder.decodeImageToPixels(named: imageName) else {
            print("Failed to decode Image")
            return
        }
        
        let visiblePixels = imageInfo.pixels.filter { pixel in
            var alpha: CGFloat = 0
            pixel.color.getWhite(nil, alpha: &alpha)
            return alpha > 0.7
        }
        
        print("Creating \(visiblePixels.count) particles from Image")
        
        particles = visiblePixels.map { pixel in
            let particle = SKSpriteNode(color: pixel.color, size: CGSize(width: 1, height: 1))
            let x = CGFloat(pixel.x - imageInfo.width / 2) * scale
            let y = CGFloat(pixel.y - imageInfo.height / 2) * scale
            particle.position = CGPoint(x: x + self.size.width / 2, y: y + self.size.height / 2)
            addChild(particle)
            
            return Particle(node: particle, point: CGPoint(x: x, y: y))
        }
        
        startDisintegration()
    }
    
    private func startDisintegration() {
        isDisintegrating = true
    }
    
    private func updateParticlePositions() {
        let a = size.width * 0.3   // semi-major axis (X)
        let b = size.height * 0.3  // semi-minor axis (Y)
        let c = min(a, b) * 0.3    // depth extent (Z)
        
        for index in particles.indices {
            var particle = particles[index]
            var coord = particle.coordinate
            var chaos = particle.chaosVelocity
            
            coord.x += chaos.x
            coord.y += chaos.y
            coord.z += chaos.z
            
            if !isInsideEllipsoid(coord, a: a, b: b, c: c) {
                chaos.x *= -0.8
                chaos.y *= -0.8
                chaos.z *= -0.8
            }
            
            var yRotation = particle.yRotation + particle.yRotationSpeed
            if yRotation > .pi * 2 || yRotation < -.pi * 2 { yRotation = 0 }
            
            let rotatedX = coord.x * cos(yRotation) + coord.z * sin(yRotation)
            let rotatedZ = -coord.x * sin(yRotation) + coord.z * cos(yRotation)
            
            let perspective = 1.0 / (1.0 + rotatedZ * 0.008)
            let x = rotatedX * perspective + size.width / 2
            let y = coord.y * perspective + size.height / 2
            
            particle.coordinate = coord
            particle.chaosVelocity = chaos
            particle.yRotation = yRotation
            particle.node.position = CGPoint(x: x, y: y)
            
            particles[index] = particle
        }
    }
    
    private func isInsideEllipsoid(_ coord: Particle.Coordinate3D, a: CGFloat, b: CGFloat, c: CGFloat) -> Bool {
        let value = (coord.x * coord.x) / (a * a)
        + (coord.y * coord.y) / (b * b)
        + (coord.z * coord.z) / (c * c)
        return value <= 1.0
    }
    
    private func startIntegration() async {
        isDisintegrating = false
        
        await withTaskGroup(of: Void.self) { group in
            for index in particles.indices {
                group.addTask {
                    let particle = await self.particles[index]
                    let localX = await particle.origPoint.x + self.size.width / 2
                    let localY = await particle.origPoint.y + self.size.height / 2
                    await MainActor.run {
                        self.particles[index].reset()
                    }
                    
                    let moveAction = SKAction.move(to: CGPoint(x: localX, y: localY), duration: 1.5)
                    await particle.node.runAsync(moveAction)
                }
            }
        }
    }
}
