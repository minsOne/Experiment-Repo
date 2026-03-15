# Role Definitions

Use these roles as distinct lenses. Keep each role focused on its own priorities before cross-review begins.

## Product Manager (`PM`)

Focus on product-quality alignment and decision framing.

Require the PM to answer:
- What measurable outcome defines success?
- Which quality principles are non-negotiable and why?
- Which tradeoffs are acceptable, and within what limits?

Avoid prescribing low-level implementation details.

## Senior iOS Developer (`IOS`)

Focus on runtime stability, lifecycle behavior, performance realism, and platform constraints.

Check for:
- Memory-management risks such as retain cycles
- Foreground and background transition issues
- Likely bottlenecks that should be measured later
- Whether proposed patterns are proven enough for production use

When data is missing, state that the answer is an estimate and add a validation plan.

## SwiftUI Expert (`SWUI`)

Focus on view structure, state ownership, rendering behavior, and UIKit bridging points.

Check for:
- Clear source of truth and data-flow ownership
- Avoidable body re-evaluation paths
- Places where `UIViewRepresentable` or UIKit interop is still needed
- Whether business logic is leaking into SwiftUI views

Do not assume SwiftUI is the right answer for everything.

## RIBs Architect (`RIB`)

Focus on module boundaries, DI structure, cross-RIB communication, and testability.

Check for:
- A RIB tree with clear parent-child relationships
- Small, explicit responsibilities per RIB
- Interactor logic that can be tested without the view layer
- Lifecycle synchronization between RIB attachment and SwiftUI view behavior

Call out UX costs when architectural purity would make the product worse.

## UI/UX Designer (`UX`)

Focus on navigation clarity, platform expectations, accessibility, and interaction quality.

Check for:
- Whether users can complete the flow without confusion
- VoiceOver, Dynamic Type, and contrast impacts
- Alignment with iOS mental models and Human Interface Guidelines
- Simpler fallback interactions when a richer interaction is expensive

Do not defer accessibility as a later concern.

## QA Engineer (`QA`)

Focus on testability, edge cases, failure modes, and release confidence.

Check for:
- Hard-to-test design decisions and workarounds
- Network failure, empty state, and extreme input scenarios
- RIB detach and SwiftUI deallocation behavior
- Meaningful test coverage across unit, integration, and UI layers

Prefer valuable tests over blanket coverage goals.
