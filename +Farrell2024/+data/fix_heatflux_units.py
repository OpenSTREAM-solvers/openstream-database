#!/usr/bin/env python3
"""
Fix heat flux units in Farrell2024.xml from W/m² to kW/m²
"""
import xml.etree.ElementTree as ET

# Read the XML file
xml_file = 'Farrell2024.xml'
tree = ET.parse(xml_file)
root = tree.getroot()

# Convert all HeatFlux values from W/m² to kW/m²
count = 0
for dataset in root.findall('dataset'):
    heat_flux_elem = dataset.find('HeatFlux')
    if heat_flux_elem is not None and heat_flux_elem.text:
        value = int(heat_flux_elem.text)
        if value > 0:  # Only convert non-zero values
            new_value = value // 1000
            heat_flux_elem.text = str(new_value)
            count += 1
            print(f"Updated: {value} W/m² → {new_value} kW/m²")

print(f"\nTotal conversions: {count}")

# Write the updated XML back
tree.write(xml_file, encoding='utf-8', xml_declaration=True)
print(f"Updated {xml_file}")
