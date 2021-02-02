import Foundation
import AVFoundation

class VideoTransition {
  typealias Completion = (Result) -> Void

  /// The movie clips.
  private var clips: [AVAsset] = []

  /// The available time ranges for the movie clips.
  private var clipTimeRanges: [CMTimeRange] = []

  func merge(_ assets: [AVAsset], completion: @escaping Completion) throws {
    guard assets.count >= 2 else {
      throw Error.numberOfAssetsMustLargeThanTwo
    }

    clips.removeAll()
    clipTimeRanges.removeAll()

    /*
     Load Asset with keys: ["tracks", "duration", "composable"]
     */
    let semaphore = DispatchSemaphore(value: 0)
    for asset in assets {
      loadAsset(asset) {
        semaphore.signal()
      }
      semaphore.wait()
    }

    let videoTracks = self.clips[0].tracks(withMediaType: .video)
    let videoSize = videoTracks[0].naturalSize

    let composition = AVMutableComposition()
    composition.naturalSize = videoSize

    /*
     With transitions:
     Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
     Set up the video composition to cycle between "pass through A", "transition from A to B", "pass through B".
     */
    let videoComposition = AVMutableVideoComposition()
    //    videoComposition.customVideoCompositorClass = MTVideoCompositor.self
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30) // 30 fps.
    videoComposition.renderSize = videoSize

    buildTransitionComposition(composition, videoComposition: videoComposition)

    let result = Result(composition: composition, videoComposition: videoComposition)
    completion(result)
  }
}

private extension VideoTransition {
  func loadAsset(_ asset: AVAsset, completion: @escaping (() -> Void)) {
    let assetKeys = ["tracks", "duration", "composable"]
    asset.loadValuesAsynchronously(forKeys: assetKeys) {
      for key in assetKeys {
        var error: NSError?
        if asset.statusOfValue(forKey: key, error: &error) == .failed {
          print("load assets failed")
          completion()
          return
        }
      }
      if !asset.isComposable {
        print("asset is not composable")
        completion()
        return
      }
      self.clips.append(asset)
      // This code assumes that both assets are atleast 5 seconds long.
      if let timeRange = asset.tracks(withMediaType: .video).first?.timeRange {
        self.clipTimeRanges.append(timeRange)
      } else {
        let clipTimeRange = CMTimeRange(
          start: CMTimeMakeWithSeconds(0, preferredTimescale: 1),
          duration: CMTimeMakeWithSeconds(5, preferredTimescale: 1))
        self.clipTimeRanges.append(clipTimeRange)
      }
      completion()
    }
  }

  func buildTransitionComposition(
    _ composition: AVMutableComposition,
    videoComposition: AVMutableVideoComposition
  ) {
    let compositionVideoTracks = composition.addMutableTrack(
      withMediaType: .video,
      preferredTrackID: kCMPersistentTrackID_Invalid)!

    let compositionAudioTracks = composition.addMutableTrack(
      withMediaType: .audio,
      preferredTrackID: kCMPersistentTrackID_Invalid)!

    buildComposition(
      composition,
      compositionVideoTrack: compositionVideoTracks,
      compositionAudioTrack: compositionAudioTracks)
  }

  func buildComposition(
    _ composition: AVMutableComposition,
    compositionVideoTrack: AVMutableCompositionTrack,
    compositionAudioTrack: AVMutableCompositionTrack
  ) {
    let clipsCount = clips.count
    var nextClipStartTime = CMTime.zero
    var hasAudio = false

    for index in 0 ..< clipsCount {
      let asset = clips[index]
      var timeRangeInAsset: CMTimeRange
      if index < (clipTimeRanges.count - 1) {
        timeRangeInAsset = clipTimeRanges[index]
      } else {
        timeRangeInAsset = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
      }

      do {
        if let clipVideoTrack = asset.tracks(withMediaType: .video).first {
          try compositionVideoTrack.insertTimeRange(
            timeRangeInAsset,
            of: clipVideoTrack,
            at: nextClipStartTime)
        } else {
          print("video track nil")
        }

        if let clipAudioTrack = asset.tracks(withMediaType: .audio).first {
          try compositionAudioTrack.insertTimeRange(
            timeRangeInAsset,
            of: clipAudioTrack,
            at: nextClipStartTime)
          hasAudio = true
        } else {
          print("audio track nil")
        }
      } catch {
        print("An error occurred inserting a time range of the source track into the video composition.")
      }

      nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration)
    }

    if !hasAudio {
      /*
      Remove audio track if not exists, otherwise it will cause export error:
      Error Domain=AVFoundationErrorDomain Code=-11838
      "Operation Stopped" UserInfo={NSLocalizedFailureReason=The operation is not supported for this media., NSLocalizedDescription=Operation Stopped, NSUnderlyingError=0x2808acde0 {Error Domain=NSOSStatusErrorDomain Code=-16976 "(null)"}}
      */
      composition.removeTrack(compositionAudioTrack)
    }
  }
}
