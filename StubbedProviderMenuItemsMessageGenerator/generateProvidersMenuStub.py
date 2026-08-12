#!/usr/bin/env python3
"""
Generate ProvidersMenu stub test data.

This script creates binary and text-format ProvidersMenu messages
for testing without a live YAMS server.

Manual protobuf wire format encoding (proto2).
No external dependencies required.
"""

import os
import sys

def encode_varint(value):
    """Encode a varint using protobuf variable-length integer format."""
    parts = []
    while value > 0x7f:
        parts.append((value & 0x7f) | 0x80)
        value >>= 7
    parts.append(value & 0x7f)
    return bytes(parts)

def encode_tag(field_number, wire_type):
    """Encode a protobuf field tag."""
    return encode_varint((field_number << 3) | wire_type)

def encode_string(field_number, value):
    """Encode a string field (wire type 2: length-delimited)."""
    encoded_value = value.encode('utf-8')
    return encode_tag(field_number, 2) + encode_varint(len(encoded_value)) + encoded_value

def encode_enum(field_number, value):
    """Encode an enum field as varint (wire type 0)."""
    return encode_tag(field_number, 0) + encode_varint(value)

def encode_message(field_number, message_bytes):
    """Encode a nested message (wire type 2: length-delimited)."""
    return encode_tag(field_number, 2) + encode_varint(len(message_bytes)) + message_bytes

def create_menu_item(display_text, url):
    """Create a ProviderMenuItem message."""
    # Field 1: display_text (string)
    # Field 2: url (string)
    msg = encode_string(1, display_text)
    msg += encode_string(2, url)
    return msg

def create_subsystem(provider_urn, provider_type, provider_display_name, menu_items):
    """Create a ProviderSubsystemMenu message."""
    # Field 1: provider_urn (string)
    # Field 2: provider_type (enum)
    # Field 3: provider_display_name (string)
    # Field 4: menu_items (repeated ProviderMenuItem)
    msg = encode_string(1, provider_urn)
    msg += encode_enum(2, provider_type)
    msg += encode_string(3, provider_display_name)
    
    for item in menu_items:
        msg += encode_message(4, item)
    
    return msg

def create_providers_menu():
    """Create a ProvidersMenu message with subsystems from external team example."""
    # Enum values for EServiceType
    eMachinePositioning = 1
    eHeightRelative = 2
    eSiteRelative = 3
    
    # Create subsystems based on external team's example data
    subsystems = []
    
    # Subsystem 1: Machine Controls (eMachinePositioning)
    menu_items_1 = [
        create_menu_item("Machine Overview", "https://www.google.com"),
        create_menu_item("Autos Setup", "https://www.google.com"),
        create_menu_item("Autos Optimisation", "https://www.google.com"),
        create_menu_item("Blade Wear", "https://www.google.com"),
        create_menu_item("Steering Control", "https://www.google.com"),
        create_menu_item("Pass Match Adjustment", "https://www.google.com"),
    ]
    subsystem_1 = create_subsystem(
        "urn:providernamespace:machine-controls",
        eMachinePositioning,
        "Machine Controls",
        menu_items_1
    )
    subsystems.append(subsystem_1)
    
    # Subsystem 2: Positioning (eSiteRelative)
    menu_items_2 = [
        create_menu_item("GNSS Overview", "https://www.google.com"),
        create_menu_item("GNSS Correction Source", "https://www.google.com"),
    ]
    subsystem_2 = create_subsystem(
        "urn:providernamespace:positioning",
        eSiteRelative,
        "Positioning",
        menu_items_2
    )
    subsystems.append(subsystem_2)
    
    # Create ProvidersMenu message
    # Field 1: repeated ProviderSubsystemMenu subsystems
    # Field 2: required int32 Age (required by the framework)
    msg = b''
    for subsystem in subsystems:
        msg += encode_message(1, subsystem)
    msg += encode_enum(2, 0)  # Age = 0 (stub value)
    
    return msg

