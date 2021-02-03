import UIKit
import AVFoundation

enum UIControlHelper {
  static func trackPosition(
    inView view: UIView,
    for time: CMTime,
    withDuration duration: CMTime
  ) -> CGFloat {
    let trackFrame = view.frame

    guard duration.seconds != .zero else { return trackFrame.minX }

    let progress = time.seconds / duration.seconds
    let range = trackFrame.maxX - trackFrame.minX
    let position = trackFrame.minX + CGFloat(progress) * range

    return position.clamped(to: trackFrame.minX, and: trackFrame.maxX)
  }

  static func trackTime(
    inView view: UIView,
    for position: CGFloat,
    withDuration duration: CMTime
  ) -> CMTime {
    let trackFrame = view.frame
    let range = trackFrame.maxX - trackFrame.minX

    guard range != 0 else { return .zero }

    let progress = (position - trackFrame.minX) / range
    let time = CMTimeMultiplyByFloat64(duration, multiplier: Float64(progress))

    return time.numericOrZero.clamped(to: .zero, and: duration)
  }
}
