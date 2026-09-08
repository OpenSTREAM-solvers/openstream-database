[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Documentation](https://github.com/OpenSTREAM-solvers/openstream/actions/workflows/publishDocs.yml/badge.svg)](https://github.com/OpenSTREAM-solvers/openstream/actions/workflows/publishDocs.yml)

# OpenSTREAM-database

OpenSTREAM-database provides an application and validation environment for
[OpenSTREAM](https://github.com/OpenSTREAM-solvers/openstream), enabling
users to configure, run, and evaluate OpenSTREAM solvers using publicly
available experimental datasets.

OpenSTREAM-database complements the core OpenSTREAM repository:

- **OpenSTREAM** provides the solver frameworks, physical and closure
  models, numerical methods, input handling, visualization capabilities,
  tutorials, documentation, and core automated tests.
- **OpenSTREAM-database** provides dataset implementations, application
  workflows, calculated-versus-measured comparisons, and an environment
  for model assessment and validation.

OpenSTREAM and OpenSTREAM-database are maintained as separate
repositories. OpenSTREAM must be installed independently and made
available on the MATLAB path.

## Getting started

Install and configure OpenSTREAM by following the
[OpenSTREAM Getting Started guide](https://openstream-solvers.github.io/openstream/Usage/gettingStarted.html).

Clone OpenSTREAM-database separately and add both repository roots to the
MATLAB path:

```matlab
addpath('<path-to-openstream>')
addpath('<path-to-openstream-database>')
```

Verify that MATLAB can locate functionality from both repositories:

```matlab
which Inputs.InputSet
which Dataset
```

The returned paths should refer to the intended OpenSTREAM and
OpenSTREAM-database working copies.

Application workflows are provided in the `projects` folder. Further
information is available on the
[OpenSTREAM-database documentation page](https://openstream-solvers.github.io/openstream/Applications/database.html).

## Units

OpenSTREAM uses SI units for all inputs, calculated quantities, and stored
results.

OpenSTREAM-database follows the same convention. All numerical data stored
in dataset source files under the `+src` directories are expressed in SI
units, including data converted from other systems of units used in the
original experimental sources.

Any conversion from the units reported in an original publication to the
SI values stored by OpenSTREAM-database should be documented in the
corresponding dataset README or implementation.

## Data provenance and citation

The datasets implemented in OpenSTREAM-database are derived from publicly
available experimental sources.

When using a dataset:

- Consult and cite the original experimental publication.
- Review the experimental conditions, measurement definitions, original
  units, and reported uncertainties.
- Review any unit conversion, transcription, processing, interpolation,
  filtering, or assumptions introduced by the implementation.
- Cite OpenSTREAM and OpenSTREAM-database as appropriate.

Use of an OpenSTREAM-database implementation does not replace citation of
the original experimental source.

## Citing OpenSTREAM

If OpenSTREAM is used in research or published work, cite the relevant
OpenSTREAM publications:

- J.-M. Le Corre, J. Chan, E. Walter, E. T. Hurlburt, and R. W. Morse,
  “OpenSTREAM: A new open-source platform for two-phase flow model
  development,” *12th International Conference on Multiphase Flow
  (ICMF 2025)*, Toulouse, France, May 12–16, 2025.

- J.-M. Le Corre, J. Chan, E. Walter, E. T. Hurlburt, and R. W. Morse,
  “OpenSTREAM: An open-source platform for two-phase flow modeling and
  simulation,” *21st International Topical Meeting on Nuclear Reactor
  Thermal Hydraulics (NURETH-21)*, Busan, Korea,
  August 31–September 5, 2025.

The original experimental publications associated with the datasets used
in an analysis should also be cited.

## Validation and interpretation

Inclusion of a dataset or application does not imply that every
OpenSTREAM solver, model combination, or calculated quantity has been
comprehensively verified or validated against that dataset.

Users remain responsible for assessing:

- The applicability and quality of the experimental data.
- The assumptions and validity ranges of the selected models.
- Numerical convergence and discretization sensitivity.
- Experimental, model, parameter, and numerical uncertainty.
- The suitability of the selected comparison quantities and metrics.
- The interpretation of calculated-versus-measured differences.

A favorable comparison for one case, quantity, or model selection should
not be interpreted as general validation outside the conditions examined.

## Testing and verification

OpenSTREAM-database does not currently include an automated test suite.

Changes to dataset implementations and application workflows should be
verified through documented and reproducible execution of the affected
cases. This should include review of the source data, generated OpenSTREAM
inputs, calculated results, experimental comparisons, and post-processing
outputs.

Development of an automated testing and regression framework is a planned
improvement.

## Development status

OpenSTREAM-database is under active development. Dataset implementations,
application workflows, comparison methods, documentation, and
verification capabilities may continue to evolve.

Users should review the dataset-specific documentation and repository
history when reproducing earlier calculations.

## Contributing

Contributions may include new publicly available datasets, corrections to
existing implementations, additional application workflows, improved
comparisons and visualization, uncertainty information, documentation,
and verification capabilities.

Before contributing, review the
[OpenSTREAM-database contribution guidelines](https://openstream-solvers.github.io/openstream/Applications/contributing.html).

## License

The original OpenSTREAM-database software and documentation are distributed
under the MIT License. See the [LICENSE](LICENSE) file for the complete
terms.

Experimental data and material derived from third-party publications may
be subject to separate copyright, attribution, licensing, or redistribution
conditions. Consult the dataset-specific README files and original sources
before reusing or redistributing dataset content.