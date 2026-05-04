#!/usr/bin/env python3
"""
Ingest context files into vector memory
Run this to update agent searchable memory
"""

import os
import sys
from pathlib import Path

from vector_memory_service import VectorMemoryService


# Files to ingest for agent context
CONTEXT_FILES = [
    "~/.openclaw/workspace/AGENTS.md",
    "~/.openclaw/workspace/SOUL.md",
    "~/.openclaw/workspace/USER.md",
    "~/.openclaw/workspace/MEMORY.md",
    "~/.openclaw/workspace/SESSION-CONTEXT.md",
]


def ingest_file(service: VectorMemoryService, file_path: str):
    """Ingest a single file into vector memory"""
    # Expand path
    expanded_path = os.path.expanduser(file_path)
    
    if not os.path.exists(expanded_path):
        print(f"[Ingest] Skipping (not found): {file_path}")
        return
    
    try:
        with open(expanded_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Skip if empty
        if not content.strip():
            print(f"[Ingest] Skipping (empty): {file_path}")
            return
        
        # Add to vector memory
        service.add_document(
            content=content,
            source=file_path,
            metadata={
                "type": "context_file",
                "size_bytes": len(content)
            }
        )
        print(f"[Ingest] ✓ Added: {file_path}")
        
    except Exception as e:
        print(f"[Ingest] ✗ Failed: {file_path} - {e}")


def main():
    """Main ingestion routine"""
    print("=" * 60)
    print("Vector Memory Ingestion")
    print("=" * 60)
    print()
    
    # Initialize service
    service = VectorMemoryService(
        persist_directory=os.path.expanduser("~/.openclaw/vector_memory"),
        collection_name="agent_context"
    )
    
    # Show initial stats
    stats = service.get_stats()
    print(f"Initial state: {stats['total_documents']} documents")
    print()
    
    # Ingest each file
    for file_path in CONTEXT_FILES:
        ingest_file(service, file_path)
    
    # Show final stats
    print()
    stats = service.get_stats()
    print("=" * 60)
    print(f"Ingestion complete: {stats['total_documents']} total documents")
    print("=" * 60)


if __name__ == "__main__":
    main()
