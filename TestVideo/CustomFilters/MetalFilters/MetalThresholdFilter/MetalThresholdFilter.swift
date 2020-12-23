import UIKit

extension CIImage {
  func applyMetalThresholdFilter(threshold: Float) -> CIImage {
    return MetalThresholdFilter(threshold: threshold).filterImage(self) ?? self
  }
}

private class MetalThresholdFilter: MetalBaseFilter {
  var threshold: Float

  init(threshold: Float) {
    self.threshold = threshold
    super.init(kernelFunctionName: "metalThreshold")
  }

  override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
    encoder.setBytes(&threshold, length: MemoryLayout<Float>.size, index: 0)
  }
}
