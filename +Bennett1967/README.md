# Bennett1967

The `Bennett1967` package implements post-critical-heat-flux measurements
reported by Bennett et al. (1967) for application, model assessment, and
validation studies with OpenSTREAM.

The experiments investigate heat transfer to steam-water mixtures flowing
upward through uniformly heated vertical tubes after the critical heat flux
has been exceeded. The implemented data support analysis of the onset of the
liquid-deficient region, post-CHF wall-temperature development, thermal
nonequilibrium, and liquid-film dryout.

## Experimental source

The authoritative experimental source is:

> A. W. Bennett, G. F. Hewitt, H. A. Kearsey, and R. K. F. Keeys,
> *Heat Transfer to Steam-Water Mixtures Flowing in Uniformly Heated Tubes
> in Which the Critical Heat Flux Has Been Exceeded*, AERE-R-5373,
> Chemical Engineering and Process Technology Division, Atomic Energy
> Research Establishment, Harwell, United Kingdom, October 1967.

The dataset was prepared from a scanned copy of the AERE report. The report
is retained separately from the machine-readable source data and remains the
authoritative reference for the experiments, measurements, uncertainties,
and interpretation.

## Experimental objective

The principal experimental objectives were to:

- measure axial surface-temperature profiles downstream of the dryout point,
  where liquid ceased to flow on the heated wall;
- investigate the behavior of the interface between wetted-wall and dry-wall
  regions;
- examine how wall-temperature profiles change with heat flux, mass velocity,
  inlet condition, and heated length;
- provide data for the development and assessment of post-CHF heat-transfer
  models.

The report describes a two-step predictive model in which heat is transferred
from the wall to a superheated steam continuum and then from the steam to
entrained water droplets. The experimental dataset in this package is not
restricted to that original model and may be used to assess alternative
OpenSTREAM formulations.

## Experimental facility and test section

The experiments were performed in the Harwell High Pressure Two Phase Heat
Transfer Loop. Water circulated through a preheater and entered the test
section at conditions adjusted to give a nominal test-section outlet pressure
of 1000 psia.

The test section was a vertical, electrically heated Nimonic 80A tube. Nimonic
was selected to withstand the high temperatures in the dry-wall region and to
limit axial heat-flux variation caused by the temperature dependence of
electrical resistivity.

The reported test-section dimensions were:

- internal diameter: 0.497 in, approximately 0.012624 m;
- outside diameter: 0.625 in, approximately 0.015875 m;
- total tube length: 19 ft, approximately 5.7912 m;
- long heated length: 219 in, approximately 5.5626 m;
- short heated length: 144 in, approximately 3.6576 m.

The tube was assembled from two Nimonic sections joined by a flange. The
report states that the flange locally depressed the heat flux over
approximately 1 in, but that the liquid-deficient region was not propagated
upstream of the flange.

## Temperature measurements

Twenty-seven thermocouples were installed along the tube. The first 12 used
chromel-alumel wire with junctions attached through anodized-aluminum
insulators. The upper 15 were sheathed thermocouples selected for the higher
temperatures encountered in the liquid-deficient region.

The thermocouple elevations for the 219 in heated configuration were reported
at axial distances from 2 to 218 in from the start of the full heated length.
The report provides complete wall-temperature tables for both the 219 in and
144 in heated configurations.

The report states that 224 wall-temperature profiles were obtained. The data
show a rapid temperature increase immediately after the onset of the
liquid-deficient region. At lower mass velocities, wall temperature generally
continues to increase downstream. At higher mass velocities, the temperature
can pass through a maximum and then decrease.

## Operating procedure

For a selected pressure, inlet condition, and mass flow rate, power was raised
until the outlet thermocouple showed the rapid temperature increase associated
with the critical heat flux condition. After steady conditions were reached,
wall temperatures and operating quantities were recorded. Power was then
increased progressively so that the dry-wall region moved upstream.

Power was subsequently reduced to move the wetted region downstream. The
report concludes that wall-temperature behavior and the location of the onset
of the critical heat flux condition were essentially reversible, in contrast
to the hysteresis characteristic of pool boiling.

The reported inlet subcooling was generally 20–70 Btu/lb and usually varied by
no more than approximately ±10 Btu/lb within an individual test series. In the
OpenSTREAM-database source, inlet subcooling is represented as an enthalpy
difference in J/kg.

## Implemented quantities

Each XML record can contain:

