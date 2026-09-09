# <DatasetName>

`<DatasetName>` implements experimental data from `<Author et al. (Year)>`
for use with OpenSTREAM.

> Replace all text enclosed in angle brackets and remove this instruction
> when completing the README.

## Experimental source

> `<Complete bibliographic reference>`

- **Publication or data link:** <source-url>
- **DOI or identifier:** `<DOI, report number, or other identifier>`
- **Data access:** `<Describe how the original data were obtained>`

The original publication and associated public data remain the authoritative
sources for the experiment, measurements, uncertainties, and interpretation.

## Dataset scope

- **Facility:** `<Facility name and description>`
- **Test section:** `<Geometry and orientation>`
- **Working fluid:** `<Fluid>`
- **Operating conditions:** `<Relevant ranges>`
- **Measured quantities:** `<Implemented quantities>`
- **Implemented cases:** `<Case identifiers or scope>`
- **Excluded information:** `<Cases or quantities not implemented>`

## Source data and units

Source-data files are stored under `+src` and all numerical values use SI
units.

| Quantity | Stored field | SI unit | Original unit | Source location |
|---|---|---|---|---|
| `<Quantity>` | `<Field>` | `<SI unit>` | `<Original unit>` | `<Table, figure, or page>` |

Document any conversion from the original units:

| Quantity | Conversion |
|---|---|
| `<Quantity>` | `<SI value = conversion of original value>` |

## Uncertainty

| Quantity | Reported uncertainty | Source location |
|---|---|---|
| `<Quantity>` | `<Value and unit or percentage>` | `<Table, page, or section>` |

If uncertainty information is unavailable, state this explicitly. Do not
assign uncertainty values that are not supported by the original source.

## Data processing and assumptions

Document any transcription, correction, digitization, interpolation,
filtering, reconstruction, property evaluation, or other processing.

List assumptions used to translate the experiment into an OpenSTREAM case,
including any interpretation of geometry, boundary conditions, heating,
measurement locations, or reported quantities.

## Package structure

```text
+<DatasetName>/
├── +src/
│   └── <DatasetName>.xml
├── @<DatasetName>/
│   └── <DatasetName>.m
└── README.md
```

The dataset-specific class inherits from the generic `Dataset` class. Its
constructor reads and interprets the corresponding XML or JSON source file
when the dataset object is created.

## Usage

Ensure that OpenSTREAM and OpenSTREAM-database are available on the MATLAB
path:

```matlab
addpath('<path-to-openstream>')
addpath('<path-to-openstream-database>')
```

Construct the dataset object:

```matlab
dataset = <DatasetName>.<DatasetName>(<constructor arguments>);
```

Describe how to:

1. select one or more experimental cases;
2. generate the OpenSTREAM input files;
3. run a selected case;
4. compare calculated and measured results.

Add a minimal executable example here.

## Calculated-versus-measured comparison

| Experimental quantity | OpenSTREAM quantity | Comparison definition | SI unit |
|---|---|---|---|
| `<Measured quantity>` | `<Calculated quantity>` | `<Location, time, or averaging definition>` | `<Unit>` |

Document any interpolation, averaging, filtering, alignment, or other
processing used in the comparison.

## Verification

OpenSTREAM-database does not currently include an automated test suite.
Document the reproducible checks performed for this dataset, including:

- loading the source file;
- reviewing SI-unit conversions;
- selecting representative cases;
- reviewing generated OpenSTREAM inputs;
- running representative calculations;
- reviewing calculated-versus-measured comparisons and figures.

Record the OpenSTREAM version or commit and the relevant software and
numerical configuration used during verification.

## Known limitations

Document missing data, unavailable uncertainties, ambiguous information,
simplified geometry, reconstructed conditions, unsupported models, or
other limitations.

## Citation

When using this dataset implementation, cite the original experimental
publication:

> `<Complete bibliographic reference>`

Also cite the relevant OpenSTREAM publications and identify the
OpenSTREAM-database version or commit used.

## Licensing and redistribution

The original OpenSTREAM-database software and documentation are distributed
under the MIT License, as described by the repository root `LICENSE` file.

Experimental data and material derived from third-party publications may
be subject to separate copyright, attribution, licensing, or redistribution
conditions.

- **Original copyright holder:** `<Name or unknown>`
- **Original data license:** `<License or not identified>`
- **Redistribution status:** `<Permitted, restricted, or unclear>`
- **Required attribution:** `<Requirements>`
