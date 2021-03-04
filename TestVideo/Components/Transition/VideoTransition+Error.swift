import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Error: Swift.Error {
    /// The number of assets must equal or more than 2.
    case numberOfAssetsMustLargeThanTwo
    /// The number of effects should equal to assets.count - 1.
    case numberOfEffectsWrong
    /// PixelBufferRequestError
    case newRenderedPixelBufferForRequestFailure
  }
}
