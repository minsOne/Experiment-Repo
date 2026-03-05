import Foundation
import UIKit

public enum ActualDisappearReason: String, Codable {
    case interactiveTransitionCancelled = "interactive transition canceled"
    case beingDismissed = "isBeingDismissed == true"
    case movingFromParent = "isMovingFromParent == true"
    case detachedFromWindowAndNoActiveContainer = "view.window == nil && not owned by active container"
    case ownedByActiveContainer = "still has active container"
}

public struct ActualDisappearCheck: Codable, Equatable {
    public let isActualDisappear: Bool
    public let reason: ActualDisappearReason
}

public enum ActualDisappearEvaluator {
    public static func evaluate(_ viewController: UIViewController) -> ActualDisappearCheck {
        let isInteractiveTransitionCancelled =
            (viewController.transitionCoordinator?.isInteractive == true)
                && (viewController.transitionCoordinator?.isCancelled == true)

        if isInteractiveTransitionCancelled {
            return .init(
                isActualDisappear: false,
                reason: .interactiveTransitionCancelled,
            )
        }

        if viewController.isBeingDismissed {
            return .init(
                isActualDisappear: true,
                reason: .beingDismissed,
            )
        }

        if viewController.isMovingFromParent {
            return .init(
                isActualDisappear: true,
                reason: .movingFromParent,
            )
        }

        let isOwnedByActiveContainer = isOwnedByActiveContainer(viewController)
        if viewController.view.window == nil, !isOwnedByActiveContainer {
            return .init(
                isActualDisappear: true,
                reason: .detachedFromWindowAndNoActiveContainer,
            )
        }

        return .init(
            isActualDisappear: false,
            reason: .ownedByActiveContainer,
        )
    }

    private static func isOwnedByActiveContainer(_ viewController: UIViewController) -> Bool {
        guard
            !viewController.isBeingDismissed,
            !viewController.isMovingFromParent
        else { return false }

        if let nav = viewController.navigationController,
           !nav.isBeingDismissed,
           nav.view.window != nil,
           nav.viewControllers.contains(viewController)
        {
            return true
        }

        if let parent = viewController.parent,
           parent.view.window != nil,
           parent !== viewController,
           parent.children.contains(viewController)
        {
            return true
        }

        if let presenter = viewController.presentingViewController,
           presenter.view.window != nil,
           !presenter.isBeingDismissed
        {
            return true
        }

        return false
    }
}
