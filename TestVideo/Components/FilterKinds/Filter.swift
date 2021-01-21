import UIKit
import AVFoundation

let kMetalValue = "value"
let kMetalOverlayImage = "overlayImage"

struct Filter {
  let uuid: UUID = UUID()
  private(set) var kind: Kind
  private(set) var timeRange: TimeRange = TimeRange()

  var isAvailable: Bool {
    return kind.isAvailable && timeRange.isAvailable
  }

  mutating func updateKind(arguments: [String: Any]) {
    kind = kind.update(with: arguments)
  }

  mutating func updateTimeRange(_ timeRange: TimeRange) {
    self.timeRange = timeRange
  }

  func applyingFilter(for image: CIImage) -> CIImage {
    return kind.applyingFilter(for: image)
  }

  func isAvailable(in time: CMTime) -> Bool {
    return isAvailable && time >= timeRange.from && time <= timeRange.to
  }
}

extension Filter {
  struct TimeRange {
    let from: CMTime
    let to: CMTime
  }

  enum Kind {
    case blur(value: Float? = nil)
    case brightness(value: Float? = nil)
    case saturation(value: Float? = nil)
    case threshold(value: Float? = nil)
    case overlay(overlayImage: CIImage? = nil)
  }
}

extension Filter.TimeRange {
  var isAvailable: Bool {
    return from != .zero && to != .zero || from < to
  }

  init() {
    from = .zero
    to = .zero
  }
}

extension Filter.Kind {
  var tag: Int {
    switch self {
    case .blur: return 0
    case .brightness: return 1
    case .saturation: return 2
    case .threshold: return 3
    case .overlay: return 4
    }
  }

  var title: String {
    switch self {
    case .blur: return "BLUR"
    case .brightness: return "BRIGHTNESS"
    case .saturation: return "SATURATION"
    case .threshold: return "THRESHOLD"
    case .overlay: return "OVERLAY"
    }
  }

  var isAvailable: Bool {
    switch self {
    case .blur(let value):
      return value != .zero
    case .brightness(let value):
      return value != .zero
    case .saturation(let value):
      return value != .zero
    case .threshold(let value):
      return value != .zero
    case .overlay(let overlayImage):
      return overlayImage != nil
    }
  }

  var value: Float? {
    switch self {
    case .blur(let value): return value
    case .brightness(let value): return value
    case .saturation(let value): return value
    case .threshold(let value): return value
    case .overlay: return nil
    }
  }

  var valueRange: (min: Float, max: Float)? {
    switch self {
    case .blur: return (0, 25)
    case .brightness: return (0, 0.5)
    case .saturation: return (0, 0.5)
    case .threshold: return (0, 0.5)
    case .overlay: return nil
    }
  }

  func update(with arguments: [String: Any]) -> Filter.Kind {
    switch self {
    case .blur(let value):
      let currentValue = arguments[kMetalValue] as? Float ?? value
      return .blur(value: currentValue)
    case .brightness(let value):
      let currentValue = arguments[kMetalValue] as? Float ?? value
      return .brightness(value: currentValue)
    case .saturation(let value):
      let currentValue = arguments[kMetalValue] as? Float ?? value
      return .saturation(value: currentValue)
    case .threshold(let value):
      let currentValue = arguments[kMetalValue] as? Float ?? value
      return .threshold(value: currentValue)
    case .overlay(let overlayImage):
      let currentOverlayImage = arguments[kMetalOverlayImage] as? CIImage ?? overlayImage
      return .overlay(overlayImage: currentOverlayImage)
    }
  }

  func applyingFilter(for image: CIImage) -> CIImage {
    switch self {
    case .blur(let value):
      guard let value = value else { return image }
      return image.applyingGaussianBlur(sigma: Double(value)).cropped(to: image.extent)
    case .brightness(let value):
      guard let value = value else { return image }
      return image.applyingMetalBrightnessFilter(brightness: value)
    case .saturation(let value):
      guard let value = value else { return image }
      return image.applyingMetalSaturationFilter(saturation: value)
    case .threshold(let value):
      guard let value = value else { return image }
      return image.applyingMetalThresholdFilter(threshold: value)
    case .overlay(let overlayImage):
      guard let overlayImage = overlayImage else { return image }
      return image.applyingMetalSourceOverlayFilter(overlay: overlayImage)
    }
  }
}
