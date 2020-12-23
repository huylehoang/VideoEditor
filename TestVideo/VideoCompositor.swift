import UIKit
import AVFoundation

class VideoCompositor {
  private let duration: Double

  private var blur = 0.0
  private var brightness = 0.0
  private var saturation = 0.0

  init(duration: Double) {
    self.duration = duration
  }

  func updateBlur(_ blur: Double) {
    self.blur = blur
  }

  func updateBrightness(_ brightness: Double) {
    self.brightness = brightness
  }

  func updateSaturation(_ saturation: Double) {
    self.saturation = saturation
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
    let time = request.compositionTime.seconds

    // Blur (currently hardcode the filter duration)
    if blur != 0 && time >= 0 && time <= duration / 2 {
      output = output.applyingGaussianBlur(sigma: blur).cropped(to: request.sourceImage.extent)
    }

    // Brightness (currently hardcode the filter duration)
    if brightness != 0 && time > duration / 2 && time <= duration * 5/6 {
      output = output.applyMetalBrightnessFilter(brightness: 0.5)
    }

    // Saturation (currently hardcode the filter duration)
    if saturation != 0 && time >= duration * 2/3 && time <= duration * 5/6 {
      output = output.applyMetalSaturationFilter(saturation: 0.5)
    }

    if let stickersOutput = addStickersHandler?(output) {
      output = stickersOutput
    }

    request.finish(with: output.clamped(to: request.sourceImage.extent), context: nil)
  }

  func handleStickers(stickers: CIImage?) -> StickerHandler? {
    guard let stickers = stickers else { return nil }
    return { currentOutput in
      return currentOutput.applyMetalSourceOverlayFilter(overlay: stickers)
    }
  }
}
