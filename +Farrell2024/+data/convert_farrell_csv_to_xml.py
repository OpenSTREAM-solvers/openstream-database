#!/usr/bin/env python3
"""Convert Farrell 2024 CSV film-thickness data into dataset XML."""

import csv
import sys
from pathlib import Path
from xml.etree import ElementTree as ET

FIELD_MAP = {
    "Param Name": "ParamName",
    "Mass Flow [kg/m^2]": "MassFlow",
    "Mass Flux [kg/m^2*s]": "MassFlux",
    "Inlet Enthalpy   [J/kg]": "InletEnthalpy",
    "Inlet Quality": "InletQuality",
    "Heat Flux [kW/m^2]": "HeatFlux",
    "Heater Power [W]": "Power",
    "Pressure [Pa]": "Pressure",
    "Length [m]": "Length",
    "Area [m^2]": "Area",
    "Perimeter [m]": "Perimeter",
    "WallMesh": "WallMesh",
    "WallPower": "WallPower",
    "Fluid": "Fluid",
    "Film Thickness Measured [m]": "MeasuredFilmThickness",
}

DEFAULT_FIELDS = {
    "Fluid": "R245fa",
}


def parse_value(raw):
    value = raw.strip()
    if value == "":
        return None
    try:
        if value.upper() in {"NA", "N/A", "NONE"}:
            return None
        return float(value)
    except ValueError:
        return value


def parse_array(raw):
    value = raw.strip()
    if not value:
        return []
    if value.startswith("[") and value.endswith("]"):
        inner = value[1:-1].strip()
        if not inner:
            return []
        items = inner.split()
        parsed_items = []
        for item in items:
            try:
                num = float(item)
                parsed_items.append(str(int(num)) if num.is_integer() else str(num))
            except ValueError:
                parsed_items.append(item)
        return parsed_items
    return [value]


def pretty_print_xml(elem, level=0):
    indent = "    "
    i = "\n" + level * indent
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + indent
        for child in elem:
            pretty_print_xml(child, level + 1)
        if not child.tail or not child.tail.strip():
            child.tail = i
    if level and (not elem.tail or not elem.tail.strip()):
        elem.tail = i


def clean_param_name(value):
    if value is None:
        return ""
    return value.strip().strip("'\"")


def build_dataset_row(row, index):
    dataset = {
        "TestID": str(index),
    }

    for old_name, new_name in FIELD_MAP.items():
        if old_name not in row:
            continue
        raw_value = row[old_name]
        if new_name == "HeatFlux":
            parsed = parse_value(raw_value)
            dataset[new_name] = str(int(parsed * 1000)) if parsed is not None else "0"
        elif new_name == "ParamName":
            dataset[new_name] = clean_param_name(raw_value)
            dataset["TestName"] = clean_param_name(raw_value)
        elif new_name in {"Perimeter", "WallMesh", "WallPower"}:
            if new_name == "Perimeter":
                dataset[new_name] = ['0.072', '0.024']
            elif new_name == "WallMesh":
                dataset[new_name] = ['0.21', '0.21']
            elif new_name == "WallPower":
                dataset[new_name] = ['1', '1', '0', '0']
        elif new_name == "Length":
            dataset[new_name] = '0.42'
        else:
            parsed = parse_value(raw_value)
            dataset[new_name] = str(parsed) if parsed is not None else ""

    for key, value in DEFAULT_FIELDS.items():
        dataset.setdefault(key, value)

    return dataset


def write_xml(rows, xml_path):
    root = ET.Element("struct")
    for row in rows:
        dataset_elem = ET.SubElement(root, "dataset")
        for key, value in row.items():
            if isinstance(value, list):
                for item in value:
                    child = ET.SubElement(dataset_elem, key)
                    child.text = item
            else:
                child = ET.SubElement(dataset_elem, key)
                child.text = value

    pretty_print_xml(root)
    tree = ET.ElementTree(root)
    tree.write(str(xml_path), encoding="utf-8", xml_declaration=True)


def load_csv(csv_path):
    with open(csv_path, newline="", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)
        rows = list(reader)

    header_row = None
    header_index = None
    for idx, row in enumerate(rows):
        if not row:
            continue
        row0 = row[0].lstrip('\ufeff').strip()
        if row0.startswith("Param Name"):
            header_row = [cell.lstrip('\ufeff').strip() for cell in row]
            header_index = idx
            break

    if header_row is None:
        raise ValueError("Could not find the CSV header row containing 'Param Name'.")

    data_rows = rows[header_index + 1 :]
    dict_rows = [dict(zip(header_row, row)) for row in data_rows if any(cell.strip() for cell in row)]
    return dict_rows


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    script_dir = Path(__file__).parent

    if len(argv) not in {0, 1, 2}:
        print("Usage: python convert_farrell_csv_to_xml.py [<input.csv>] [<output.xml>]")
        sys.exit(1)

    csv_path = Path(argv[0]) if len(argv) >= 1 else script_dir / "PreObsFilmThicknessComparison.csv"
    xml_path = Path(argv[1]) if len(argv) == 2 else script_dir.parent / "+src" / "Farrell2024.xml"

    rows = load_csv(csv_path)
    converted = [build_dataset_row(row, idx + 1) for idx, row in enumerate(rows)]
    write_xml(converted, xml_path)
    print(f"Wrote {len(converted)} dataset entries to {xml_path}")


if __name__ == "__main__":
    main()
