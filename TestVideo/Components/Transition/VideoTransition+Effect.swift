import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Effect: Int, CaseIterable, CustomStringConvertible {
    case normal
    case fade
    case wind
    case multiplyBlend
    case pinwheel
    case gridFlip
    case bounce

    var transition: BaseTransition {
      switch self {
      case .normal: return NormalTransition()
      case .fade: return FadeTransition()
      case .wind: return WindTransition()
      case .multiplyBlend: return MultiplyBlendTransition()
      case .pinwheel: return PinwheelTransition()
      case .gridFlip: return GridFlipTransition()
      case .bounce: return BounceTransition()
      }
    }

    var description: String {
      return transition.functionName
    }
  }
}
