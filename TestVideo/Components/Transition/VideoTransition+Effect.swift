import Foundation

extension VideoTransition {
  enum Effect: CustomStringConvertible {
    case normal
    case fade

    var transition: BaseTransition {
      switch self {
      case .normal: return NormalTransition()
      case .fade: return FadeTransition()
      }
    }

    var description: String {
      return transition.functionName
    }
  }
}
