import UIKit

extension CIImage {
  func applyHDRZebraFilter(time: Float) -> CIImage {
    return HDRZebraFilter(inputImage: self, inputTime: time).outputImage ?? self
  }
}

private class HDRZebraFilter: CIFilter, BaseKernelFilter {
  let inputImage: CIImage
  let inputTime: Float

  init(inputImage: CIImage, inputTime: Float) {
    self.inputImage = inputImage
    self.inputTime = inputTime
    super.init()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var outputImage: CIImage? {
    return applyFilterWithArguments(inputImage, inputTime)
  }
}
