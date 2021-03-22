import Metal
import UIKit
import CoreGraphics

/// Reference BBMetalImage github: https://github.com/Silence-GitHub/BBMetalImage
final class MetalDevice {
  static let shared = MetalDevice()
  static var sharedDevice: MTLDevice { return shared.device }
  static var sharedCommandQueue: MTLCommandQueue { return shared.commandQueue }
  static var sharedColorSpace: CGColorSpace { return shared.colorSpace }
  static var sharedContext: CIContext { return shared.context }

  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let colorSpace: CGColorSpace
  private let context: CIContext

  private init() {
    device = MTLCreateSystemDefaultDevice()!
    commandQueue = device.makeCommandQueue()!
    colorSpace = CGColorSpaceCreateDeviceRGB()
    context = CIContext(mtlDevice: device)
  }
}
