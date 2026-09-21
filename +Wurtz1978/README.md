# Wurtz1978

The `Wurtz1978` package implements annular steam-water flow measurements
reported by Würtz (1978) for application, model assessment, and validation
studies with OpenSTREAM.

The implemented data support comparison of calculated and measured liquid-
film and disturbance-wave properties, including film flow, base-film
thickness, wave amplitude, frequency, velocity, number density, and
spacing.

## Experimental source

The authoritative experimental source is:

> J. Würtz, *An Experimental and Theoretical Investigation of Annular
> Steam-Water Flow in Tubes and Annuli at 30 to 90 bar*, Risø Report
> No. 372, Risø National Laboratory, Denmark, April 1978.

[View Risø Report No. 372 through DTU Orbit](https://backend.orbit.dtu.dk/ws/files/53678081/ris_r_372.pdf)

The report presents measurements of film-flow rates, pressure gradients,
film thicknesses, wave frequencies and velocities, and burnout heat fluxes
in one annular and two tubular geometries. More than 250 steam-water
experiments were performed at pressures from 30 to 90 bar under adiabatic
and diabatic conditions.

## Dataset scope

The package contains selected annular-flow measurements from the report,
organized for comparison with OpenSTREAM mixture, three-field, and
four-field calculations.

Each implemented record can include:

- geometry and operating conditions required to define an OpenSTREAM case;
- outlet equilibrium quality;
- liquid-film mass flow rate;
- base-film thickness;
- disturbance-wave amplitude;
- wave frequency and time period;
- wave velocity;
- wave number density;
- wave spacing;
- dataset identifiers and test-section names.

Some experimental quantities are unavailable for individual records. Empty
XML elements represent measurements that are not provided for those cases.

## Source data and units

The source data are stored in:

```text
+Wurtz1978/+src/Wurtz1978.xml
```

The XML file contains a top-level `dataset` structure with one record for
each implemented case. Numerical values use SI units.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `InletEnthalpy`;
- `Length`, `Area`, `Perimeter`, and `Diameter`;
- `Power`, `HeatFlux`, `WallMesh`, and `WallPower`;
- `MassFlux`, `OutletEnthalpy`, `InletSubcooling`, and `Xout`;
- `FilmFlow` and `BaseThickness`;
- `WaveAmplitude`, `WaveFrequency`, and `WaveVelocity`;
- `WaveNumberDensity` and `WaveSpacing`;
- `TestName` and `TestID`.

Wave time period is calculated in the plotting workflow as the reciprocal
of `WaveFrequency`. Base-film thickness, wave amplitude, and wave spacing
are stored in metres. Wave number density is stored in m⁻¹.

## OpenSTREAM representation

The current XML source represents the selected measurements as adiabatic
cases:

- applied `Power` and `HeatFlux` are zero;
- inlet and outlet enthalpies are equal;
- the thermodynamic inlet state corresponds to the measured equilibrium
  condition;
- `WallMesh` spans the modeled channel while `WallPower` provides the wall
  definition required by the generic OpenSTREAM input workflow.

This representation allows the calculated equilibrium annular-flow
properties to be compared directly with the reported measurements.

## Data extraction and processing

The experimental values are provided in tabulated form in Risø Report
No. 372. The implemented values were recovered manually from the report
and organized using the OpenSTREAM-database field conventions.

Values were converted to SI units where required. Additional quantities
needed for OpenSTREAM input generation or plotting were derived from the
reported geometry and operating conditions.

Manual transcription can introduce entry errors despite review. The
original report remains the authoritative source for the experimental
configuration, tabulated measurements, uncertainty, and interpretation.
Any future correction, retranscription, or other processing should be
documented here and in the source-data history.

## Package structure

```text
+Wurtz1978/
├── +src/
│   └── Wurtz1978.xml
├── @Wurtz1978/
│   ├── Wurtz1978.m
│   └── plotResults.m
└── README.md
```

The `Wurtz1978` class inherits from the generic `Dataset` class. Dataset
loading, case selection, OpenSTREAM input generation, solver execution,
and result storage are provided by the generic interface.

The `plotResults` method groups selected cases by pressure and mass flux
and creates calculated-versus-measured comparisons for the requested
quantity.

## Usage

Ensure that OpenSTREAM and OpenSTREAM-database are available on the MATLAB
path, then construct a selected case:

```matlab
data = Wurtz1978.Wurtz1978(<entryID>);
```

Generate the OpenSTREAM input files:

```matlab
inputFilePaths = data.makeInputFiles();
```

Run a selected solver:

```matlab
results = data.runCase('FourField');
```

Plot a calculated-versus-measured comparison:

```matlab
data.plotResults('wavevelocity','FourField');
```

When multiple cases are compared, create an array of calculated
`Wurtz1978` objects and call `plotResults` on that array.

## Supported comparisons

The plotting method supports the following comparison quantities:

- `quality`: outlet equilibrium quality;
- `filmflow`: liquid-film mass flow rate;
- `basethickness`: base-film thickness;
- `wavestrouhal`: wave Strouhal number;
- `waveshape`: wave shape factor;
- `wavedrag`: wave drag coefficient;
- `wavevelocity`: wave velocity;
- `waveperiod`: wave time period;
- `wavenumberdensity`: wave number density;
- `waveamplitude`: wave amplitude;
- `wavespacing`: wave spacing.

Outlet-quality comparison is available for Mixture, ThreeField, and
FourField results. Film-flow comparison requires ThreeField or FourField
results. Base-film and disturbance-wave comparisons require FourField
results.

Some plots also compare the experimental measurements and OpenSTREAM
results with annular-flow correlations implemented by the FourField model.

## Measurement uncertainty

The original report remains the authoritative source for measurement
methods, experimental uncertainty, and qualification of the data.

No additional quantitative data-extraction or processing uncertainty is
assigned by this implementation unless explicitly documented for a
particular field or case.

## Verification and limitations

OpenSTREAM-database does not currently include an automated test suite for
this package. Verification should include source-data loading, review of
generated OpenSTREAM inputs, representative solver calculations, and
review of calculated-versus-measured plots.

Known limitations include:

- the implemented values were manually transcribed from tables in
  Risø-372 and may remain subject to transcription errors;
- the package contains selected measurements and does not claim to
  reproduce every experiment reported in Risø-372;
- some wave quantities are unavailable for individual records;
- the source uses an adiabatic equilibrium representation for the
  implemented OpenSTREAM cases;
- the plotting method must exclude or otherwise handle unavailable
  measurements for the selected comparison quantity;
- film and wave comparisons depend on the selected ThreeField or FourField
  model and closure relations;
- applicability of a selected solver or correlation must be assessed for
  the geometry and conditions of each case;
- favorable agreement for the implemented cases should not be interpreted
  as general validation outside the conditions examined.

## Citation

When using this dataset implementation:

1. Cite Würtz (1978), Risø Report No. 372, as the original experimental
   source.
2. Cite the relevant OpenSTREAM publications.
3. Identify the OpenSTREAM-database version or commit used in the
   analysis.
4. Identify the selected cases, solver, model configuration, and compared
   quantities when reporting results.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package originate from the publicly available
Würtz report. The original report remains the authoritative source and
should be cited when the data are used.

This repository does not reproduce the original report pages or figures.
The machine-readable values are provided with source attribution and
documentation of their manual transcription, OpenSTREAM representation,
and known limitations.
