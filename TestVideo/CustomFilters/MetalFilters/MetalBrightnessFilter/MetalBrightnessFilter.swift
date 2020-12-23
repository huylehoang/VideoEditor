import UIKit

extension CIImage {
  func applyMetalBrightnessFilter(brightness: Float) -> CIImage {
    return MetalBrightnessFilter(brightness: brightness).filterImage(self) ?? self
  }
}

private class MetalBrightnessFilter: MetalBaseFilter {
  private var brightness: Float

  init(brightness: Float) {
    self.brightness = brightness
    super.init(kernelFunctionName: "metalBrightness")
  }

  override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
    encoder.setBytes(&brightness, length: MemoryLayout<Float>.size, index: 0)
  }
}
