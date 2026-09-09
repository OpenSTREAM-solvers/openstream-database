# Groeneveld CHF database
### Source: [NUREG/KM-0011 (NRC.gov)](https://www.nrc.gov/reading-rm/doc-collections/nuregs/knowledge/km0011/index.html)
## Abstract
This report contains a compilation of over 25,000 critical heat flux (CHF) data points obtained in water-cooled tubes that were used to derive the 2006 Groeneveld CHF lookup table. This compilation is based on 62 data sets that have been obtained during the past 60 years. This NUREG report describes the pertinent experimental details and possible concerns for these data sets. It also discusses the applicability and validity of the CHF lookup table to reactor conditions of interest and includes a graphical comparison of the ranges of conditions covered by these primary data and subsequently obtained supplementary data sets.

# Groeneveld2019

The `Groeneveld2019` package implements the complete critical heat flux
(CHF) database published in NUREG/KM-0011 for application, model assessment,
and validation studies with OpenSTREAM.

The database was used to support development of the 2006 Groeneveld CHF
lookup table and has also been used for the OECD Nuclear Energy Agency
Artificial Intelligence and Machine Learning Critical Heat Flux Benchmark
Exercises.

## Experimental source

The authoritative source is:

> D. C. Groeneveld, *Critical Heat Flux Data Used to Generate the 2006
> Groeneveld Critical Heat Flux Lookup Tables*, NUREG/KM-0011,
> U.S. Nuclear Regulatory Commission, January 2019.

[View NUREG/KM-0011 on GovInfo](https://www.govinfo.gov/app/details/GOVPUB-Y3_N88-PURL-gpo194267)

NUREG/KM-0011 compiles more than 25,000 CHF data points for water-cooled
tubes from 62 experimental datasets collected over approximately 60 years.
The report describes the experimental sources, data ranges, known concerns,
and relationship of the database to the 2006 Groeneveld CHF lookup table.

## Dataset scope

`Groeneveld2019.xml` contains all data from NUREG/KM-0011. Each record
represents one experimental CHF case and includes the geometry, operating
conditions, and critical-power information required to construct an
OpenSTREAM application case.

The implemented records contain the mandatory OpenSTREAM input-generation
fields together with dataset-specific quantities used for case selection,
comparison, and post-processing.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `InletEnthalpy`;
- `Length`, `Area`, `Perimeter`, and `Diameter`;
- `Power`, `WallMesh`, and `WallPower`;
- `HeatFlux`, `MassFlux`, and `XOUT`;
- `InletTemperature`, `InletSubcooling`, and `TIN`;
- `TestName` and `TestID`.

## Source data and units

The source data are stored in:

```text
+Groeneveld2019/+src/Groeneveld2019.xml
```

The XML file contains a top-level `dataset` structure with one record for
each implemented case. All numerical values use SI units.

The source records include reported quantities and values derived for the
OpenSTREAM representation, including:

- mass flow rate from mass flux and flow area;
- total power from heat flux, heated perimeter, and heated length;
- inlet enthalpy and inlet subcooling from the stated thermodynamic
  conditions;
- the uniform axial wall-power representation used to generate OpenSTREAM
  boundary conditions.

The original NUREG/KM-0011 publication remains the authoritative source for
the experimental data, source references, qualifications, and
interpretation.

## AI and machine-learning benchmark

The Groeneveld CHF database has also been used in the OECD Nuclear Energy
Agency Critical Heat Flux Benchmark Exercises developed by the Task Force
on Artificial Intelligence and Machine Learning for Scientific Computing
in Nuclear Engineering.

The benchmark exercises support assessment of artificial-intelligence and
machine-learning methods for CHF prediction.

[View the OECD NEA CHF benchmark information](https://www.oecd-nea.org/jcms/pl_86293/benchmarking-artificial-intelligence-and-machine-learning-for-critical-heat-flux-predictions)

## Package structure

```text
+Groeneveld2019/
├── +src/
│   └── Groeneveld2019.xml
├── @Groeneveld2019/
│   ├── Groeneveld2019.m
└── README.md
```

The `Groeneveld2019` class inherits from the generic `Dataset` class.
Dataset loading, case selection, OpenSTREAM input generation, solver
execution, and result storage are provided by the generic interface.

## Usage

Ensure that OpenSTREAM and OpenSTREAM-database are available on the MATLAB
path, then construct a selected case:

```matlab
data = Groeneveld2019.Groeneveld2019(<entryID>);
```

Generate the OpenSTREAM input files:

```matlab
inputFilePaths = data.makeInputFiles();
```

Run a selected solver:

```matlab
results = data.runCase('Mixture');
```

## Verification and limitations

OpenSTREAM-database does not currently include an automated test suite for
this package. Verification should include source-data loading, generation
and review of OpenSTREAM inputs, representative solver calculations,
convergence review, and calculated-versus-measured comparison plots.

Users remain responsible for assessing:

- applicability of the selected OpenSTREAM solver and closure models;
- numerical convergence and sensitivity;
- interpretation of CHF and film-dryout criteria;
- experimental qualifications and concerns documented in NUREG/KM-0011;
- suitability of the selected cases and comparison metrics.

A favorable comparison for a selected case, solver, or model configuration
should not be interpreted as general validation outside the conditions
examined.

## Citation

When using this dataset implementation:

1. Cite NUREG/KM-0011 as the source of the implemented CHF database.
2. Cite the relevant original experimental source when required for the
   selected cases.
3. Cite the relevant OpenSTREAM publications and identify the
   OpenSTREAM-database version or commit used in the analysis.
4. Cite the OECD NEA benchmark documentation when the dataset is used in
   the associated AI/ML CHF benchmark context.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package originate from the publicly available
NUREG/KM-0011 compilation. The original report and underlying experimental
sources remain authoritative and should be cited when the data are used.

This repository does not reproduce the original report pages. The
machine-readable values are provided with source attribution and
documentation of their OpenSTREAM representation and known limitations.
