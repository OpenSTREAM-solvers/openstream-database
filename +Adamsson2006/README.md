# Adamsson2006

The `Adamsson2006` package implements liquid-film mass-flow measurements
reported by Adamsson and Anglart (2006) for application, model assessment,
and validation studies with OpenSTREAM.

The experiments investigate diabatic annular steam-water flow in a heated
tube under conditions representative of boiling water reactor operation.
They are particularly useful for assessing mechanistic film-flow and dryout
models because the liquid-film flow was measured directly for several axial
power distributions and operating conditions.

## Experimental source

The authoritative experimental source is:

> C. Adamsson and H. Anglart, “Film flow measurements for high-pressure
> diabatic annular flow in tubes with various axial power distributions,”
> *Nuclear Engineering and Design*, Vol. 236, No. 23, pp. 2485–2493,
> 2006. [View the publication](https://doi.org/10.1016/j.nucengdes.2006.03.002)

The article reports liquid-film mass-flow measurements performed in the
high-pressure two-phase-flow loop at the Royal Institute of Technology
(KTH), Sweden.

## Experimental configuration

The experiments used an electrically heated vertical stainless-steel tube.
The implemented test-section geometry is:

- heated length: 3.65 m;
- inner diameter: approximately 14 mm;
- flow area: 1.5394e-4 m²;
- heated perimeter: 4.3982e-2 m.

The liquid film was extracted through a porous-wall section near the outlet
of the test section. The extracted sample was condensed in a heat exchanger,
and the sample vapor content was determined from a heat balance. The
liquid-film flow rate was obtained by progressively increasing the extracted
sample flow until vapor appeared in the sample.

For nonuniform power distributions, different measurement elevations were
obtained by shortening the test section while preserving the local heat flux
at the measurement location. For the uniform power distribution, the
effective measurement location was varied by changing the inlet temperature
and hence the onset-of-boiling location.

## Dataset scope

The implemented measurements use water at a system pressure of 7 MPa and
mass fluxes from 750 to 1750 kg/(m²·s). Four axial power-distribution
families are represented:

- uniform;
- inlet-peaked;
- middle-peaked;
- outlet-peaked.

Each dataset record contains the operating conditions and axial power
profile required to construct an OpenSTREAM case, together with measured
liquid-film mass-flow values and their corresponding elevations.

The experiments show that the axial power distribution influences the
liquid-film inventory. In particular, outlet-peaked heating produces less
film than inlet-peaked heating under comparable conditions. The reported
film flow also approaches a very small value near dryout.

## Source-data preparation

The experimental values were manually extracted from the tables in the
journal paper and organized using the OpenSTREAM-database field conventions.
Values were converted to SI units where required, and additional quantities
needed for OpenSTREAM input generation or post-processing were derived from
the reported geometry and operating conditions.

Manual transcription can introduce entry errors despite review. The
original journal paper remains the authoritative source for the experimental
configuration, tabulated measurements, uncertainty, and interpretation. Any
future correction, retranscription, or other processing should be documented
here and in the source-data history.

## Source data and units

The source data are stored in:

```text
+Adamsson2006/+src/Adamsson2006.xml
```

The XML file contains a top-level `dataset` structure with one record for
each implemented case. All stored numerical values use SI units, with
temperatures expressed in kelvin.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `InletEnthalpy`;
- `Length`, `Area`, `Perimeter`, and `Diameter`;
- `Power`, `HeatFlux`, `WallMesh`, and `WallPower`;
- `MassFlux`, `InletTemperature`, and `InletSubcooling`;
- `Quality`, `Elevation`, and `FilmFlow`;
- `TestName` and `TestID`.

`WallMesh` defines the axial intervals used to represent the heated tube,
while `WallPower` defines the corresponding relative axial power
distribution. Uniform and shaped power profiles are therefore represented
using the same generic OpenSTREAM wall-input convention.

`Quality` identifies the experimental case condition. The calculated outlet
equilibrium quality is obtained from the OpenSTREAM result and may be stored
separately during post-processing. These quantities should not be assumed to
be identical without reviewing the specific calculation.

## Package structure

```text
+Adamsson2006/
├── +src/
│   └── Adamsson2006.xml
├── @Adamsson2006/
│   ├── Adamsson2006.m
│   └── plotResults.m
└── README.md
```

The `Adamsson2006` class inherits from the generic `Dataset` class. Dataset
loading, case selection, OpenSTREAM input generation, solver execution, and
result storage are provided by the generic interface.

The package also includes dataset-specific post-processing and plotting for
film-flow analysis.

## Application workflow

The dataset is intended primarily for annular-flow calculations using the
ThreeField solver. A typical workflow is:

```matlab
% Load a selected experimental case.
data = Adamsson2006.Adamsson2006(<entryID>);

% Initialize and adjust the OpenSTREAM inputs.
opts = data.inputOptions();
data.makeInputFiles(opts);

% Run the annular-flow calculation.
data.runCase('ThreeField');

% Review convergence.
data.checkConvergence();

% Compare calculated and measured film-flow distributions.
data.plotResults('Film-flow comparison','film');
```

The exact physical models and numerical options should be selected and
documented for the intended analysis.

## Post-processing

The dataset-specific post-processor stores quantities used for film-flow and
dryout assessment, including:

- test-section length-to-diameter ratio;
- applied power;
- calculated outlet equilibrium quality;
- minimum calculated film flow per unit perimeter;
- onset-of-annular-flow index and downstream annular-flow length;
- entrainment-to-deposition ratio at annular-flow onset;
- initial entrained-liquid fraction;
- mixture- and film-solver convergence status;
- maximum film-initialization iteration count.

The plotting method supports:

- calculated vapor, film, and droplet mass-flow distributions together with
  measured liquid-film flow;
- a derived droplet-flow estimate obtained from total liquid flow minus the
  measured film flow;
- axial heat-flux and equilibrium-quality distributions.

The derived droplet flow is not a direct experimental measurement and should
be identified accordingly in figures and discussion.

## Measurement uncertainty and limitations

The original article remains authoritative for measurement uncertainty and
experimental qualifications.

Important limitations of the implementation include:

- the implemented values were manually transcribed from tables in the
  journal paper and may remain subject to transcription errors;
- the geometry is a round tube rather than a rod bundle;
- individual records contain measurements only at the implemented axial
  locations;
- the droplet-flow comparison is derived rather than measured directly;
- the calculated film-flow distribution depends on the selected onset-of-
  annular-flow, entrainment, deposition, wall-boiling, friction, and
  momentum models;
- agreement for the implemented cases should not be interpreted as general
  validation outside the investigated conditions.

## Verification

OpenSTREAM-database does not currently include an automated test suite for
this package. Verification should include:

- successful loading of every selected source-data record;
- comparison of the manually transcribed values with the journal tables;
- review of generated OpenSTREAM geometry, boundary-condition, model, and
  option inputs;
- comparison of the represented axial power profile with the source;
- confirmation of mixture- and film-solver convergence;
- review of calculated and measured film-flow distributions;
- sensitivity to the selected entrainment, deposition, and annular-flow
  initialization models;
- confirmation that derived quantities are distinguished from direct
  measurements.

## Citation

When using this dataset implementation:

1. Cite Adamsson and Anglart (2006) as the original experimental source.
2. Cite the relevant OpenSTREAM publications.
3. Identify the OpenSTREAM-database version or commit used in the analysis.
4. Report the selected cases, solver, model configuration, numerical
   options, and convergence status.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package were manually transcribed from tables
in the published Adamsson and Anglart article. The original publication
remains the authoritative source and should be cited when the data are used.
The article and its publisher retain their applicable rights, and users
should follow any access, reuse, redistribution, citation, and attribution
requirements associated with the publication.

This repository does not reproduce the original article pages or figures.
The machine-readable values are provided with source attribution and
documentation of their manual transcription, OpenSTREAM representation, and
known limitations.
