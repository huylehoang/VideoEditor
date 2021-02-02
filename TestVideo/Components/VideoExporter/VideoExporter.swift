import AVFoundation
import Photos

class VideoExporter {
  private var exportingSession: AVAssetExportSession?

  func exportAndSaveToAlbum(
    asset: AVAsset,
    videoComposition: AVVideoComposition? = nil,
    completion: @escaping (String?) -> Void
  ) {
    exportingSession?.cancelExport()
    guard
      let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    else {
      completion("Can not generate export session")
      return
    }
    removeVideoAtTempURL()
    let outputUrl = tempOutputURL
    exportSession.outputURL = outputUrl
    exportSession.outputFileType = .mp4
    exportSession.shouldOptimizeForNetworkUse = true
    exportSession.videoComposition = videoComposition
    exportSession.exportAsynchronously { [weak self] in
      guard exportSession.status == .completed else {
        self?.removeVideoAtTempURL()
        completion(exportSession.error?.localizedDescription)
        return
      }
      PHPhotoLibrary.shared().performChanges {
        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputUrl)
      } completionHandler: { saved, error in
        self?.removeVideoAtTempURL()
        guard saved else {
          completion(error?.localizedDescription)
          return
        }
        completion(nil)
      }
    }
  }
}

private extension VideoExporter {
  var tempOutputURL: URL {
    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let outputURL = documentDirectory.appendingPathComponent("video.mp4")
    return outputURL
  }

  func removeVideoAtTempURL() {
    try? FileManager.default.removeItem(at: tempOutputURL)
  }
}
