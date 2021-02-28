import Foundation

extension VideoTransition {
  enum Effect: CustomStringConvertible {
    case normal
    case wipeLeft

    var transition: BaseTransition {
      switch self {
      case .normal: return NormalTransition()
      case .wipeLeft: return WipeLeftTransition()
      }
    }

    var description: String {
      return transition.functionName
    }
  }
}
