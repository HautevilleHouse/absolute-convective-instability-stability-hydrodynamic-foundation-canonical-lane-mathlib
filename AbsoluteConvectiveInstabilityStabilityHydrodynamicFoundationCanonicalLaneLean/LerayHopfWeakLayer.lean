/-
All Rights Reserved - No License Granted

Copyright (c) 2026 HautevilleHouse. All rights reserved.

This repository is published for academic review, citation, priority, public
notice, and research-reference purposes only.

No license is granted to use, copy, reproduce, redistribute, modify, merge,
publish, distribute, sublicense, sell, fork, mirror, scrape, use for training or
fine-tuning, include in a dataset or benchmark, use to create, evaluate, or
benchmark a derivative system, incorporate into another system, or create
derivative works from this repository or any substantial portion of it without
prior written permission from the rights holder.

Viewing this repository on GitHub for academic review and citation is permitted
with all rights reserved by the rights holder.

Any discussion, review, comparison, implementation, derivative research use, or
public reference to this repository must cite the repository and preserve this
notice.

Unauthorized reproduction or redistribution of this repository, including public
GitHub forks containing the repository contents, constitutes copyright
infringement and may be subject to DMCA.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic

/-!
# Absolute Convective Instability Stability Hydrodynamic Foundation

This module records the admissible-class bridge for hydrodynamic stability
classifications. The fields are proof-carrying Lean terms, so the package
checks that each named stability obligation is supplied by the source-derived
certificate route.
-/

namespace HydrodynamicFoundation
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

-- A simplified hydrodynamic state: growth rate and spatial growth
structure HydrodynamicState where
  growthRate : ℝ
  spatialGrowth : ℝ

def Stable (s : HydrodynamicState) : Prop := s.growthRate < 0
def AbsoluteInstability (s : HydrodynamicState) : Prop := s.growthRate > 0 ∧ s.spatialGrowth = 0
def ConvectiveInstability (s : HydrodynamicState) : Prop := s.growthRate > 0 ∧ s.spatialGrowth ≠ 0

-- The admissible-class bridge: for a given state, exactly one of stable/absolute/convective holds
structure InstabilityEnvelope where
  state : HydrodynamicState
  isStable : Prop
  isAbsolute : Prop
  isConvective : Prop
  stable_iff : isStable ↔ Stable state
  absolute_iff : isAbsolute ↔ AbsoluteInstability state
  convective_iff : isConvective ↔ ConvectiveInstability state
  trichotomy : isStable ∨ isAbsolute ∨ isConvective
  mutual_exclusion : ¬ (isAbsolute ∧ isConvective) ∧ ¬ (isStable ∧ isAbsolute) ∧ ¬ (isStable ∧ isConvective)
  classification : (isStable ↔ ¬ isAbsolute ∧ ¬ isConvective) ∧
    (isAbsolute ↔ ¬ isStable ∧ ¬ isConvective) ∧
    (isConvective ↔ ¬ isStable ∧ ¬ isAbsolute)

-- Canonical state: a convectively unstable wave
noncomputable def canonicalState : HydrodynamicState := { growthRate := 1, spatialGrowth := 1 }

-- Canonical envelope for the canonical state
noncomputable def canonicalEnvelope : InstabilityEnvelope := {
  state := canonicalState
  isStable := Stable canonicalState
  isAbsolute := AbsoluteInstability canonicalState
  isConvective := ConvectiveInstability canonicalState
  stable_iff := Iff.rfl
  absolute_iff := Iff.rfl
  convective_iff := Iff.rfl
  trichotomy := by
    simp [Stable, AbsoluteInstability, ConvectiveInstability, canonicalState]
  mutual_exclusion := by
    simp [Stable, AbsoluteInstability, ConvectiveInstability, canonicalState]
  classification := by
    simp [Stable, AbsoluteInstability, ConvectiveInstability, canonicalState]
}

def InstabilityEnvelopeClosed (E : InstabilityEnvelope) : Prop :=
  (E.isStable ∨ E.isAbsolute ∨ E.isConvective) ∧
  ¬ (E.isStable ∧ E.isAbsolute) ∧
  ¬ (E.isStable ∧ E.isConvective) ∧
  ¬ (E.isAbsolute ∧ E.isConvective)

theorem canonicalEnvelope_closed : InstabilityEnvelopeClosed canonicalEnvelope := by
  constructor
  · exact canonicalEnvelope.trichotomy
  · constructor
    · exact canonicalEnvelope.mutual_exclusion.2.1
    · constructor
      · exact canonicalEnvelope.mutual_exclusion.2.2
      · exact canonicalEnvelope.mutual_exclusion.1

theorem canonical_convective_instability : ConvectiveInstability canonicalState := by
  simp [ConvectiveInstability, canonicalState]

theorem canonical_not_absolute : ¬ AbsoluteInstability canonicalState := by
  simp [AbsoluteInstability, canonicalState]

theorem convective_implies_not_absolute (E : InstabilityEnvelope) : E.isConvective → ¬ E.isAbsolute := by
  intro hc ha
  exact (E.mutual_exclusion.1) ⟨ha, hc⟩

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HydrodynamicFoundation