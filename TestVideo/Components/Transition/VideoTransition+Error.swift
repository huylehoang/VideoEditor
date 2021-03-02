import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Error: Swift.Error {
    /// The number of assets must equal or more than 2.
    case numberOfAssetsMustLargeThanTwo
    /// PixelBufferRequestError
    case newRenderedPixelBufferForRequestFailure
  }
}
