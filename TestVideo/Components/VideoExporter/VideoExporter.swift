import AVFoundation
import Photos

final class VideoExporter {
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
      self?.saveVideo(fileUrl: outputUrl, completion: completion)
    }
  }
}

private extension VideoExporter {
  var tempOutputURL: URL {
    return URL(fileURLWithPath: NSTemporaryDirectory().appending("exported.mp4"))
  }

  func removeVideoAtTempURL() {
    guard FileManager.default.fileExists(atPath: tempOutputURL.path) else {
      print("Do not exist file at path: \(tempOutputURL.path)")
      return
    }
    do {
      try FileManager.default.removeItem(at: tempOutputURL)
      print("Removed file at path: \(tempOutputURL.path)")
    } catch {
      print("Error while removing video at temp output url (\(tempOutputURL.path): \(error.localizedDescription)")
    }
  }

  func saveVideo(fileUrl: URL, completion: @escaping (String?) -> Void) {
    PHPhotoLibrary.shared().performChanges {
      let options = PHAssetResourceCreationOptions()
      options.shouldMoveFile = true
      let creationRequest = PHAssetCreationRequest.forAsset()
      creationRequest.addResource(with: .video, fileURL: fileUrl, options: options)
    } completionHandler: { [weak self] saved, error in
      self?.removeVideoAtTempURL()
      guard saved else {
        completion(error?.localizedDescription)
        return
      }
      completion(nil)
    }
  }
}
