import AVFoundation

/// Referene FrameGrabber github: https://github.com/arthurhammer/FrameGrabber
class PlaybackController {
  private let seeker: PlayerSeeker

  let player: AVPlayer
  var currentTime: ((CMTime) -> Void)?
  var currentRate: ((Bool) -> Void)?

  private var isPlaying = false {
    didSet {
      currentRate?(isPlaying)
    }
  }

  private var currentTimeObserver: Any?
  private var isPlayingObserver: NSKeyValueObservation?

  init(playerItem: AVPlayerItem) {
    player = AVPlayer(playerItem: playerItem)
    seeker = PlayerSeeker(player: player)
    addObserver()
  }

  deinit {
    if let currentTimeObserver = currentTimeObserver {
      player.removeTimeObserver(currentTimeObserver)
    }
    isPlayingObserver?.invalidate()
  }

  func replaceCurrentItem(with playerItem: AVPlayerItem) {
    if let currentTimeObserver = currentTimeObserver {
      player.removeTimeObserver(currentTimeObserver)
    }
    isPlayingObserver?.invalidate()
    player.replaceCurrentItem(with: playerItem)
    addObserver()
  }

  func playOrPause() {
    if isPlaying {
      pause()
    } else {
      play()
    }
  }

  func play() {
    guard !isPlaying else { return }
    seekToStartIfNecessary()
    player.play()
  }

  func pause() {
    guard isPlaying else { return }
    player.pause()
  }

  func step(byCount count: Int) {
    pause()
    player.currentItem?.step(byCount: count)
  }

  // MARK: - Seeking
  func smoothlySeek(to time: CMTime) {
    seeker.smoothlySeek(to: time)
  }

  private func seekToStartIfNecessary() {
    guard
      let item = player.currentItem,
      item.currentTime() >= item.duration
    else { return }
    smoothlySeek(to: .zero)
  }
}

private extension PlaybackController {
  func addObserver() {
    currentTimeObserver = player.addPeriodicTimeObserver(
      forInterval: CMTime(seconds: 0.0001, preferredTimescale: CMTimeScale(NSEC_PER_MSEC)),
      queue: .main,
      using: { [weak self] time in
        self?.currentTime?(time)
      })

    isPlayingObserver = player.observe(
      \.rate,
      options: [.new],
      changeHandler: { [weak self] _, change in
        guard let newValue = change.newValue else { return }
        self?.isPlaying = newValue != 0
      })
  }
}