- fluid, pressure, mass flow rate, and mass flux;
- tube length, flow area, heated perimeter, and diameter;
- inlet enthalpy and inlet temperature;
- inlet subcooling expressed as an enthalpy difference;
- saturation temperature;
- total power and heat flux;
- wall mesh and relative axial wall-power distribution;
- outlet equilibrium quality;
- measured inside-wall temperatures and corresponding axial elevations;
- measured onset-of-CHFC or dryout elevation, when available;
- test name, test group, and test identifier.

The primary measured quantity used for post-CHF comparison is the axial
inside-wall temperature distribution. The onset-of-CHFC elevation is used
where it can be established from the reported measurements.

## Source-data preparation

The numerical values were recovered from the scanned PDF report using
character recognition and organized using the OpenSTREAM-database field
conventions. The recognized values were reviewed and corrected where needed.

Sanity checks were performed to improve the accuracy and consistency of the
implemented records. These checks included, where applicable:

- consistency of geometry and operating-condition fields within each case;
- agreement between mass flow rate, mass flux, and flow area;
- consistency of total power, heat flux, heated perimeter, heated length, and
  the axial wall-power distribution;
- energy-balance checks connecting inlet conditions, applied power, and
  outlet conditions;
- consistency of axial measurement locations with the selected heated length;
- review of temperature values and conversions from degrees Fahrenheit to
  kelvin;
- comparison of repeated and related cases to identify recognition or
  transcription anomalies.

Character recognition and manual correction can still introduce errors. The
scanned AERE report remains the authoritative source. Any future correction,
retranscription, or processing change should be documented here and in the
source-data history.

## Source data and units

The authoritative machine-readable source is:

```text
+Bennett1967/+src/Bennett1967.xml
```

Only the XML source is maintained for this package. All stored numerical
values use SI units, with absolute temperatures expressed in kelvin.

Principal fields include:

- `Fluid`, `Pressure`, `MassFlow`, and `MassFlux`;
- `Length`, `Area`, `Perimeter`, and `Diameter`;
- `Power`, `HeatFlux`, `WallMesh`, and `WallPower`;
- `InletEnthalpy`, `InletTemperature`, and `InletSubcooling`;
- `SaturationTemperature` and `OutletQuality`;
- `Elevation` and `WallTemperature`;
- `ZBO`, `TestName`, `TestGroup`, and `TestID`.

`InletSubcooling` is stored as an enthalpy difference in J/kg, not as a
temperature difference.

`WallMesh` defines the axial wall intervals and `WallPower` gives the
corresponding relative power distribution. The experiments used uniform
heating, and the fields provide the OpenSTREAM wall-input representation of
the selected heated length.

`ZBO` identifies the measured onset-of-CHFC or dryout elevation when it can be
determined from the reported data. An unavailable value is represented as
missing data and must not be interpreted as zero.

## Package structure

```text
+Bennett1967/
├── +src/
│   └── Bennett1967.xml
├── @Bennett1967/
│   ├── Bennett1967.m
│   ├── plotResults.m
│   └── plotTrends.m
└── README.md
```

The `Bennett1967` class inherits from the generic `Dataset` class. Dataset
loading, case selection, OpenSTREAM input generation, solver execution, and
result storage are provided by the generic interface.

The package includes dataset-specific plotting methods for axial result
comparisons and trends across multiple cases.

## Application workflows

The dataset supports two complementary OpenSTREAM applications.

### Post-CHF wall-temperature prediction

The Mixture solver can be used with a thermal-nonequilibrium model to
calculate post-CHF phase and wall temperatures. A typical workflow is:

```matlab
% Load a selected experimental case.
data = Bennett1967.Bennett1967(<entryID>);

% Initialize and configure the OpenSTREAM inputs.
opts = data.inputOptions();
data.makeInputFiles(opts);

% Run the post-CHF calculation.
data.runCase('Mixture');

% Review convergence and compare with the measurements.
data.checkConvergence();
data.plotResults('Mixture',{'temperature'},'Z','K');
```

### Onset-of-CHFC or dryout prediction

The ThreeField solver can be used to calculate liquid-film depletion and
compare the predicted dryout elevation with the reported value:

```matlab
% Load a selected experimental case.
data = Bennett1967.Bennett1967(<entryID>);

% Initialize and configure the annular-flow inputs.
opts = data.inputOptions();
data.makeInputFiles(opts);

% Run the liquid-film calculation.
data.runCase('ThreeField');

% Review convergence and compare dryout elevations.
data.checkConvergence();
data.plotResults('ThreeField',{'doelevation'},'Z','K',true);
```

