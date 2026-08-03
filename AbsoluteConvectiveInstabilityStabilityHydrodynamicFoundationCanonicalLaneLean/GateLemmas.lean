import AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean.BridgeLemmas

namespace HautevilleHouse
namespace AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean

def gateClosed (A : AdmissibleClass) : Prop :=
  A.endpointSatisfied ∨ A.remainderRecorded

theorem gate_from_admissible_class (A : AdmissibleClass) :
    gateClosed A := by
  exact A.gateWitness

end AbsoluteConvectiveInstabilityStabilityHydrodynamicFoundationCanonicalLaneLean
end HautevilleHouse