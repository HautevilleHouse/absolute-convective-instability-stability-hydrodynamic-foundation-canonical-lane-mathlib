import Mathlib.Data.Real.Basic
import Mathlib.Data.Complex.Basic
import Mathlib.Tactic.NormNum

/-!
# Hydrodynamic Stability Analytic Objects

This module gives the theorem package a local analytic vocabulary for
absolute and convective instability in hydrodynamic stability theory:
one-dimensional space, time, scalar fields, perturbation fields,
dispersion relations, and the classification of instability types.
-/

namespace HautevilleHouse
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

abbrev Space := ℝ
abbrev Time := ℝ
abbrev ScalarField := Time → Space → ℝ
abbrev ComplexScalarField := Time → Space → ℂ

def zeroScalarField : ScalarField := fun _ _ => 0
def zeroComplexField : ComplexScalarField := fun _ _ => 0

structure HydrodynamicOperators where
  spatialDerivative : ScalarField → ScalarField
  timeDerivative : ScalarField → ScalarField
  linearizedPerturbation : ComplexScalarField → ComplexScalarField
  pressureProjection : ScalarField → ScalarField
  pressureProjectionIdempotent : ∀ p, pressureProjection (pressureProjection p) = pressureProjection p

def primitiveOperators : HydrodynamicOperators := {
  spatialDerivative := fun _ => zeroScalarField
  timeDerivative := fun _ => zeroScalarField
  linearizedPerturbation := fun u => u
  pressureProjection := fun p => p
  pressureProjectionIdempotent := by intro p; rfl
}

structure DispersionRelation where
  frequency : ℝ → ℂ

def growthRate (D : DispersionRelation) (k : ℝ) : ℝ := (D.frequency k).im

structure HydrodynamicSystem where
  baseFlow : ScalarField
  perturbation : ComplexScalarField
  operators : HydrodynamicOperators
  dispersion : DispersionRelation
  groupVelocity : ℝ → ℝ
  viscosity : ℝ

def primitiveSystem : HydrodynamicSystem := {
  baseFlow := zeroScalarField
  perturbation := zeroComplexField
  operators := primitiveOperators
  dispersion := { frequency := fun _ => 0 }
  groupVelocity := fun _ => 0
  viscosity := 1
}

def absolutelyUnstableSystem : HydrodynamicSystem := {
  baseFlow := zeroScalarField
  perturbation := zeroComplexField
  operators := primitiveOperators
  dispersion := { frequency := fun _ => Complex.I }
  groupVelocity := fun _ => 0
  viscosity := 1
}

def IsStable (S : HydrodynamicSystem) : Prop :=
  ∀ k : ℝ, growthRate S.dispersion k ≤ 0

def IsConvectiveInstability (S : HydrodynamicSystem) : Prop :=
  (∃ k, growthRate S.dispersion k > 0) ∧
  ∀ k, growthRate S.dispersion k > 0 → S.groupVelocity k ≠ 0

def IsAbsoluteInstability (S : HydrodynamicSystem) : Prop :=
  ∃ k, growthRate S.dispersion k > 0 ∧ S.groupVelocity k = 0

def WellPosedClassification (S : HydrodynamicSystem) : Prop :=
  IsStable S ∨ IsConvectiveInstability S ∨ IsAbsoluteInstability S

theorem primitive_system_stable : IsStable primitiveSystem := by
  intro k
  simp [primitiveSystem, growthRate, DispersionRelation.frequency]

theorem absolutely_unstable_system_absolute : IsAbsoluteInstability absolutelyUnstableSystem := by
  unfold IsAbsoluteInstability
  use 0
  constructor
  · simp [absolutelyUnstableSystem, growthRate, DispersionRelation.frequency]
    norm_num
  · simp [absolutelyUnstableSystem, groupVelocity]

theorem absolute_instability_not_stable (S : HydrodynamicSystem) :
    IsAbsoluteInstability S → ¬ IsStable S := by
  intro h_abs h_stable
  rcases h_abs with ⟨k, hk_pos, hk_gv⟩
  have hk_nonpos : growthRate S.dispersion k ≤ 0 := h_stable k
  exact (not_lt_of_ge hk_nonpos) hk_pos

theorem convective_instability_not_stable (S : HydrodynamicSystem) :
    IsConvectiveInstability S → ¬ IsStable S := by
  intro h_conv h_stable
  rcases h_conv with ⟨⟨k, hk_pos⟩, hk_gv⟩
  have hk_nonpos : growthRate S.dispersion k ≤ 0 := h_stable k
  exact (not_lt_of_ge hk_nonpos) hk_pos

theorem absolute_instability_not_convective (S : HydrodynamicSystem) :
    IsAbsoluteInstability S → ¬ IsConvectiveInstability S := by
  intro h_abs h_conv
  rcases h_abs with ⟨k, hk_pos, hk_gv⟩
  rcases h_conv with ⟨hk_exists, hk_all⟩
  have hk_neq : S.groupVelocity k ≠ 0 := hk_all k hk_pos
  exact hk_neq hk_gv

theorem primitive_system_well_posed : WellPosedClassification primitiveSystem := by
  unfold WellPosedClassification
  exact Or.inl primitive_system_stable

theorem absolutely_unstable_system_well_posed : WellPosedClassification absolutelyUnstableSystem := by
  unfold WellPosedClassification
  exact Or.inr (Or.inr absolutely_unstable_system_absolute)

structure AdmissibleClassBridge where
  primitive_stable : IsStable primitiveSystem
  absolutely_unstable_example : IsAbsoluteInstability absolutelyUnstableSystem
  absolute_not_stable : ∀ S : HydrodynamicSystem, IsAbsoluteInstability S → ¬ IsStable S
  convective_not_stable : ∀ S : HydrodynamicSystem, IsConvectiveInstability S → ¬ IsStable S
  primitive_wellposed : WellPosedClassification primitiveSystem
  absolutely_unstable_wellposed : WellPosedClassification absolutelyUnstableSystem

def admissibleClassBridge : AdmissibleClassBridge := {
  primitive_stable := primitive_system_stable
  absolutely_unstable_example := absolutely_unstable_system_absolute
  absolute_not_stable := fun S h => absolute_instability_not_stable S h
  convective_not_stable := fun S h => convective_instability_not_stable S h
  primitive_wellposed := primitive_system_well_posed
  absolutely_unstable_wellposed := absolutely_unstable_system_well_posed
}

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HautevilleHouse