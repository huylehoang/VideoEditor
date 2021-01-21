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

  // Convert seconds to hours:minutes:seconds format
  var hoursMinutesSecondsFormatted: String {
    guard numericOrZero != .zero else { return "00:00" }
    let secondsRounded = Int(numericOrZero.seconds.rounded())
    let format = "%02i"
    let hours = secondsRounded / 3600
    let minutes = (secondsRounded % 3600) / 60
    let seconds = (secondsRounded % 3600) % 60
    let hoursString = hours > 0 ? "\(String(format: format, hours)):" : ""
    let minutesString = "\(String(format: format, minutes)):"
    let secondsString = String(format: format, seconds)
    return hoursString + minutesString + secondsString
  }
}

extension Comparable {
  func clamped(to lower: Self, and upper: Self) -> Self {
    precondition(lower <= upper, "\(lower) <= \(upper)")
    return max(lower, min(upper, self))
  }
}
