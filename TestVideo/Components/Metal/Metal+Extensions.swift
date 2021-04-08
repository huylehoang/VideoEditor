import UIKit
import MetalKit

/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage
extension CIImage {
  var metalTexture: MTLTexture? {
    return cgImage?.metalTexture
  }

  private var cgImage: CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(self, from: self.extent) {
      return cgImage
    }
    return nil
  }
}

extension MTLTexture {
  var ciImage: CIImage? {
    if let cgImage = cgImage {
      return CIImage(cgImage: cgImage)
    }
    return nil
  }

  var cgImage: CGImage? {
    // Data -> CGContext -> CGImage produces empty image on Xcode 11.5 release mode
    // Create CGImage with another way
    // Data -> CFData -> CGDataProvider -> CGImage
    let bytesPerPixel: Int = 4
    let bytesPerRow: Int = width * bytesPerPixel
    var data = [UInt8](repeating: 0, count: Int(width * height * bytesPerPixel))
    getBytes(&data, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
    let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue
    if let cfdata = CFDataCreate(kCFAllocatorDefault, &data, bytesPerRow * height),
       let dataProvider = CGDataProvider(data: cfdata),
       let cgimage = CGImage(width: width, height: height,
                             bitsPerComponent: 8,
                             bitsPerPixel: 32,
                             bytesPerRow: bytesPerRow,
                             space: MetalDevice.sharedColorSpace,
                             bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                             provider: dataProvider,
                             decode: nil,
                             shouldInterpolate: true,
                             intent: .defaultIntent)
    {
      return cgimage
    }
    return nil
  }
}

private extension CGImage {
  var metalTexture: MTLTexture? {
    let loader = MTKTextureLoader(device: MetalDevice.sharedDevice)
    if let texture = try? loader.newTexture(cgImage: self, options: [MTKTextureLoader.Option.SRGB : false]) {
      return texture
    }
    // Texture loader can not load image data to create texture
    // Draw image and create texture
    let descriptor = MTLTextureDescriptor()
    descriptor.pixelFormat = .rgba8Unorm
    descriptor.width = width
    descriptor.height = height
    descriptor.usage = .shaderRead
    let bytesPerRow: Int = width * 4
    let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue
    if let currentTexture = MetalDevice.sharedDevice.makeTexture(descriptor: descriptor),
       let context = CGContext(data: nil,
                               width: width,
                               height: height,
                               bitsPerComponent: 8,
                               bytesPerRow: bytesPerRow,
                               space: MetalDevice.sharedColorSpace,
                               bitmapInfo: bitmapInfo) {

      context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

      if let data = context.data {
        currentTexture.replace(region: MTLRegionMake3D(0, 0, 0, width, height, 1),
                               mipmapLevel: 0,
                               withBytes: data,
                               bytesPerRow: bytesPerRow)

        return currentTexture
      }
    }
    return nil
  }
}
