# Sawai1989

The `Sawai1989` package implements disturbance-wave measurements reported
by Sawai et al. (1989) for application and validation studies with
OpenSTREAM.

The experiments investigate hydrodynamic non-equilibrium in boiling
steam-water annular flow. The implemented data support comparison of
measured and calculated disturbance-wave velocity and wave time period in
the heated and downstream unheated sections.

## Experimental source

The authoritative experimental source is:

> T. Sawai, S. Yamauchi, and S. Nakanishi, “Behavior of disturbance waves
> under hydrodynamic non-equilibrium conditions,” *International Journal
> of Multiphase Flow*, Vol. 15, No. 3, pp. 341–356, 1989.

The article reports boiling steam-water experiments at a pressure of
2.95 MPa and examines the development and recovery of disturbance-wave
behavior under hydrodynamic non-equilibrium conditions.

## Experimental configuration

The implemented cases use a vertical stainless-steel tube with an inner
diameter of 4 mm. The modeled channel consists of:

- an upstream heated section with a length of 0.8 m;
- a downstream unheated section with a length of 0.848 m;
- a total modeled length of 1.648 m.

The experiments represented in this package use mass fluxes of 300 and
500 kg/(m²·s). Disturbance-wave measurements are provided at four axial
locations for each case.

## Dataset scope

The package contains eight experimental cases:

```text
A_G300    A_G500
B_G300    B_G500
C_G300    C_G500
D_G300    D_G500
```

The suffix identifies the nominal mass flux in kg/(m²·s). The A–D groups
represent different thermal conditions and outlet qualities.

For each case, the source file contains:

- geometry and operating conditions required to generate OpenSTREAM input
  files;
- measured disturbance-wave velocities;
- measured disturbance-wave time periods;
- axial measurement elevations;
- inlet and outlet thermodynamic quantities;
- heat flux, total power, and axial wall-power distribution;
- dataset identifiers and descriptive test names.

## Source data and units

The source data are stored in:

```text
+Sawai1989/+src/Sawai1989.xml
```

The XML file contains a top-level `dataset` structure with one record for
each experimental case. All numerical values use SI units, except
`WaveTimePeriod`, which is stored in milliseconds as reported and used by
the plotting workflow.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `InletEnthalpy`;
- `Length`, `Area`, `Perimeter`, and `Diameter`;
- `Power`, `WallMesh`, and `WallPower`;
- `HeatFlux`, `MassFlux`, and `InletSubcooling`;
- `OutletEnthalpy` and `Xout`;
- `Elevation`, `WaveVelocity`, and `WaveTimePeriod`;
- `TestName` and `TestID`.

The axial wall-power representation contains two heated intervals followed
by two unheated intervals. The measurement elevations extend downstream of
the heated section into the unheated region.

## Data extraction and processing

The disturbance-wave measurements were not available in tabulated or
machine-readable form. The axial distributions of wave velocity and wave
time period were digitized directly from figures in the original article
using [GRABIT](https://www.mathworks.com/matlabcentral/fileexchange/7173-grabit),
a MATLAB tool for extracting data points from images by calibrating the
plot axes and selecting points interactively.

The extracted values were organized using the OpenSTREAM-database field
conventions. Boundary conditions, geometry, and thermodynamic quantities
were converted or derived as required for the OpenSTREAM representation,
and all numerical values were stored using the unit conventions documented
above.

The digitized values are approximations of the plotted measurements and
may be affected by figure resolution, axis scaling, marker size, line
thickness, and manual point selection. The number of digits stored in the
XML file should not be interpreted as the experimental measurement
precision or as the accuracy of the digitization process.

Any future correction, redigitization, interpolation, reconstruction, or
other processing should be documented here and in the source-data history.

## Package structure

```text
+Sawai1989/
├── +src/
│   └── Sawai1989.xml
├── @Sawai1989/
│   ├── Sawai1989.m
│   └── plotResults.m
└── README.md
```

The `Sawai1989` class inherits from the generic `Dataset` class. Dataset
loading, case selection, OpenSTREAM input generation, solver execution,
and result storage are provided by the generic interface.

The `plotResults` method compares measured and calculated disturbance-wave
velocity and wave time period for FourField solver results. Axial position
is expressed relative to the end of the heated section and normalized by
the tube diameter.

## Usage

Ensure that OpenSTREAM and OpenSTREAM-database are available on the MATLAB
path, then construct a selected case:

```matlab
data = Sawai1989.Sawai1989(<entryID>);
```

Generate the OpenSTREAM input files:

```matlab
inputFilePaths = data.makeInputFiles();
```

Run the FourField solver:

```matlab
results = data.runCase('FourField');
```

Plot the measured and calculated disturbance-wave quantities:

```matlab
data.plotResults('FourField');
```

Consult the corresponding application workflow for the physical models,
numerical settings, case selection, and interpretation of the comparison.

## Calculated-versus-measured comparison

The package supports comparison of:

- measured and calculated disturbance-wave velocity;
- measured and calculated disturbance-wave time period;
- the developing calculated wave time period and its modeled equilibrium
  value.

The comparison is performed along the heated and unheated sections. The
end of the heated section is used as the axial reference location.

## Measurement uncertainty

The original article remains the authoritative source for the experimental
configuration, measurement methods, uncertainties, and interpretation.

Digitization uncertainty is distinct from reported experimental
uncertainty. No additional quantitative digitization uncertainty is
assigned by this implementation unless explicitly documented for a
particular field or case.

## Verification and limitations

OpenSTREAM-database does not currently include an automated test suite for
this package. Verification should include source-data loading, review of
generated OpenSTREAM inputs, representative FourField calculations, and
review of calculated-versus-measured plots.

Known limitations include:

- the wave-velocity and wave-time-period measurements were digitized from
  published figures rather than obtained from tabulated data;
- digitized values are subject to figure readability and point-selection
  uncertainty;
- the stored numerical precision may exceed the meaningful precision of
  the plotted source data;
- the package contains the eight cases currently implemented in the XML
  source file and does not claim to reproduce every result in the article;
- the plotting workflow is specific to FourField solver results;
- measured wave time periods are stored in milliseconds, while
  OpenSTREAM calculates time periods in seconds before plotting them in
  milliseconds;
- applicability of the selected disturbance-wave and annular-flow models
  must be assessed for the conditions of each case;
- a favorable comparison for the implemented cases should not be
  interpreted as general validation outside the conditions examined.

## Citation

When using this dataset implementation:

1. Cite Sawai, Yamauchi, and Nakanishi (1989) as the original experimental
   source.
2. Cite GRABIT when the data-extraction method is relevant to the work.
3. Cite the relevant OpenSTREAM publications.
4. Identify the OpenSTREAM-database version or commit used in the
   analysis.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package were independently digitized from
figures in the published Sawai et al. article using GRABIT. The original
article remains the authoritative source and should be cited when the data
are used.

This repository does not reproduce the original article pages or figures.
The machine-readable values are provided with source attribution and
documentation of the digitization method, OpenSTREAM representation, and
known limitations.
