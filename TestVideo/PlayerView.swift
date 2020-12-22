import UIKit
import AVFoundation

class PlayerView: UIView {
  private lazy var stickerContainers: UIView = {
    let view = UIView(frame: playerLayer.videoRect)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.clipsToBounds = true
    view.backgroundColor = .clear
    addSubview(view)
    return view
  }()

  private var stickers: [UIImageView] {
    return stickerContainers.subviews as? [UIImageView] ?? []
  }

  override static var layerClass: AnyClass {
    AVPlayerLayer.self
  }
  
  private var playerLayer: AVPlayerLayer {
    layer as! AVPlayerLayer
  }
  
  var player: AVPlayer? {
    get { playerLayer.player }
    set { playerLayer.player = newValue }
  }

  var stickersCIImage: CIImage? {
    guard !stickers.isEmpty, let cgImage = stickerContainers.asImage().cgImage else { return nil }
    return CIImage(cgImage: cgImage)
  }

  func addSticker(_ sticker: UIImage? = nil) {
    let videoRect = playerLayer.videoRect

    // Random sticker position in video frame
    let randomX = CGFloat.random(in: (videoRect.maxX * 1/5)...(videoRect.maxX * 4/5))
    let randomY = CGFloat.random(in: (videoRect.maxY * 1/5)...(videoRect.maxY * 4/5))

    let image = sticker ?? UIImage(named: "sticker-\(Int.random(in: 1...2))")!
    let imageSize = image.size
    let scaleFactor = min(videoRect.height / image.size.height, image.size.height / videoRect.height)
    let scaledImageSize = imageSize.applying(.init(scaleX: scaleFactor, y: scaleFactor))

    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: randomX, y: randomY), size: scaledImageSize))
    imageView.image = image

    imageView.isUserInteractionEnabled = true

    // Dragging
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    imageView.addGestureRecognizer(panGesture)

    // Scaling
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    imageView.addGestureRecognizer(pinchGesture)

    // Rotating
    let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
    imageView.addGestureRecognizer(rotateGesture)

    // Removing
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    tapGesture.numberOfTapsRequired = 2
    imageView.addGestureRecognizer(tapGesture)

    stickerContainers.addSubview(imageView)
  }
}

// MARK: Gesture
private extension PlayerView {
  @objc func handlePan(_ sender: UIPanGestureRecognizer) {
    guard
      let touchingView = sender.view as? UIImageView,
      touchingView.isDescendant(of: stickerContainers)
    else { return }
    stickerContainers.bringSubviewToFront(touchingView)
    let translation = sender.translation(in: stickerContainers)
    touchingView.center = CGPoint(
      x: touchingView.center.x + translation.x,
      y: touchingView.center.y + translation.y)
    sender.setTranslation(.zero, in: stickerContainers)
  }

  @objc func handleRotate(_ sender: UIRotationGestureRecognizer) {
    guard
      let touchingView = sender.view as? UIImageView,
      touchingView.isDescendant(of: stickerContainers)
    else { return }
    stickerContainers.bringSubviewToFront(touchingView)
    let rotated = touchingView.transform.rotated(by: sender.rotation)
    touchingView.transform = rotated
    sender.rotation = 0
  }

  @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
    guard
      let touchingView = sender.view as? UIImageView,
      touchingView.isDescendant(of: stickerContainers)
    else { return }
    stickerContainers.bringSubviewToFront(touchingView)
    let scaled = touchingView.transform.scaledBy(x: sender.scale, y: sender.scale)
    touchingView.transform = scaled
    sender.scale = 1
  }

  @objc func handleTap(_ sender: UITapGestureRecognizer) {
    guard
      let touchingView = sender.view as? UIImageView,
      touchingView.isDescendant(of: stickerContainers)
    else { return }
    UIView.animate(
      withDuration: 0.2,
      animations: {
        touchingView.alpha = 0
      }, completion: { _ in
        touchingView.removeFromSuperview()
      })
  }
}
