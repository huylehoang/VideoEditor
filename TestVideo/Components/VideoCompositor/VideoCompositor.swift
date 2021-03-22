import UIKit
import AVFoundation

final class VideoCompositor {
  private(set) var blur = Filter(kind: .blur())
  private(set) var brightness = Filter(kind: .brightness())
  private(set) var saturation = Filter(kind: .saturation())
  private(set) var threshold = Filter(kind: .threshold())

  func getFilter(by tag: Int) -> Filter? {
    switch tag {
    case Filter.Kind.blur().tag: return blur
    case Filter.Kind.brightness().tag: return brightness
    case Filter.Kind.saturation().tag: return saturation
    case Filter.Kind.threshold().tag: return threshold
    default: return nil
    }
  }

  func update(filter: Filter) {
    switch filter.kind {
    case .blur:
      blur = filter
    case .brightness:
      brightness = filter
    case .saturation:
      saturation = filter
    case .threshold:
      threshold = filter
    default:
      break
    }
  }

  func makePlayerItemWithComposition(for asset: AVAsset) -> AVPlayerItem {
    let playerItem = AVPlayerItem(asset: asset)
    playerItem.videoComposition = AVVideoComposition(
      asset: asset,
      applyingCIFiltersWithHandler: { [weak self] request in
        guard let self = self else {
          request.finish(with: request.sourceImage, context: nil)
          return
        }
        self.requestFilters(request: request)
      })
    return playerItem
  }

  func makeExportVideoComposition(asset: AVAsset, playerView: PlayerView) -> AVVideoComposition {
    let addStickerHandler = handleStickers(stickers: playerView.stickersCIImage)
    return AVVideoComposition(
      asset: asset,
      applyingCIFiltersWithHandler: { [weak self] request in
        guard let self = self else {
          request.finish(with: request.sourceImage, context: nil)
          return
        }
        self.requestFilters(request: request, addStickersHandler: addStickerHandler)
      })
  }
}

private extension VideoCompositor {
  typealias StickerHandler = (_ currentOutput: CIImage) -> CIImage

  func requestFilters(
    request: AVAsynchronousCIImageFilteringRequest,
    addStickersHandler: (StickerHandler)? = nil
  ) {
    var output = request.sourceImage
    let time = request.compositionTime

    if blur.isAvailable(in: time) {
      output = blur.applyingFilter(for: output)
    }

    if brightness.isAvailable(in: time) {
      output = brightness.applyingFilter(for: output)
    }

    if saturation.isAvailable(in: time) {
      output = saturation.applyingFilter(for: output)
    }

    if threshold.isAvailable(in: time) {
      output = threshold.applyingFilter(for: output)
    }

    if let stickersOutput = addStickersHandler?(output) {
      output = stickersOutput
    }

    request.finish(with: output.clamped(to: request.sourceImage.extent), context: nil)
  }

  func handleStickers(stickers: CIImage?) -> StickerHandler? {
    guard let stickers = stickers else { return nil }
    return { currentOutput in
      return Filter.Kind.overlay(overlayImage: stickers).applyingFilter(for: currentOutput)
    }
  }
}
