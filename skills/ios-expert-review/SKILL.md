---
name: ios-expert-review
description: Review iOS product, screen, flow, SwiftUI, UIKit, or RIBs architecture topics through six expert lenses and synthesize a practical plan. Use when Codex needs a multi-perspective review for iOS feature design, refactors, architecture tradeoffs, UX flows, testing strategy, or launch-readiness decisions.
---

# iOS Expert Review

Run a structured six-perspective review, then converge on a practical plan without fabricating evidence.

## Intake

Use the topic from the user message when it is already provided.

Ask one short follow-up only when the topic itself is missing.

Collect or infer these inputs before reviewing:
- Topic or decision to review
- Current architecture or implementation baseline
- Target screen, feature, or flow
- Minimum iOS version if relevant
- Constraints: schedule, quality bar, performance, team capacity
- Known problems or target KPIs

If important context is missing, proceed with at most five explicit assumptions and label the result `가정 기반 초안`.

## Workflow

### Step 1: Set shared constraints

Have the Product Manager define:
- Success criteria in measurable terms
- Up to three non-negotiable principles and why they matter
- Acceptable tradeoff boundaries

Use this step to set constraints, not to pre-decide implementation details.

### Step 2: Run independent analysis

Have these five roles analyze independently:
- Senior iOS Developer
- SwiftUI Expert
- RIBs Architect
- UI/UX Designer
- QA Engineer

Let each role see only the PM constraints from Step 1. Do not let roles see each other's analysis yet.

Require each role to output:
- `1-3` proposals in priority order
- Proposal ID in the form `ROLE-N`, for example `IOS-1`, `SWUI-2`, `RIB-1`
- Recommendation
- Rationale type: `사용자 맥락`, `코드 관찰`, `플랫폼 가이드`, `가정`, or `추정`
- Key risk or limitation
- Verification plan

Allow `N/A` with a short reason when a role's concern is not meaningfully relevant to the topic.

### Step 3: Run cross-review

After all independent analysis is complete, allow each role to critique up to two proposal IDs from Step 2.

Require each critique to include:
- Target proposal ID
- Why it is risky, weak, or incomplete
- One concrete alternative
- Whether the role could accept the original proposal as-is

Summarize the review as:
- `공통 합의`: items supported by at least four roles
- `충돌`: role pairs, tradeoff, and whether each side can yield
- `빈틈`: areas not addressed well enough and whether more analysis is needed

### Step 4: Synthesize the final plan

Have the Product Manager synthesize the output into a decision record.

Always include:
- Chosen decisions
- Rejected alternatives and why they were rejected
- Remaining uncertainties
- A practical implementation roadmap
- Quality gates
- Risk response table
- Test plan

Use the output shape in [output-template.md](./references/output-template.md).

## Guardrails

- Distinguish clearly between observed facts, platform guidance, assumptions, and estimates.
- Do not invent benchmarks, Instruments numbers, HIG citations, or production evidence. If unavailable, say so and propose how to verify.
- Favor signal over symmetry. Do not pad the answer just to satisfy a pattern.
- Keep Step 2 independent. Do not ask roles to pre-criticize proposals they have not seen yet.
- Keep code-level implementation detail lightweight unless the user explicitly asks for it.
- If conflicts remain unresolved, surface them instead of forcing false consensus.

## Role Guidance

Load role instructions from [role-definitions.md](./references/role-definitions.md) only when needed during execution.
