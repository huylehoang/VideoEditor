import UIKit

extension CIImage {
  func applyMetalSourceOverlayFilter(overlay: CIImage) -> CIImage {
    return MetalSourceOverlayFilter(inputOverlay: overlay).filterImage(self) ?? self
  }
}

private class MetalSourceOverlayFilter: MetalBaseFilter {
  let inputOverlay: CIImage

  init(inputOverlay: CIImage) {
    self.inputOverlay = inputOverlay
    super.init(kernelFunctionName: "metalSourceOverlay")
  }

  override func updateParameters(forComputeCommandEncoder encoder: MTLComputeCommandEncoder) {
    encoder.setTexture(inputOverlay.metalTexture, index: 2)
  }
}
