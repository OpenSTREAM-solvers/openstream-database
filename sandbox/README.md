# OpenSTREAM-database sandbox

This folder provides a local workspace for exploratory calculations using
OpenSTREAM-database.

The sandbox can be used to:

- create and run temporary OpenSTREAM application cases;
- experiment with dataset selections and model configurations;
- test lightweight in-memory `Dataset` workflows;
- inspect generated OpenSTREAM inputs and results;
- develop ideas before moving them to a maintained dataset, project, or
  test.

Files created in this folder are not part of the maintained
OpenSTREAM-database content. User-created scripts, generated input files,
calculation results, figures, logs, and saved MATLAB objects should not be
committed to the repository.

Reusable work should be moved to the appropriate maintained location:

- curated experimental data and dataset-specific methods belong in a
  dataset package;
- publication companion workflows belong in `projects`;
- automated verification belongs in `tests`;
- general user guidance belongs in the documentation.

Files named `*_default.m`, when provided, are starting templates. Copy and
rename a template before modifying it.