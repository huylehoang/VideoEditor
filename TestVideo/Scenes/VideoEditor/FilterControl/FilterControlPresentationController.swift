import UIKit

class FilterControlPresentationController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
    transitioningDelegate = self
    modalPresentationStyle = .custom
  }

  override func loadView() {
    view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FilterControlPresentationController: UIViewControllerTransitioningDelegate {
  public func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    let presentationController = PresentationController(
      presentedViewController: presented,
      presenting: presenting)
    presentationController.delegate = self
    return presentationController
  }

  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return PresentingAnimation()
  }

  public func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    return DimissingAnimation()
  }
}

extension FilterControlPresentationController: UIAdaptivePresentationControllerDelegate {
  public func adaptivePresentationStyle(
    for controller: UIPresentationController,
    traitCollection: UITraitCollection
  ) -> UIModalPresentationStyle {
    return .none
  }

  public func presentationController(
    _ controller: UIPresentationController,
    viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle
  ) -> UIViewController? {
    return self
  }
}

private final class PresentingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(
    using transitionContext: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
    return 0.2
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let to = transitionContext.viewController(forKey: .to)
    else { return }

    let containerView = transitionContext.containerView

    containerView.addSubview(to.view)

    let constraints = [
      to.view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      to.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      to.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
    ]
    NSLayoutConstraint.activate(constraints)

    containerView.layoutIfNeeded()

    to.view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

    UIView.animate(
      withDuration: 0.2,
      delay: 0,
      options: .curveEaseOut,
      animations: {
        to.view.transform = .identity
      },
      completion: { _ in
        transitionContext.completeTransition(true)
      })
  }
}

private final class DimissingAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(
    using transitionContext: UIViewControllerContextTransitioning?
  ) -> TimeInterval {
    return 0.2
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let from = transitionContext.viewController(forKey: .from)
    else { return }

    UIView.animate(
      withDuration: 0.2,
      delay: 0.0,
      usingSpringWithDamping: 1,
      initialSpringVelocity: 1,
      options: .curveEaseIn,
      animations: {
        from.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        transitionContext.containerView.alpha = 0
      },
      completion: { _ in
        transitionContext.completeTransition(true)
      })
  }
}

private final class PresentationController: UIPresentationController {
  private var dimmingView: UIView!

  override init(
    presentedViewController: UIViewController,
    presenting presentingViewController: UIViewController?
  ) {
    super.init(
      presentedViewController: presentedViewController,
      presenting: presentingViewController)
    setupDimmingView()
  }

  override func presentationTransitionWillBegin() {
    if let containerView = containerView {
      containerView.insertSubview(dimmingView, at: 0)
      let constraints = [
        dimmingView.topAnchor.constraint(equalTo: containerView.topAnchor),
        dimmingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        dimmingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        dimmingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      ]
      NSLayoutConstraint.activate(constraints)
    }

    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 1.0
      return
    }

    coordinator.animate { [weak self] _ in
      self?.dimmingView.alpha = 1.0
    }
  }

  override func dismissalTransitionWillBegin() {
    guard let coordinator = presentedViewController.transitionCoordinator else {
      dimmingView.alpha = 0.0
      return
    }

    coordinator.animate { [weak self] _ in
      self?.dimmingView.alpha = 0.0
    }
  }
}

private extension PresentationController {
  func setupDimmingView() {
    dimmingView = UIView()
    dimmingView.translatesAutoresizingMaskIntoConstraints = false
    dimmingView.backgroundColor = UIColor(red: 33/255, green: 43/255, blue: 54/255, alpha: 0.76)
    dimmingView.alpha = 0.0

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    dimmingView.isUserInteractionEnabled = true
    dimmingView.addGestureRecognizer(tapGesture)
  }

  @objc func handleTap(_ sender: UITapGestureRecognizer) {
    presentedViewController.dismiss(animated: true)
  }
}
