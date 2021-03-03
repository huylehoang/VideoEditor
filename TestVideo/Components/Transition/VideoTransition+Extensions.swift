import UIKit
import MetalKit

extension MTLComputeCommandEncoder {
  func setValue(_ value: UnsafeRawPointer, at index: Int) {
    setBytes(value, length: MemoryLayout.size(ofValue: value), index: index)
  }

  func setColorValueAsFloat3(_ value: UIColor, at index: Int) {
    let rbga = value.rgba
    var color = vector_float3(Float(rbga.red), Float(rbga.green), Float(rbga.blue))
    setBytes(&color, length: MemoryLayout.size(ofValue: color), index: index)
  }

  func setColorValueAsFloat4(_ value: UIColor, at index: Int) {
    let rbga = value.rgba
    var color = vector_float4(Float(rbga.red), Float(rbga.green), Float(rbga.blue), Float(rbga.alpha))
    setBytes(&color, length: MemoryLayout.size(ofValue: color), index: index)
  }

  func setPointValueAsFloat2(_ value: CGPoint, at index: Int) {
    var point = vector_float2(Float(value.x), Float(value.y))
    setBytes(&point, length: MemoryLayout.size(ofValue: point), index: index)
  }

  func setImageAsTexture(_ image: UIImage?, at index: Int) {
    guard
      let images = image,
      let ciImage = CIImage(image: images),
      let texture = ciImage.metalTexture
    else { return }
    setTexture(texture, index: index)
  }
}

extension UIColor {
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
  }
}
