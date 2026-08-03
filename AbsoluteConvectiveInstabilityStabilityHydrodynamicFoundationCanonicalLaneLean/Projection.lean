import Mathlib.Analysis.Complex.Basic
import Mathlib.Topology.Instances.Real
import Mathlib.Order.Filter.Basic

namespace HautevilleHouse
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

open Filter
open TopologicalSpace

-- The dichotomy of absolute vs convective instability
inductive InstabilityKind : Type
  | absolute
  | convective
  deriving DecidableEq, Repr

-- A hydrodynamic perturbation: amplitude as a function of space and time
structure HydrodynamicState where
  perturbation : ℝ → ℝ → ℂ

-- The full closure state includes the hydrodynamic field and its classification
structure ClosureState where
  state : HydrodynamicState
  kind : InstabilityKind

-- The canonical projection used in the bridge: it acts as the identity on all states.
-- In this admissible-class foundation, the projecting object is the admissible class itself.
structure Projection (α : Type) where
  toFun : α → α
  idempotent : ∀ x : α, toFun (toFun x) = toFun x

-- The principal theorem projection for this hydrodynamic stability foundation.
def theoremProjection : Projection ClosureState := {
  toFun := fun x => x,
  idempotent := by intro x; rfl
}

-- Bridge theorem: the projection is idempotent.
theorem theorem_projection_idempotent (x : ClosureState) :
    theoremProjection.toFun (theoremProjection.toFun x) = theoremProjection.toFun x := by
  exact theoremProjection.idempotent x

-- Additional structure: the notion of pointwise stability
def IsConvectivelyStable (s : HydrodynamicState) : Prop :=
  ∀ x : ℝ, Tendsto (fun t : ℝ => Complex.normSq (s.perturbation x t)) atTop (𝓝 0)

def IsAbsolutelyUnstable (s : HydrodynamicState) : Prop :=
  ¬ IsConvectivelyStable s

-- The admissible-class bridge predicate: a state is admissible if it is classified consistently.
def Admissible (c : ClosureState) : Prop :=
  match c.kind with
  | InstabilityKind.convective => IsConvectivelyStable c.state
  | InstabilityKind.absolute => IsAbsolutelyUnstable c.state

-- Key theorem: the projection maps admissible states to admissible states (trivially, since it is identity).
theorem projection_preserves_admissible (c : ClosureState) :
    Admissible c → Admissible (theoremProjection.toFun c) := by
  intro h
  exact h

-- Another bridge statement: any state can be projected into the 'admissible closure' by forgetting the mismatch
-- Here we provide a canonical closure: the identity induces the admissible closure of the theory.
def admissibleClosure : Set ClosureState := { c : ClosureState | Admissible c }

-- The projection restricted to the admissible closure is the identity (definitionally).
theorem projection_on_admissible (c : ClosureState) (h : c ∈ admissibleClosure) :
    theoremProjection.toFun c = c := rfl

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HautevilleHouse