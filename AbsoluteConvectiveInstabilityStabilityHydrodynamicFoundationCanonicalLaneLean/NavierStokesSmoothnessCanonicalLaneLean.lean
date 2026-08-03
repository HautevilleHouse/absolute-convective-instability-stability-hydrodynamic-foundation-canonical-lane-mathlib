-- This module is the root of the AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean Lean proof package.
-- It provides the canonical definitions and bridge theorems for the classification
-- of hydrodynamic stability into absolute, convective, and stable regimes.

import Mathlib.Analysis.Calculus.Deriv
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.NormedSpace.Basic
import Mathlib.Topology.Basic

noncomputable section
open Complex
open scoped Real

namespace ACISHF

/-- The dispersion relation of a hydrodynamical linear stability problem. -/
structure DispersionRelation where
  omega : ℂ → ℂ
  groupVel : ℂ → ℂ
  has_groupVel : ∀ k : ℂ, HasDerivAt omega (groupVel k) k

/-- A mode is unstable if its imaginary frequency is positive. -/
def UnstableMode (D : DispersionRelation) (k : ℂ) : Prop :=
  0 < (D.omega k).im

/-- Strong linear stability: all modes are stable (decay). -/
def StronglyStable (D : DispersionRelation) : Prop :=
  ∀ k : ℂ, (D.omega k).im < 0

/-- Neutral linear stability: no mode grows. -/
def NeutrallyStable (D : DispersionRelation) : Prop :=
  ∀ k : ℂ, (D.omega k).im ≤ 0

/-- Absolute instability: an unstable mode with zero group velocity exists. -/
def AbsolutelyUnstable (D : DispersionRelation) : Prop :=
  ∃ k : ℂ, UnstableMode D k ∧ D.groupVel k = 0

/-- Convective instability: there is an unstable mode, but no absolute instability. -/
def ConvectivelyUnstable (D : DispersionRelation) : Prop :=
  (∃ k : ℂ, UnstableMode D k) ∧ ¬ AbsolutelyUnstable D

/-- The canonical stability classification. -/
inductive StabilityClassification where
  | stable
  | absolute
  | convective

/-- Classify a dispersion relation based on the algebraic criteria. -/
noncomputable def classify (D : DispersionRelation) : StabilityClassification := by
  classical
  exact if hAbs : AbsolutelyUnstable D then StabilityClassification.absolute
    else if hC : ∃ k : ℂ, UnstableMode D k then StabilityClassification.convective
    else StabilityClassification.stable

/-- If a dispersion relation is strongly stable, it is not absolutely unstable. -/
theorem stable_not_absolute (D : DispersionRelation) (hS : StronglyStable D) : ¬ AbsolutelyUnstable D := by
  intro hAbs
  rcases hAbs with ⟨k, hU, hgv⟩
  have hlt := hS k
  have hgt := hU
  linarith

/-- If a dispersion relation is strongly stable, it is not convectively unstable. -/
theorem stable_not_convective (D : DispersionRelation) (hS : StronglyStable D) : ¬ ConvectivelyUnstable D := by
  intro hC
  rcases hC with ⟨hG, _⟩
  rcases hG with ⟨k, hU⟩
  have hlt := hS k
  linarith

/-- If a dispersion relation is absolutely unstable, it is not stable. -/
theorem absolute_not_stable (D : DispersionRelation) (hA : AbsolutelyUnstable D) : ¬ StronglyStable D := by
  intro hS
  rcases hA with ⟨k, hU, hgv⟩
  have hlt := hS k
  linarith

/-- Convective instability implies existence of an unstable mode. -/
theorem convective_has_unstable (D : DispersionRelation) (hC : ConvectivelyUnstable D) : ∃ k : ℂ, UnstableMode D k := hC.1

/-- Convective instability is not absolute instability. -/
theorem convective_not_absolute (D : DispersionRelation) (hC : ConvectivelyUnstable D) : ¬ AbsolutelyUnstable D := hC.2

/-- Absolute and convective instability are mutually exclusive (by definition). -/
theorem absolute_not_convective (D : DispersionRelation) (hA : AbsolutelyUnstable D) : ¬ ConvectivelyUnstable D := by
  intro hC
  exact hC.2 hA

/-- The bridge theorem for classification: an absolutely unstable dispersion
  is classified as absolute. -/
theorem classify_eq_absolute (D : DispersionRelation) (hA : AbsolutelyUnstable D) :
    classify D = StabilityClassification.absolute := by
  unfold classify
  rw [dif_pos hA]

/-- The bridge theorem for classification: if there is no absolute instability
  but some growth exists, the classification is convective. -/
theorem classify_eq_convective (D : DispersionRelation)
    (hAbs : ¬ AbsolutelyUnstable D)
    (hC : ∃ k : ℂ, UnstableMode D k) :
    classify D = StabilityClassification.convective := by
  unfold classify
  rw [dif_neg hAbs, dif_pos hC]

/-- The bridge theorem for classification: if there is no growth at all,
  the classification is stable. -/
theorem classify_eq_stable (D : DispersionRelation)
    (hAbs : ¬ AbsolutelyUnstable D)
    (hC : ¬ ∃ k : ℂ, UnstableMode D k) :
    classify D = StabilityClassification.stable := by
  unfold classify
  rw [dif_neg hAbs, dif_neg hC]

/-- A strongly stable dispersion is classified as stable. -/
theorem classify_stable_of_strongly_stable (D : DispersionRelation) (hS : StronglyStable D) :
    classify D = StabilityClassification.stable := by
  apply classify_eq_stable
  · exact stable_not_absolute D hS
  · intro hG
    rcases hG with ⟨k, hU⟩
    have hlt := hS k
    linarith

/-- The admissible class of a dispersion relation, carrying its classification.
  This encodes the canonical bridge between the abstract algebraic criteria and
  the physical hydrodynamic stability theory. -/
structure AdmissibleClassification (D : DispersionRelation) where
  classification : StabilityClassification
  classification_eq : classify D = classification

/-- A concrete hydrodynamic stability system bundles a state space, a linearised
  operator, and an admissible dispersion relation bridging them. -/
structure HydrodynamicStabilitySystem where
  -- State space (typically a space of perturbations).
  State : Type
  [normedState : NormedAddCommGroup State]
  [normedSpaceState : NormedSpace ℝ State]
  -- Linearised evolution operator.
  linearOperator : State →L[ℝ] State
  -- The associated dispersion relation.
  dispersion : DispersionRelation
  -- The classification is admissible.
  admissibleClassification : AdmissibleClassification dispersion

end ACISHF