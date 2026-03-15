//
//  ribs-attach-detach-reference.swift
//  Reference only - not production code
//

import Foundation
import UIKit

// MARK: - Route intents / entry decisions

enum FeatureRouteIntent {
    case back
    case goToStepB(seed: StepBSeed)
    case openAuxiliary(AuxiliaryRoute)
}

enum CrossCaseRequestIntent {
    case startAdditionalVerification(payload: AdditionalVerificationPayload)
}

struct StepBSeed {}
enum AuxiliaryRoute { case help, addressSearch }
struct AdditionalVerificationPayload {}

enum FeatureEntryDecision {
    case shellFirstAuthoritative
    case inlinePushContinuation
    case auxiliaryLocalEntry
}

// MARK: - Child -> Parent communication

protocol IntentSink: AnyObject {
    func send(_ intent: FeatureRouteIntent)
    func send(_ intent: CrossCaseRequestIntent)
}

final class FeatureAInteractor {
    weak var intentSink: IntentSink?

    func didTapNext(seed: StepBSeed) {
        intentSink?.send(.goToStepB(seed: seed))
    }

    func didTapNeedAdditionalVerification(payload: AdditionalVerificationPayload) {
        intentSink?.send(.startAdditionalVerification(payload: payload))
    }

    func didTapBack() {
        intentSink?.send(.back)
    }
}

// MARK: - Entry coordinator

struct FeatureEntryContext {
    let isExternalReturn: Bool
    let requiresAuthoritativeFetch: Bool
    let canInlineContinue: Bool
    let isAuxiliary: Bool
}

final class FeatureEntryCoordinator {
    func decide(context: FeatureEntryContext) -> FeatureEntryDecision {
        if context.isAuxiliary {
            return .auxiliaryLocalEntry
        }

        if context.isExternalReturn || context.requiresAuthoritativeFetch || !context.canInlineContinue {
            return .shellFirstAuthoritative
        }

        return .inlinePushContinuation
    }
}

// MARK: - Cleanup contract

protocol DetachCleanable: AnyObject {
    func prepareForDetach()
    func cleanupForDetach()
}

final class CleanupBag {
    private var tasks: [Task<Void, Never>] = []
    private var cleanupBlocks: [() -> Void] = []
    private var isCleanedUp = false

    func insert(task: Task<Void, Never>) {
        tasks.append(task)
    }

    func insert(_ cleanup: @escaping () -> Void) {
        cleanupBlocks.append(cleanup)
    }

    func cleanup() {
        guard !isCleanedUp else { return }
        isCleanedUp = true

        tasks.forEach { $0.cancel() }
        tasks.removeAll()

        cleanupBlocks.forEach { $0() }
        cleanupBlocks.removeAll()
    }
}

// MARK: - Example child router/interactor pair

final class FeatureBRouter {
    func attach() {
        // attach child view / interactor / router
    }

    func detach() {
        // detach child hierarchy
    }
}

final class FeatureChildRIB: DetachCleanable {
    private let cleanupBag = CleanupBag()
    private(set) var isDetached = false

    func prepareForDetach() {
        // disable inputs / finish editing / freeze transient UI
    }

    func cleanupForDetach() {
        guard !isDetached else { return }
        isDetached = true
        cleanupBag.cleanup()
    }
}

// MARK: - Intent gate

struct IntentFingerprint: Hashable {
    let intentKind: String
    let ownerId: String
    let caseOrSessionId: String
    let routeFamily: String
    let targetId: String
    let payloadHash: Int
    let epoch: Int
}

final class IntentGate {
    private var inFlightFingerprints: Set<IntentFingerprint> = []

    func tryEnter(_ fingerprint: IntentFingerprint) -> Bool {
        inFlightFingerprints.insert(fingerprint).inserted
    }

    func unlock(_ fingerprint: IntentFingerprint) {
        inFlightFingerprints.remove(fingerprint)
    }
}

