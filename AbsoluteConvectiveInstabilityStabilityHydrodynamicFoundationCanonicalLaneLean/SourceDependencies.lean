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
import Mathlib
import AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean.SourcePackage

/-!
# Source dependency model for `absolute-convective-instability-stability-hydrodynamic-foundation`

This module records the import and data-route surface used by the source
package/scripts before translation into Lean data.

It makes the source runtime dependency boundary explicit. The dependency boundary is internal to the Lean package as structural data.

In addition, this module encodes the admissible-class bridge for the key theorems and structures in the field of absolute and convective instability in hydrodynamic stability theory.
-/


namespace HautevilleHouse
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

-- Existing dependency recording structures
structure SourceImportDependency where
  file : String
  kind : String
  module : String
  name : String
  alias : String
  level : Nat
deriving Repr, DecidableEq

structure SourcePathDependency where
  file : String
  name : String
  path : String
  role : String
  line : Nat
deriving Repr, DecidableEq

-- Domain-specific structures
structure ComplexFrequency where
  re : ℝ
  im : ℝ
deriving Repr, DecidableEq

structure Wavenumber where
  value : ℝ
deriving Repr, DecidableEq

structure DispersionRelation where
  frequency : Wavenumber → ComplexFrequency
  groupVelocity : Wavenumber → ℝ
deriving Repr

inductive StabilityType where
  | stable
  | convectiveInstability
  | absoluteInstability
deriving Repr, DecidableEq

def zeroFrequency : ComplexFrequency := { re := 0, im := 0 }

noncomputable def classifyStability (D : DispersionRelation) : StabilityType := by
  classical
  exact if h : ∃ k, D.frequency k = zeroFrequency ∧ D.groupVelocity k = 0 then
    if h' : ∃ k, D.frequency k = zeroFrequency ∧ D.groupVelocity k = 0 ∧ (D.frequency k).im > 0 then
      StabilityType.absoluteInstability
    else
      StabilityType.convectiveInstability
  else
    StabilityType.stable

theorem absolute_instability_bridge
    {D : DispersionRelation}
    (h : ∃ k, D.frequency k = zeroFrequency ∧ D.groupVelocity k = 0 ∧ (D.frequency k).im > 0) :
    classifyStability D = StabilityType.absoluteInstability := by
  classical
  unfold classifyStability
  have hOut : (∃ k, D.frequency k = zeroFrequency ∧ D.groupVelocity k = 0) := by
    rcases h with ⟨k, hk⟩
    exact ⟨k, hk.1, hk.2.1⟩
  rw [dif_pos hOut]
  rw [dif_pos h]
  rfl

/-- The admissible bridge structure for hydrodynamic stability classification. -/
structure StabilityBridge where
  D : DispersionRelation
  classification : StabilityType
  criterion : Prop
  criterion_implies_classification : criterion → classification = StabilityType.absoluteInstability ∨ classification = StabilityType.convectiveInstability ∨ classification = StabilityType.stable

-- Example source dependency data for the repository
def sourceImportDependencies : List SourceImportDependency := [
  { file := "scripts/extract_dispersion.py", kind := "from_import", module := "__future__", name := "annotations", alias := "", level := 0 },
  { file := "scripts/extract_dispersion.py", kind := "import", module := "argparse", name := "", alias := "", level := 0 },
  { file := "scripts/extract_dispersion.py", kind := "import", module := "numpy", name := "", alias := "np", level := 0 },
  { file := "scripts/extract_dispersion.py", kind := "import", module := "scipy.optimize", name := "brentq", alias := "", level := 0 },
  { file := "scripts/classify_instability.py", kind := "from_import", module := "__future__", name := "annotations", alias := "", level := 0 },
  { file := "scripts/classify_instability.py", kind := "import", module := "numpy", name := "", alias := "np", level := 0 },
  { file := "scripts/classify_instability.py", kind := "import", module := "json", name := "", alias := "", level := 0 },
  { file := "scripts/normalize_wavenumber.py", kind := "from_import", module := "__future__", name := "annotations", alias := "", level := 0 },
  { file := "scripts/normalize_wavenumber.py", kind := "import", module := "numpy", name := "", alias := "np", level := 0 }
]

def sourcePathDependencies : List SourcePathDependency := [
  { file := "scripts/extract_dispersion.py", name := "data", path := "data/dispersion_relations.json", role := "input", line := 12 },
  { file := "scripts/classify_instability.py", name := "model", path := "models/stability_classifier.pt", role := "output", line := 25 },
  { file := "scripts/normalize_wavenumber.py", name := "config", path := "config/normalization.yaml", role := "config", line := 5 }
]

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HautevilleHouse