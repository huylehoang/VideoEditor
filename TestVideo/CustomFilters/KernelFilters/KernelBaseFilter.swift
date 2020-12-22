import UIKit

protocol KernelBaseFilter: CIFilter {
  var inputImage: CIImage { get }

  func applyKernelFilterWithArguments(_ arguments: Any...) -> CIImage?
}

extension KernelBaseFilter {
  func applyKernelFilterWithArguments(_ arguments: Any...) -> CIImage? {
    return Self.kernel.apply(extent: inputImage.extent, arguments: arguments)
  }
}

// MARK: Private Static
private extension KernelBaseFilter {
  private static var kernel: CIColorKernel {
    return { () -> CIColorKernel in
      guard
        let url = Bundle(for: Self.self).url(forResource: typeName, withExtension: ciMetalExtension),
        let data = try? Data(contentsOf: url)
      else {
        fatalError("Unable to load metallib")
      }

      guard let kernel = try? CIColorKernel(functionName: functionName, fromMetalLibraryData: data) else {
        fatalError("Unable to create CIColorKernel for \(functionName)")
      }

      return kernel
    }()
  }

  private static var ciMetalExtension: String {
    return "ci.metallib"
  }

  private static var typeName: String {
    return String(describing: self)
  }

  private static var functionName: String {
    return typeName.lowercasedFirstLetter()
  }
}

private extension String {
  func lowercasedFirstLetter() -> String {
    return prefix(1).lowercased() + dropFirst()
  }
}
