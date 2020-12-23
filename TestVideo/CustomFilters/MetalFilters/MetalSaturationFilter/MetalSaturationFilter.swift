import UIKit

extension CIImage {
  func applyMetalSaturationFilter(saturation: Float) -> CIImage {
    return MetalSaturationFilter(saturation: saturation).filterImage(self) ?? self
  }
}

private class MetalSaturationFilter: MetalBaseFilter {
  var saturation: Float

  init(saturation: Float) {
    self.saturation = saturation
    super.init(kernelFunctionName: "metalSaturation")
  }

  override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
    encoder.setBytes(&saturation, length: MemoryLayout<Float>.size, index: 0)
  }
}
