#!/usr/bin/env python3
"""
Setup script to initialize the YOUBOOK database schema in Supabase.
"""

import os
from supabase import create_client, Client
from app.core.config import settings

def setup_database():
    """Execute the database schema SQL file."""

    # Initialize Supabase client with service role key for admin operations
    supabase: Client = create_client(
        settings.SUPABASE_URL,
        settings.SUPABASE_SERVICE_ROLE_KEY
    )

    # Read the SQL schema file
    schema_path = os.path.join(os.path.dirname(__file__), 'supabase_schema.sql')
    with open(schema_path, 'r', encoding='utf-8') as f:
        sql_content = f.read()

    # Remove comments and split into individual statements
    statements = []
    current_statement = []

    for line in sql_content.split('\n'):
        line = line.strip()
        if line.startswith('--') or line == '':
            continue
        if line.endswith(';'):
            current_statement.append(line[:-1])  # Remove semicolon
            statements.append(' '.join(current_statement))
            current_statement = []
        else:
            current_statement.append(line)

    print(f"Found {len(statements)} SQL statements to execute")

    # Execute each statement
    for i, statement in enumerate(statements, 1):
        if statement.strip():
            try:
                print(f"Executing statement {i}: {statement[:50]}...")
                result = supabase.rpc('exec_sql', {'sql': statement})
                print(f"Statement {i} executed successfully")
            except Exception as e:
                print(f"Error executing statement {i}: {e}")
                print(f"Statement was: {statement}")

    print("Database setup completed!")

if __name__ == "__main__":
    setup_database()