def format_debug_string(binary_data):
    """Format binary protobuf data as human-readable debug string."""
    lines = []
    lines.append("ProvidersMenu {")
    
    # Simple parser to show structure
    pos = 0
    subsystem_num = 0
    
    while pos < len(binary_data):
        tag = binary_data[pos]
        pos += 1
        field_number = tag >> 3
        wire_type = tag & 0x07
        
        if field_number == 1 and wire_type == 2:  # Subsystems (repeated message)
            subsystem_num += 1
            
            # Read length
            length = 0
            shift = 0
            start_pos = pos
            while pos < len(binary_data):
                byte = binary_data[pos]
                pos += 1
                length |= (byte & 0x7f) << shift
                if (byte & 0x80) == 0:
                    break
                shift += 7
            
            subsystem_data = binary_data[pos:pos + length]
            pos += length
            
            lines.append(f"  subsystems {{")
            parse_subsystem(subsystem_data, lines)
            lines.append(f"  }}")
        
        elif field_number == 2 and wire_type == 0:  # Age (int32 varint)
            value = 0
            shift = 0
            while pos < len(binary_data):
                byte = binary_data[pos]
                pos += 1
                value |= (byte & 0x7f) << shift
                if (byte & 0x80) == 0:
                    break
                shift += 7
            lines.append(f"  Age: {value}")
    
    lines.append("}")
    return "\n".join(lines)

def parse_subsystem(data, lines, indent="    "):
    """Parse and format a ProviderSubsystemMenu."""
    # Enum mapping for EServiceType
    enum_names = {
        0: "eUndefined",
        1: "eMachinePositioning",
        2: "eHeightRelative",
        3: "eSiteRelative",
    }
    
    pos = 0
    while pos < len(data):
        tag = data[pos]
        pos += 1
        field_number = tag >> 3
        wire_type = tag & 0x07
        
        if wire_type == 0:  # Varint
            value = 0
            shift = 0
            while pos < len(data):
                byte = data[pos]
                pos += 1
                value |= (byte & 0x7f) << shift
                if (byte & 0x80) == 0:
                    break
                shift += 7
            
            if field_number == 2:  # provider_type
                enum_name = enum_names.get(value, f"UNKNOWN_{value}")
                lines.append(f"{indent}provider_type: {enum_name}")
        
        elif wire_type == 2:  # Length-delimited
            length = 0
            shift = 0
            while pos < len(data):
                byte = data[pos]
                pos += 1
                length |= (byte & 0x7f) << shift
                if (byte & 0x80) == 0:
                    break
                shift += 7
            
            field_data = data[pos:pos + length]
            pos += length
            
            if field_number == 1:  # provider_urn
                lines.append(f"{indent}provider_urn: \"{field_data.decode('utf-8')}\"")
            elif field_number == 3:  # provider_display_name
                lines.append(f"{indent}provider_display_name: \"{field_data.decode('utf-8')}\"")
            elif field_number == 4:  # menu_items
                lines.append(f"{indent}menu_items {{")
                parse_menu_item(field_data, lines, indent + "  ")
                lines.append(f"{indent}}}")

def parse_menu_item(data, lines, indent="      "):
    """Parse and format a ProviderMenuItem."""
    pos = 0
    while pos < len(data):
        tag = data[pos]
        pos += 1
        field_number = tag >> 3
        wire_type = tag & 0x07
        
        if wire_type == 2:  # Length-delimited (string)
            length = 0
            shift = 0
            while pos < len(data):
                byte = data[pos]
                pos += 1
                length |= (byte & 0x7f) << shift
                if (byte & 0x80) == 0:
                    break
                shift += 7
            
            field_data = data[pos:pos + length]
            pos += length
            
            if field_number == 1:  # display_text
                lines.append(f"{indent}display_text: \"{field_data.decode('utf-8')}\"")
            elif field_number == 2:  # url
                lines.append(f"{indent}url: \"{field_data.decode('utf-8')}\"")

def main():
    """Generate stub data files."""
    # Determine output directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, "stub_data")
    
    # Create directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Generate binary data
    binary_data = create_providers_menu()
    
    # Write binary file
    bin_path = os.path.join(output_dir, "providers_menu_stub.bin")
    with open(bin_path, 'wb') as f:
        f.write(binary_data)
    print(f"✓ Generated {bin_path} ({len(binary_data)} bytes)")
    
    # Generate and write text file
    debug_string = format_debug_string(binary_data)
    txt_path = os.path.join(output_dir, "providers_menu_stub.txt")
    with open(txt_path, 'w') as f:
        f.write(debug_string)
    print(f"✓ Generated {txt_path}")

if __name__ == "__main__":
    main()
