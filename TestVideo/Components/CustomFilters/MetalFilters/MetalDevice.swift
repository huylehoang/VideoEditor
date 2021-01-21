import Metal
import CoreGraphics

/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage
class MetalDevice {
  static let shared = MetalDevice()
  static var sharedDevice: MTLDevice { return shared.device }
  static var sharedCommandQueue: MTLCommandQueue { return shared.commandQueue }
  static var sharedColorSpace: CGColorSpace { return shared.colorSpace }

  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let colorSpace: CGColorSpace

  private init() {
    device = MTLCreateSystemDefaultDevice()!
    commandQueue = device.makeCommandQueue()!
    colorSpace = CGColorSpaceCreateDeviceRGB()
  }
}
