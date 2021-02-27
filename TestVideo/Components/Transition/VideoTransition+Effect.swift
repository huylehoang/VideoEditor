import Foundation

extension VideoTransition {
  enum Effect: CustomStringConvertible {
    case normal

    var transition: BaseTransition {
      switch self {
      case .normal: return NormalTransition()
      }
    }

    var description: String {
      switch self {
      case .normal: return ""
      }
    }
  }
}
