#!/usr/bin/env python3
"""
Extract uncommented SQL statements from the schema file for easy execution.
"""

def extract_active_sql():
    """Extract only the uncommented SQL statements."""

    with open('supabase_schema.sql', 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    active_lines = []

    for line in lines:
        stripped = line.strip()
        # Skip comment lines and empty lines
        if stripped.startswith('--') or stripped == '':
            continue
        active_lines.append(line)

    # Join back and clean up
    sql = '\n'.join(active_lines)

    # Write to a new file
    with open('active_schema.sql', 'w', encoding='utf-8') as f:
        f.write(sql)

    print("Active SQL statements extracted to 'active_schema.sql'")
    print("Copy and paste this file's contents into your Supabase SQL Editor")

if __name__ == "__main__":
    extract_active_sql()
