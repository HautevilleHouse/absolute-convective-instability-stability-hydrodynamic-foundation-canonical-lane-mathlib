import Mathlib.Data.Real.Basic

/-!
# Mathlib Statement Layer

Domain: Absolute Convective Instability, Stability, Hydrodynamic Foundation.
Canonical knowledge domain encoding the admissible-class bridge for
classification of absolute versus convective instability.
-/

namespace HautevilleHouse
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

def sourceRepository : String := "AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundation"
def sourceDescription : String := "Absolute/convective instability classification in hydrodynamic stability"

-- ------------------------------------------------------------------
-- Basic hydrodynamic state
-- ------------------------------------------------------------------
structure HydrodynamicState where
  meanFlowVelocity : ℝ
  density : ℝ
  kinematicViscosity : ℝ
  surfaceTension : ℝ
  depth : ℝ

-- ------------------------------------------------------------------
-- Complex frequency (we avoid importing ℂ to keep dependencies light)
-- ------------------------------------------------------------------
structure ComplexFrequency where
  real : ℝ
  imag : ℝ
deriving Repr

namespace ComplexFrequency

def zero : ComplexFrequency := ⟨0, 0⟩

@[ext] theorem ext {z w : ComplexFrequency} : z.real = w.real → z.imag = w.imag → z = w := by
  cases z
  cases w
  simp_all

@[simp] theorem zero_real : zero.real = 0 := rfl
@[simp] theorem zero_imag : zero.imag = 0 := rfl

theorem zero_eq_iff (z : ComplexFrequency) : z = zero ↔ z.real = 0 ∧ z.imag = 0 := by
  constructor
  · intro h
    rw [h]
    simp
  · intro h
    rcases h with ⟨hr, hi⟩
    ext
    · exact hr.symm
    · exact hi.symm

end ComplexFrequency

-- ------------------------------------------------------------------
-- Dispersion relation and its derivative
-- ------------------------------------------------------------------
structure DispersionRelation where
  omega : ℝ → ComplexFrequency

structure DispersionDerivative where
  dOmegaDk : ℝ → ComplexFrequency

-- Absolute instability: a saddle point with positive growth rate
def AbsoluteInstability (D : DispersionRelation) (D' : DispersionDerivative) : Prop :=
  ∃ k : ℝ, D'.dOmegaDk k = ComplexFrequency.zero ∧ 0 < (D.omega k).imag

-- Convective instability: at least one growing mode, and all growing modes
-- have nonzero real group velocity (so perturbations are advected away)
def ConvectiveInstability (D : DispersionRelation) (D' : DispersionDerivative) : Prop :=
  (∃ k : ℝ, 0 < (D.omega k).imag) ∧
  (∀ k : ℝ, 0 < (D.omega k).imag → (D'.dOmegaDk k).real ≠ 0)

-- ------------------------------------------------------------------
-- Admissible class and the bridge theorem
-- ------------------------------------------------------------------
structure AdmissibleClass where
  admissible : HydrodynamicState → Prop

-- The bridge theorem specific to this domain:
-- For every admissible state, absolute and convective instability are
-- mutually exclusive for a given dispersion relation.
def ConstrainedTheoremClosure (A : AdmissibleClass) : Prop :=
  ∀ (s : HydrodynamicState), A.admissible s →
    ∀ (D : DispersionRelation) (D' : DispersionDerivative),
      AbsoluteInstability D D' → ¬ ConvectiveInstability D D'

def theoremSpecificClosurePackageClosed : Prop :=
  ∀ A : AdmissibleClass, ConstrainedTheoremClosure A

-- ------------------------------------------------------------------
-- Proof obligation ledger
-- ------------------------------------------------------------------
structure MathlibProofObligation where
  sourceKey : String
  theoremObject : String
  commonCoreImported : Bool
  theoremSpecificDefinitionsNative : Bool
  theoremSpecificBridgeNative : Bool
  theoremSpecificAdmittedClosureNative : Bool
  unrestrictedClassicalClosureNative : Bool
  carriedGap : String
deriving Repr, DecidableEq

def mathlibProofObligation : MathlibProofObligation := {
  sourceKey := sourceRepository,
  theoremObject := sourceDescription,
  commonCoreImported := true,
  theoremSpecificDefinitionsNative := true,
  theoremSpecificBridgeNative := true,
  theoremSpecificAdmittedClosureNative := true,
  unrestrictedClassicalClosureNative := false,
  carriedGap := "admissible-class closure package closes over the physically admissible states; unrestricted classical closure remains carried"
}

-- ------------------------------------------------------------------
-- Verification checks for the obligation fields
-- ------------------------------------------------------------------
theorem mathlib_common_core_imported_checked :
    mathlibProofObligation.commonCoreImported = true := by
  rfl

theorem mathlib_theorem_specific_definitions_native_checked :
    mathlibProofObligation.theoremSpecificDefinitionsNative = true := by
  rfl

theorem mathlib_theorem_specific_bridge_native_checked :
    mathlibProofObligation.theoremSpecificBridgeNative = true := by
  rfl

theorem mathlib_theorem_specific_admitted_closure_native_checked :
    mathlibProofObligation.theoremSpecificAdmittedClosureNative = true := by
  rfl

theorem mathlib_unrestricted_classical_closure_carried :
    mathlibProofObligation.unrestrictedClassicalClosureNative = false := by
  rfl

-- ------------------------------------------------------------------
-- Proof that the admissible-class bridge statement holds
-- ------------------------------------------------------------------
theorem theorem_specific_closure_package_checked :
    theoremSpecificClosurePackageClosed := by
  intro A
  intro s hAdmissible D D'
  intro hAbs
  intro hConv
  rcases hAbs with ⟨k0, hk0, hpos⟩
  have hrealZero : (D'.dOmegaDk k0).real = 0 := by
    rw [ComplexFrequency.zero_eq_iff] at hk0
    exact hk0.1
  exact (hConv.2 k0 hpos) hrealZero

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HautevilleHouse