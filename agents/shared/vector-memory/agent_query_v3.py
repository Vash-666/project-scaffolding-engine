#!/usr/bin/env python3
"""
Production-Ready Agent Query Interface - v3
Metrics tracking, better error handling, improved reliability
"""

import sys
import time
import traceback
from typing import List, Optional, Tuple

from vector_memory_service import VectorMemoryService, SearchResult
from metrics_tracker import get_tracker


class VectorMemoryClient:
    """Production-ready Vector Memory client with metrics and fallbacks"""
    
    def __init__(self, persist_directory: str = "/Users/rohitvashist/.openclaw/vector_memory"):
        self.persist_directory = persist_directory
        self.service: Optional[VectorMemoryService] = None
        self.tracker = get_tracker()
        self._init_service()
    
    def _init_service(self) -> bool:
        """Initialize vector memory service with fallback"""
        try:
            self.service = VectorMemoryService(persist_directory=self.persist_directory)
            return True
        except Exception as e:
            print(f"[VectorMemory] Warning: Could not initialize service: {e}", file=sys.stderr)
            self.service = None
            return False
    
    def enhance_query(self, query: str, context: dict = None) -> str:
        """Enhance query for better retrieval with error handling"""
        if not query or not query.strip():
            return "project scaffolding"
        
        enhanced = query.strip()
        
        # Domain context mapping
        domain_terms = {
            'blog': 'blog content management markdown posts',
            'dashboard': 'dashboard admin data visualization charts',
            'api': 'API service REST endpoints routes middleware',
            'auth': 'authentication jwt security login',
            'database': 'database prisma models schema migrations'
        }
        
        # Add relevant domain terms
        for keyword, terms in domain_terms.items():
            if keyword in enhanced.lower():
                enhanced = f"{enhanced} {terms}"
        
        # Always add scaffolding context
        if 'scaffold' not in enhanced.lower():
            enhanced = f"{enhanced} project scaffolding best practices patterns"
        
        return enhanced
    
    def search(
        self,
        query: str,
        top_k: int = 5,
        min_score: float = 0.15,
        track_metrics: bool = True
    ) -> Tuple[List[SearchResult], dict]:
        """
        Search vector memory with metrics tracking and error handling.
        
        Returns:
            Tuple of (results, metadata)
        """
        start_time = time.time()
        metadata = {
            "success": False,
            "fallback_used": False,
            "error": None,
            "latency_ms": 0,
            "query": query,
            "enhanced_query": ""
        }
        
        try:
            # Enhance query
            enhanced_query = self.enhance_query(query)
            metadata["enhanced_query"] = enhanced_query
            
            # Check if service is available
            if self.service is None:
                if not self._init_service():
                    metadata["fallback_used"] = True
                    metadata["error"] = "Vector memory service unavailable"
                    return [], metadata
            
            # Perform search
            results = self.service.search(
                enhanced_query,
                top_k=top_k,
                min_score=min_score
            )
            
            # Calculate latency
            latency_ms = (time.time() - start_time) * 1000
            metadata["latency_ms"] = latency_ms
            metadata["success"] = True
            
            # Track metrics
            if track_metrics:
                scores = [r.score for r in results]
                self.tracker.record_query(
                    query=query,
                    enhanced_query=enhanced_query,
                    num_results=len(results),
                    scores=scores if scores else [0.0],
                    latency_ms=latency_ms,
                    cache_hit=False,  # TODO: Implement caching
                    success=True
                )
            
            return results, metadata
            
        except Exception as e:
            latency_ms = (time.time() - start_time) * 1000
            metadata["latency_ms"] = latency_ms
            metadata["error"] = str(e)
            
            # Track failed query
            if track_metrics:
                self.tracker.record_query(
                    query=query,
                    enhanced_query=metadata.get("enhanced_query", query),
                    num_results=0,
                    scores=[0.0],
                    latency_ms=latency_ms,
                    success=False,
                    error=str(e)
                )
            
            print(f"[VectorMemory] Search failed: {e}", file=sys.stderr)
            return [], metadata
    
    def get_stats(self) -> dict:
        """Get combined service and metrics stats"""
        try:
            if self.service:
                service_stats = self.service.get_stats()
            else:
                service_stats = {"error": "Service not initialized"}
            
            metrics_summary = self.tracker.get_summary(last_n=50)
            
            return {
                "service": service_stats,
                "metrics": metrics_summary,
                "healthy": metrics_summary.get('success_rate', 0) > 90
            }
        except Exception as e:
            return {"error": str(e), "healthy": False}


def search_with_fallback(query: str, top_k: int = 5) -> List[SearchResult]:
    """
    Convenience function for searching with automatic fallback.
    
    If vector memory fails, returns empty list (graceful degradation).
    """
    client = VectorMemoryClient()
    results, metadata = client.search(query, top_k=top_k)
    
    if not metadata["success"]:
        print(f"[Warning] Vector Memory query failed: {metadata.get('error')}")
        print("[Info] Continuing without enhanced context...")
    
    return results


def format_result(result: SearchResult, index: int) -> str:
    """Format a single result for display"""
    source_name = result.source.split('/')[-1] if result.source else "unknown"
    content_preview = result.content[:200].strip().replace('\n', ' ')
    return f"""
{index}. [{result.score:.3f}] {source_name}
   {content_preview}...
"""


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: agent_query_v3.py '<query>' [--stats]")
        print("Example: agent_query_v3.py 'blog authentication'")
        sys.exit(1)
    
    if sys.argv[1] == "--stats":
        client = VectorMemoryClient()
        stats = client.get_stats()
        import json
        print(json.dumps(stats, indent=2))
        sys.exit(0)
    
    query = " ".join(sys.argv[1:])
    
    print(f"Query: {query}")
    print("-" * 50)
    
    client = VectorMemoryClient()
    results, metadata = client.search(query, top_k=5)
    
    print(f"Enhanced: {metadata.get('enhanced_query', query)}")
    print(f"Latency: {metadata.get('latency_ms', 0):.1f}ms")
    print(f"Success: {'✅' if metadata['success'] else '❌'}")
    if metadata.get('fallback_used'):
        print("Note: Using fallback mode")
    print("-" * 50)
    
    if results:
        print(f"\nFound {len(results)} relevant results:\n")
        for i, result in enumerate(results, 1):
            print(format_result(result, i))
    else:
        print("\nNo relevant results found.")
        if metadata.get('error'):
            print(f"Error: {metadata['error']}")