The exact physical models, numerical options, and interpretation criteria
must be documented for each analysis.

## Plotting and trend analysis

`plotResults` supports axial and case-level comparisons that can include:

- measured and calculated wall temperatures;
- calculated liquid and vapor temperatures;
- equilibrium quality;
- heat-transfer quantities;
- liquid-film distributions;
- measured and predicted onset-of-CHFC or dryout elevations.

Measured wall-temperature smoothing, when applied for visualization, does
not modify the source data stored in the XML file. The original measurement
points should remain visible or otherwise traceable in reported figures.

`plotTrends` supports comparisons across multiple cases, including
wall-temperature or wall-superheat errors and the axial location of maximum
post-CHF temperature. Trend plots should identify the selected cases,
coordinate convention, filtering, and model configuration.

## Experimental findings represented by the dataset

The report identifies the following principal trends:

- wall temperature rises sharply at the onset of the critical heat flux
  condition and then changes more gradually downstream;
- increasing heat flux raises the maximum wall temperature and moves the
  onset location upstream;
- at lower mass velocities, wall temperature tends to increase continuously
  through the liquid-deficient region;
- at higher mass velocities, wall temperature passes through a maximum;
- local wall-temperature behavior and the onset location are approximately
  reversible when power is increased and then decreased;
- the onset location agrees with conventional end-of-channel CHF
  measurements for uniformly heated tubes;
- post-CHF wall-temperature behavior approaches a no-evaporation limit at
  low mass velocity and thermodynamic equilibrium at high mass velocity.

These findings describe the report results and do not by themselves establish
performance of a particular OpenSTREAM model configuration.

## Measurement uncertainty and limitations

The original AERE report remains authoritative for measurement methods,
reported uncertainty, and experimental qualifications.

Important limitations of the implementation include:

- values were obtained by character recognition from a scanned PDF and may
  remain subject to recognition or transcription errors despite the applied
  checks;
- the report states that the onset position could be determined to an
  accuracy of approximately ±1 in for the propagation analysis;
- the thermocouple system could not discriminate the high-frequency wall-
  temperature fluctuations reported in some other experiments;
- some records do not contain an onset-of-CHFC elevation;
- wall-temperature measurements are available only at the implemented axial
  thermocouple locations;
- the geometry is a uniformly heated round tube and does not include rod-
  bundle effects;
- plotted smoothing is a visualization operation and must not be treated as
  additional experimental information;
- post-CHF predictions depend strongly on the selected thermal-nonequilibrium,
  interfacial-transfer, wall-heat-transfer, and dryout models;
- ThreeField predictions depend on the selected onset-of-annular-flow,
  entrainment, deposition, evaporation, friction, and momentum models;
- agreement for the implemented cases should not be interpreted as general
  validation outside the report conditions.

## Verification

OpenSTREAM-database does not currently include an automated test suite for
this package. Verification should include:

- successful loading of every selected XML record;
- comparison of character-recognized values with Tables I and II of the
  scanned report;
- mass-flow, mass-flux, and area consistency checks;
- power and energy-balance checks;
- review of thermocouple elevations against the selected heated length;
- review of generated geometry, boundary-condition, model, and option
  inputs;
- confirmation of solver convergence;
- review of calculated and measured wall-temperature distributions;
- review of measured and predicted onset-of-CHFC elevations;
- sensitivity to the selected physical models and numerical settings;
- confirmation that missing measurements are not interpreted as zeros.

## Citation

When using this dataset implementation:

1. Cite Bennett et al. (1967), AERE-R-5373, as the original experimental
   source.
2. Cite the relevant OpenSTREAM publications.
3. Identify the OpenSTREAM-database version or commit used in the analysis.
4. Report the selected cases, solver, physical-model configuration,
   numerical options, coordinate convention, and convergence status.

## License and data attribution

The OpenSTREAM-database software, documentation, dataset organization, and
processing implementation are distributed under the MIT License, as
described in the repository root `LICENSE` file.

The numerical values in this package were recovered from the scanned Bennett
et al. AERE report using character recognition, followed by manual review,
consistency checks, and energy-balance checks. The original report remains the
authoritative source and should be cited whenever the data are used.

This repository does not reproduce the original report pages or figures. The
machine-readable values are provided with source attribution and
documentation of their extraction, OpenSTREAM representation, verification
checks, and known limitations.
