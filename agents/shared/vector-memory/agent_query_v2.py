#!/usr/bin/env python3
"""
Enhanced Agent Query Interface - v2
Improved query construction and result ranking
"""

import sys
import json
from vector_memory_service import VectorMemoryService


def enhance_query(query: str, context: dict = None) -> str:
    """
    Enhance query for better retrieval.
    
    Adds domain context and expands query terms.
    """
    # Base enhancement
    enhanced = query.strip()
    
    # Add domain context for project-related queries
    if any(word in enhanced.lower() for word in ['blog', 'dashboard', 'api', 'project', 'scaffold']):
        enhanced = f"{enhanced} project scaffolding template best practices patterns"
    
    # Add context for quality-related queries
    if any(word in enhanced.lower() for word in ['quality', 'gate', 'test', 'validate']):
        enhanced = f"{enhanced} quality equation validation standards requirements"
    
    # Add context for auth-related queries
    if any(word in enhanced.lower() for word in ['auth', 'login', 'user', 'jwt', 'secure']):
        enhanced = f"{enhanced} authentication security patterns implementation"
    
    return enhanced


def rank_results(results: list, original_query: str) -> list:
    """
    Re-rank results based on relevance to query intent.
    
    Boosts results that match the query's semantic intent better.
    """
    query_lower = original_query.lower()
    keywords = query_lower.split()
    
    for result in results:
        content_lower = result.content.lower()
        
        # Calculate keyword overlap bonus
        keyword_matches = sum(1 for kw in keywords if kw in content_lower)
        keyword_bonus = min(keyword_matches * 0.05, 0.15)  # Max 0.15 bonus
        
        # Apply boost
        result.score = result.score + keyword_bonus
    
    # Re-sort by adjusted score
    results.sort(key=lambda x: x.score, reverse=True)
    return results


def search_memory_v2(query: str, top_k: int = 5, min_score: float = 0.15) -> list:
    """
    Enhanced memory search with query enhancement and re-ranking.
    
    Args:
        query: User query
        top_k: Number of results
        min_score: Minimum similarity score
        
    Returns:
        List of SearchResult objects
    """
    service = VectorMemoryService(
        persist_directory='/Users/rohitvashist/.openclaw/vector_memory'
    )
    
    # Enhance the query
    enhanced_query = enhance_query(query)
    
    # Search with enhanced query
    results = service.search(
        enhanced_query,
        top_k=top_k * 2,  # Get more results for re-ranking
        min_score=min_score
    )
    
    # Re-rank based on original query intent
    results = rank_results(results, query)
    
    # Return top_k results
    return results[:top_k]


def format_result(result, index: int) -> str:
    """Format a single result for display."""
    source_name = result.source.split('/')[-1]
    return f"""
{index}. [{result.score:.3f}] {source_name}
   {result.content[:200].strip()}...
"""


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: agent_query_v2.py '<query>'")
        print("Example: agent_query_v2.py 'blog authentication'")
        sys.exit(1)
    
    query = " ".join(sys.argv[1:])
    
    print(f"Query: {query}")
    print(f"Enhanced: {enhance_query(query)}")
    print("-" * 50)
    
    results = search_memory_v2(query, top_k=5)
    
    if results:
        print(f"\nFound {len(results)} relevant results:\n")
        for i, result in enumerate(results, 1):
            print(format_result(result, i))
    else:
        print("\nNo relevant results found.")
