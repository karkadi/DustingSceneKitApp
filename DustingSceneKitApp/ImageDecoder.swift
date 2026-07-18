//
//  ImageDecoder.swift
//  DustingSceneKitApp iOS
//
//  Created by Arkadiy KAZAZYAN on 24/10/2025.
//

import UIKit
import CoreGraphics

// ImageDecoder with async support
@MainActor
class ImageDecoder {
    struct ImageInfo {
        let width: Int
        let height: Int
        var pixels: [PixelData]
        
        struct PixelData {
            let x: Int
            let y: Int
            let color: UIColor
        }
    }
    
    static func decodeImageToPixels(named imageName: String) async -> ImageInfo? {
        guard let image = UIImage(named: imageName) else {
            print("Image not found")
            return nil
        }
        
        return decodeImageToPixels(image)
    }
    
    static func decodeImageToPixels(from url: URL) async -> ImageInfo? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to load image from URL")
                return nil
            }
            return await withCheckedContinuation { continuation in
                Task { @MainActor in
                    let result = decodeImageToPixels(image)
                    continuation.resume(returning: result)
                }
            }
        } catch {
            print("Failed to load image from URL: \(error)")
            return nil
        }
    }
    
    @MainActor
    private static func decodeImageToPixels(_ image: UIImage) -> ImageInfo? {
        guard let cgImage = image.cgImage else {
            print("Failed to get CGImage")
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var imageInfo = ImageInfo(width: width, height: height, pixels: [])
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ) else {
            print("Failed to create context or color space")
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            print("Failed to get pixel data")
            return nil
        }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: bytesPerRow * height)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)
                
                let r = CGFloat(buffer[pixelIndex]) / 255.0
                let g = CGFloat(buffer[pixelIndex + 1]) / 255.0
                let b = CGFloat(buffer[pixelIndex + 2]) / 255.0
                let a = CGFloat(buffer[pixelIndex + 3]) / 255.0
                
                let color = UIColor(red: r, green: g, blue: b, alpha: a)
                imageInfo.pixels.append(.init(x: x, y: height - y - 1, color: color))
            }
        }
        
        return imageInfo
    }
}
