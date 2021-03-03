import Foundation

/// Referene MTTransitions github: https://github.com/alexiscn/MTTransitions
extension VideoTransition {
  enum Effect: Int, CaseIterable, CustomStringConvertible {
    case none
    case fade
    case wind
    case multiplyBlend
    case pinwheel
    case gridFlip
    case bounce
    case bowTieHorizontal
    case bowTieVertical
    case burn
    case butterflyWaveScrawler
    case cannabisleaf
    case circleCrop
    case circleOpen
    case circle
    case colorPhase
    case colourDistance
    case crazyParametricFun
    case crossHatch
    case crossWarp
    case crossZoom
    case cube
    case directional
    case directionalWarp
    case directionalWipe
    case displacement
    case doomScreen
    case doorway
    case dreamy
    case dreamyZoom
    case fadeColor
    case fadegrayscale
    case flyeye
    case glitchDisplace
    case glitchMemories
    case heart

    var transition: BaseTransition {
      switch self {
      case .none: return NoneTransition()
      case .fade: return FadeTransition()
      case .wind: return WindTransition()
      case .multiplyBlend: return MultiplyBlendTransition()
      case .pinwheel: return PinwheelTransition()
      case .gridFlip: return GridFlipTransition()
      case .bounce: return BounceTransition()
      case .bowTieHorizontal: return BowTieHorizontalTransition()
      case .bowTieVertical: return BowTieVerticalTransition()
      case .burn: return BurnTransition()
      case .butterflyWaveScrawler: return ButterflyWaveScrawlerTransition()
      case .cannabisleaf: return CannabisleafTransition()
      case .circleCrop: return CircleCropTransition()
      case .circleOpen: return CircleOpenTransition()
      case .circle: return CircleTransition()
      case .colorPhase: return ColorPhaseTransition()
      case .colourDistance: return ColourDistanceTransition()
      case .crazyParametricFun: return CrazyParametricFunTransition()
      case .crossHatch: return CrossHatchTransition()
      case .crossWarp: return CrossWarpTransition()
      case .crossZoom: return CrossZoomTransition()
      case .cube: return CubeTransition()
      case .directional: return DirectionalTransition()
      case .directionalWarp: return DirectionalWarpTransition()
      case .directionalWipe: return DirectionalWipeTransition()
      case .displacement: return DisplacementTransition()
      case .doomScreen: return DoomScreenTransition()
      case .doorway: return DoorwayTransition()
      case .dreamy: return DreamyTransition()
      case .dreamyZoom: return DreamyZoomTransition()
      case .fadeColor: return FadeColorTransition()
      case .fadegrayscale: return FadegrayscaleTransition()
      case .flyeye: return FlyeyeTransition()
      case .glitchDisplace: return GlitchDisplaceTransition()
      case .glitchMemories: return GlitchMemoriesTransition()
      case .heart: return HeartTransition()
      }
    }

    var description: String {
      return transition.functionName
    }
  }
}
