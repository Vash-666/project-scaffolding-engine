#!/usr/bin/env python3
"""
Agent Query Interface for Vector Memory
Simple function agents can call to search context
"""

import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from vector_memory_service import VectorMemoryService, SearchResult
from typing import List


# Singleton service instance
_service = None


def get_memory_service() -> VectorMemoryService:
    """Get or create vector memory service singleton"""
    global _service
    if _service is None:
        _service = VectorMemoryService(
            persist_directory=os.path.expanduser("~/.openclaw/vector_memory"),
            collection_name="agent_context"
        )
    return _service


def search_memory(
    query: str,
    top_k: int = 5,
    min_score: float = 0.2,
    sources: List[str] = None
) -> List[SearchResult]:
    """
    Search agent memory semantically.
    
    This is the main function agents call to retrieve context.
    
    Args:
        query: Natural language query
        top_k: Number of results (default: 5)
        min_score: Minimum relevance score 0-1 (default: 0.6)
        sources: Filter by source files (optional)
        
    Returns:
        List of SearchResult objects
        
    Example:
        >>> results = search_memory("what was decided about quality gates?")
        >>> for r in results:
        ...     print(f"{r.source}: {r.content[:100]}")
    """
    service = get_memory_service()
    
    # Expand user paths in sources
    if sources:
        sources = [os.path.expanduser(s) for s in sources]
    
    return service.search(query, top_k=top_k, min_score=min_score, sources=sources)


def get_memory_stats() -> dict:
    """Get vector memory statistics"""
    service = get_memory_service()
    return service.get_stats()


# CLI for testing
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: agent_query.py <query>")
        print("Example: agent_query.py 'what is the quality equation'")
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    
    print(f"Searching: {query}\n")
    
    results = search_memory(query, top_k=5)
    
    if not results:
        print("No relevant results found.")
        sys.exit(0)
    
    print(f"Found {len(results)} results:\n")
    
    for i, result in enumerate(results, 1):
        print(f"{i}. [{result.score:.2f}] {result.source}")
        print(f"   {result.content[:300]}...")
        print()
