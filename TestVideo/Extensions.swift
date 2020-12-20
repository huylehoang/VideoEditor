import UIKit
import AVFoundation

extension UIView {
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image { rendererContext in
      layer.render(in: rendererContext.cgContext)
    }
  }
}

extension CMTime {
  var numericOrZero: CMTime {
    let numericOrZero = isNumeric ? self : .zero
    return numericOrZero < .zero ? .zero : numericOrZero
  }
}

extension Comparable {
  func clamped(to lower: Self, and upper: Self) -> Self {
    precondition(lower <= upper, "\(lower) <= \(upper)")
    return max(lower, min(upper, self))
  }
}
