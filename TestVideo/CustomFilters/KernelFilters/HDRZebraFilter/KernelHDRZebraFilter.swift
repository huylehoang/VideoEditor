import UIKit

extension CIImage {
  func applyKernelHDRZebraFilter(time: Float) -> CIImage {
    return KernelHDRZebraFilter(inputImage: self, inputTime: time).outputImage ?? self
  }
}

private class KernelHDRZebraFilter: CIFilter, KernelBaseFilter {
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
