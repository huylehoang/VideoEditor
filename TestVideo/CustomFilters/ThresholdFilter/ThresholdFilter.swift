import UIKit

extension CIImage {
  func applyThresholdFilter(_ threshold: Float) -> CIImage {
    return ThresholdFilter(inputImage: self, inputThreshold: threshold).outputImage ?? self
  }
}

private class ThresholdFilter: CIFilter, BaseKernelFilter {
  let inputImage: CIImage
  let inputThreshold: Float

  init(inputImage: CIImage, inputThreshold: Float) {
    self.inputImage = inputImage
    self.inputThreshold = inputThreshold
    super.init()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var outputImage: CIImage? {
    return applyFilterWithArguments(inputImage, inputThreshold)
  }
}
