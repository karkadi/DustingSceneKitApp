# DustingSceneKitApp

A stunning SpriteKit implementation of the iconic Marvel disintegration effect from Avengers: Infinity War, featuring particle-based dusting animations with layer-by-layer disintegration and reassembly.

![Dusting Effect](https://img.shields.io/badge/Effect-Marvel%20Dusting-red) ![Platform](https://img.shields.io/badge/Platform-iOS-blue) ![Swift](https://img.shields.io/badge/Swift-6.0-orange) ![SpriteKit](https://img.shields.io/badge/Engine-SpriteKit-purple)

## 📱 Screenshots

<div align="center">
  <img src="./ScreenShoots/demo.gif" width="50%" />
</div>

## 🎬 Features

### ✨ Marvel Dusting Scene
- **Layer-by-Layer Disintegration**: Particles disintegrate from top to bottom in organized layers
- **Realistic Particle Physics**: 3D coordinate system with perspective projection
- **Spiral Movement**: Particles spiral toward the upper right corner with organic chaos
- **Smooth Transitions**: Fade-in and fade-out effects for seamless animations
- **Touch Controls**: Tap to toggle between disintegration and reassembly

### 🔄 Rotating Dusting Scene  
- **Animated Rotation**: Particles rotate while maintaining disintegration effects
- **Dynamic Transformations**: Continuous rotation with particle system
- **Smooth Scene Transitions**: Elegant cross-fade between scenes
- **Interactive Experience**: Responsive touch controls

## 🚀 Quick Start

### Prerequisites
- iOS 26.0+
- Xcode 26.0+
- Swift 6.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/DustingSceneKitApp.git
   cd DustingSceneKitApp
   ```

2. **Open in Xcode**
   ```bash
   open DustingSceneKitApp.xcodeproj
   ```

3. **Configure the project**
   - Select your development team
   - Set bundle identifier
   - Connect your iOS device or use simulator

4. **Build and Run**
   - Press `Cmd + R` to build and run on your device/simulator

## 🎮 Usage

### Basic Interaction
- **Single Tap**: Start disintegration effect
- **Second Tap**: Reverse effect and reassemble particles
- **Next Button**: Transition to rotating dusting scene
- **Back Button**: Return to main marvel dusting scene

### Customization
The app is highly customizable through several parameters:

```swift
// Particle System Configuration
private let totalLayers: Int = 16        // Number of disintegration layers
private let layerDelay = 0.1             // Delay between layer activation
let spiralStrength: CGFloat = 2.0        // Spiral effect intensity
let chaosStrength: CGFloat = 1.5         // Random movement intensity
```

## 🏗️ Architecture

### Core Components

#### MarvelDustingScene
- `Particle` struct with 3D coordinates and physics
- Layer-based disintegration system
- Async/await for smooth animations
- Touch gesture handling

#### RotatingDustingScene  
- Extended particle rotation system
- Continuous animation loops
- Scene transition management

#### ImageDecoder
- Custom image processing for particle generation
- Alpha-based pixel filtering
- Coordinate transformation

### Key Technologies
- **SpriteKit**: 2D graphics and animation engine
- **Swift Concurrency**: Async/await for modern animation timing
- **Core Graphics**: Image processing and pixel manipulation
- **UIKit Integration**: Seamless iOS app compatibility

## 🎨 Customization Guide

### Adding New Images
1. Add your image to `Assets.xcassets`
2. Update the image name in `createParticlesFromImage(named:)`
3. Adjust scale and positioning parameters as needed

## 🔧 Technical Details

### Performance Optimizations
- **Efficient Particle System**: Optimized for hundreds of particles
- **Async Animation Timing**: Non-blocking animation sequences
- **Memory Management**: Automatic particle cleanup
- **Frame Rate Stability**: Consistent 60FPS performance

### Supported Devices
- iPhone 8 and newer
- iPad (6th generation) and newer
- iOS 15.0 or later

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Marvel Studios for the iconic visual effect inspiration
- Apple SpriteKit team for the powerful graphics framework


<div align="center">

**Made with ❤️ and Swift**

*Experience the magic of Marvel's dusting effect in your own apps!*

</div>
