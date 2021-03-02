import UIKit
import MetalKit

extension MTLComputeCommandEncoder {
  func setValue(_ value: UnsafeRawPointer, at index: Int) {
    setBytes(value, length: MemoryLayout.size(ofValue: value), index: index)
  }

  func setColorValue(_ value: UIColor, at index: Int) {
    let rbga = value.rgba
    var color = vector_float4(Float(rbga.red), Float(rbga.green), Float(rbga.blue), Float(rbga.alpha))
    setBytes(&color, length: MemoryLayout.size(ofValue: color), index: index)
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