// MARK: - Same-case transition owner

final class CaseShellRouter: IntentSink {
    private var currentChild: (FeatureChildRIB & AnyObject)?
    private var currentFeatureBRouter: FeatureBRouter?
    private let intentGate = IntentGate()

    func send(_ intent: FeatureRouteIntent) {
        switch intent {
        case .back:
            handleBackIntent()

        case let .goToStepB(seed):
            transitionToStepB(seed: seed)

        case let .openAuxiliary(route):
            presentAuxiliary(route)
        }
    }

    func send(_ intent: CrossCaseRequestIntent) {
        switch intent {
        case let .startAdditionalVerification(payload):
            escalateCrossCaseRequest(payload: payload)
        }
    }

    private func handleBackIntent() {
        // parent owner decides whether pop / detach / no-op is allowed
    }

    private func presentAuxiliary(_ route: AuxiliaryRoute) {
        // same-case auxiliary modal/sheet only
    }

    private func transitionToStepB(seed: StepBSeed) {
        let fingerprint = IntentFingerprint(
            intentKind: "navigation",
            ownerId: "CaseShellRouter",
            caseOrSessionId: "case-1",
            routeFamily: "step-flow",
            targetId: "stepB",
            payloadHash: 0,
            epoch: 1
        )

        guard intentGate.tryEnter(fingerprint) else {
            return
        }

        currentChild?.prepareForDetach()

        let nextRouter = buildFeatureB(seed: seed)

        currentChild?.cleanupForDetach()
        currentChild = nil

        nextRouter.attach()
        currentFeatureBRouter = nextRouter
        intentGate.unlock(fingerprint)
    }

    private func buildFeatureB(seed: StepBSeed) -> FeatureBRouter {
        _ = seed
        return FeatureBRouter()
    }

    private func escalateCrossCaseRequest(payload: AdditionalVerificationPayload) {
        _ = payload
        // do not build the next case directly here.
        // send intent to RecoveryHost / platform so it can decide caseReset / new flow.
    }
}

// MARK: - Interactive pop ownership

final class InteractivePopCoordinator: NSObject, UINavigationControllerDelegate {
    private weak var navigationController: UINavigationController?
    private weak var detachOwner: InteractivePopDetachOwner?

    init(
        navigationController: UINavigationController,
        detachOwner: InteractivePopDetachOwner
    ) {
        self.navigationController = navigationController
        self.detachOwner = detachOwner
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let transitionCoordinator = navigationController.transitionCoordinator else {
            return
        }

        // Interactive gesture may still get cancelled. Detach only after completion callback.
        transitionCoordinator.notifyWhenInteractionChanges { [weak self] context in
            guard let self else { return }

            if context.isCancelled {
                self.detachOwner?.interactivePopCancelled()
            } else {
                self.detachOwner?.interactivePopCompleted()
            }
        }
    }
}

protocol InteractivePopDetachOwner: AnyObject {
    func interactivePopCompleted()
    func interactivePopCancelled()
}

final class StepRouter: InteractivePopDetachOwner {
    private var child: FeatureChildRIB?

    func interactivePopCompleted() {
        child?.prepareForDetach()
        child?.cleanupForDetach()
        child = nil
    }

    func interactivePopCancelled() {
        // keep child, no cleanup
    }
}

// MARK: - Modal dismiss vs case reset

final class ModalOwner {
    private var modalChild: (DetachCleanable & AnyObject)?
    private var isResetInProgress = false

    func modalDismissCompleted() {
        guard !isResetInProgress else { return }
        modalChild?.cleanupForDetach()
        modalChild = nil
    }

    func onCaseResetRequired() {
        isResetInProgress = true
        modalChild?.cleanupForDetach()
        modalChild = nil

        // continue reset ownership path
        performCaseReset()
    }

    private func performCaseReset() {
        // shell fixed -> child cleanup -> new case attach
    }
}
