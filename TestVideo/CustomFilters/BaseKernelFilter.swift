import UIKit

protocol BaseKernelFilter: CIFilter {
  var inputImage: CIImage { get }

  func applyFilterWithArguments(_ arguments: Any...) -> CIImage?
}

extension BaseKernelFilter {
  func applyFilterWithArguments(_ arguments: Any...) -> CIImage? {
    return Self.kernel.apply(extent: inputImage.extent, arguments: arguments)
  }
}

// MARK: Private Static
private extension BaseKernelFilter {
  private static var kernel: CIColorKernel {
    return { () -> CIColorKernel in
      guard
        let url = Bundle(for: Self.self).url(forResource: typeName, withExtension: ciMetalExtension),
        let data = try? Data(contentsOf: url)
      else {
        fatalError("Unable to load metallib")
      }

      guard let kernel = try? CIColorKernel(functionName: typeName, fromMetalLibraryData: data) else {
        fatalError("Unable to create CIColorKernel for \(typeName)")
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
}


