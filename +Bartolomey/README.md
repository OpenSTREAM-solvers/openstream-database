# Bartolomey

The `Bartolomey` package implements subcooled-boiling void-fraction data
for application and validation studies with OpenSTREAM.

The package combines several related experimental datasets associated with
different lead authors. The name `Bartolomey` is retained because the
compiled experiments appear to originate from the same research laboratory
and are presented together in the immediate source used for this
implementation.

## Data source

All numerical data implemented in `+src/Bartolomey.xml` were extracted
from:

> *RELAP5/MOD3 Subcooled Boiling Model Assessment*, NUREG/IA-0025,
> U.S. Nuclear Regulatory Commission, May 1998.

[View NUREG/IA-0025 on GovInfo](https://www.govinfo.gov/content/pkg/GOVPUB-Y3_N88-PURL-gpo73247/pdf/GOVPUB-Y3_N88-PURL-gpo73247.pdf)

The original foreign-language publications were not readily available and
were not used directly for numerical data extraction. All implemented
values were digitized from figures reproduced in NUREG/IA-0025.

## Original experimental references

NUREG/IA-0025 associates the compiled data with the following experimental
publications:

- G. G. Bartolomey and L. S. Sabotinov, “Void fraction at subcooled
  boiling at different heat distribution laws along the channel,”
  *Yadrena Energiya*, No. 3, Sofia, Bulgaria, 1976.
- G. G. Bartolomey et al., “Experimental investigation of void fraction
  at subcooled boiling mode in tubes,” *Teploenergetika*, No. 3,
  pp. 20–22, 1982, in Russian.
- G. G. Bartolomey, “Void fraction of diabatic flows in tubes at different
  heat distribution laws,” *Heat and Mass Transfer VI*, International
  Conference, Vol. 5, Minsk, 1980, pp. 38–43.
- D. A. Labuntsov et al., “Void fraction investigation of nonequilibrium
  two-phase flows,” *ENIN Transactions: Heat Transfer and Hydrodynamics*,
  Vol. 35, pp. 88–98.

These references provide the historical experimental context. Users should
consult NUREG/IA-0025 for the figures from which the implemented numerical
values were extracted.

## Dataset scope

The package contains water experiments for subcooled boiling in heated
tubes. The implemented cases include:

- operating and geometry information required to generate OpenSTREAM input
  files;
- measured void fractions;
- measurement locations expressed by either equilibrium quality or axial
  elevation;
- additional metadata and derived quantities used by the dataset class and
  plotting workflow.

The source file contains multiple experimental groups identified through
`TestName`, including Bartolomey-, Sabotinov-, and Labuntsov-led datasets.

## Source data and units

The source data are stored in:

```text
+Bartolomey/+src/Bartolomey.xml
```

All numerical values use SI units. The XML file contains the mandatory
OpenSTREAM input-generation fields together with dataset-specific fields.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `InletEnthalpy`;
- `Length`, `Area`, and `Perimeter`;
- `Power`, `WallMesh`, and `WallPower`;
- `VoidFraction`, `Quality`, and `Elevation`;
- `MassFlux`, `InletTemperature`, `HeatFlux`, `HeatedLength`,
  `NonHeatedLength`, and `Diameter`;
- `TestName` and `TestID`.

For a given case, measured void fraction is represented against either
`Quality` or `Elevation`. When one coordinate is unavailable, the
corresponding XML elements are empty.

## Data extraction and processing

The report does not provide the implemented experimental values in
machine-readable or tabulated form. The data points were extracted from
plots in NUREG/IA-0025 using plot-digitization software with a point-and-
click procedure, then converted and stored using the SI-unit conventions
of OpenSTREAM-database.

The digitized values are approximations of the plotted data and may be
affected by figure resolution, axis scaling, marker size, line thickness,
and manual point selection. The number of digits stored in the XML file
should not be interpreted as the experimental measurement precision or as
the accuracy of the digitization process.

Any correction, redigitization, interpolation, reconstruction, or other
processing identified during future review should be documented here and
in the source-data history.

## Package structure

```text
+Bartolomey/
├── +src/
│   └── Bartolomey.xml
├── @Bartolomey/
│   ├── Bartolomey.m
│   └── plotResults.m
└── README.md
```

The `Bartolomey` class inherits from the generic `Dataset` class. The
constructor reads and interprets `Bartolomey.xml` when the dataset object
is created. The `plotResults` method compares calculated and measured void
fractions using equilibrium quality or axial elevation.

## Usage

Ensure that OpenSTREAM and OpenSTREAM-database are available on the MATLAB
path, then construct a selected dataset entry:

```matlab
data = Bartolomey.Bartolomey(<entryID>);
```

Generate the OpenSTREAM input files:

```matlab
inputFilePaths = data.makeInputFiles();
```

Run a selected solver:

```matlab
results = data.runCase('Mixture');
```

Consult the corresponding application workflow for the model selections
and plotting arguments used in a specific comparison.

## Measurement uncertainty

Measurement uncertainties should be taken from NUREG/IA-0025 or the
underlying experimental references where available. No additional
measurement uncertainty is inferred by this implementation.

Digitization uncertainty is distinct from reported experimental
uncertainty. A quantitative digitization uncertainty has not been assigned
unless explicitly documented for a particular case or data series.

## Verification and limitations

OpenSTREAM-database does not currently include an automated test suite.
The dataset implementation should be verified through reproducible review
of source-data loading, generated OpenSTREAM inputs, representative solver
calculations, and calculated-versus-measured plots.

Known limitations include:

- the numerical data were digitized from plots in NUREG/IA-0025 rather
  than obtained from tabulated data or directly from the original
  experimental publications;
- digitized values are subject to the resolution and readability of the
  published figures and to point-selection uncertainty;
- the stored numerical precision may exceed the meaningful precision of
  the plotted source data;
- some cases provide equilibrium quality while others provide axial
  elevation as the measurement coordinate;
- empty XML elements represent unavailable coordinate data;
- applicability of a selected OpenSTREAM model must be assessed for the
  conditions of each case.

## Citation

When using this dataset implementation:

1. Cite NUREG/IA-0025 as the immediate source of the figures from which the
   numerical values were digitized.
2. Cite the relevant original experimental publication associated with the
   selected cases, where practical.
3. Cite the relevant OpenSTREAM publications and identify the
   OpenSTREAM-database version or commit used in the analysis.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package were independently digitized from
figures published in NUREG/IA-0025. The original report and underlying
experimental publications remain the authoritative sources and should be
cited when the data are used.

This repository does not reproduce the original report figures. The
digitized values are provided with source attribution and documentation of
the extraction method and its limitations.
