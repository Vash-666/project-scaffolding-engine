#!/usr/bin/env python3
"""
Vector Memory Metrics Tracker
Track usage, scores, and performance over time
"""

import json
import os
from datetime import datetime
from typing import Dict, List, Optional
from dataclasses import dataclass, asdict


@dataclass
class QueryMetric:
    """Single query metric record"""
    timestamp: str
    query: str
    enhanced_query: str
    num_results: int
    top_score: float
    avg_score: float
    latency_ms: float
    cache_hit: bool
    success: bool
    error: Optional[str] = None


class MetricsTracker:
    """Track Vector Memory usage and performance metrics"""
    
    def __init__(self, metrics_file: str = ".vector_memory/metrics.json"):
        self.metrics_file = os.path.expanduser(f"~/.openclaw/{metrics_file}")
        self.metrics: List[Dict] = []
        self._load_metrics()
    
    def _load_metrics(self):
        """Load existing metrics from file"""
        if os.path.exists(self.metrics_file):
            try:
                with open(self.metrics_file, 'r') as f:
                    self.metrics = json.load(f)
            except (json.JSONDecodeError, IOError):
                self.metrics = []
    
    def _save_metrics(self):
        """Save metrics to file"""
        os.makedirs(os.path.dirname(self.metrics_file), exist_ok=True)
        with open(self.metrics_file, 'w') as f:
            json.dump(self.metrics, f, indent=2)
    
    def record_query(
        self,
        query: str,
        enhanced_query: str,
        num_results: int,
        scores: List[float],
        latency_ms: float,
        cache_hit: bool = False,
        success: bool = True,
        error: Optional[str] = None
    ):
        """Record a query metric"""
        metric = QueryMetric(
            timestamp=datetime.now().isoformat(),
            query=query,
            enhanced_query=enhanced_query,
            num_results=num_results,
            top_score=scores[0] if scores else 0.0,
            avg_score=sum(scores) / len(scores) if scores else 0.0,
            latency_ms=latency_ms,
            cache_hit=cache_hit,
            success=success,
            error=error
        )
        
        self.metrics.append(asdict(metric))
        
        # Keep only last 1000 metrics to prevent file bloat
        if len(self.metrics) > 1000:
            self.metrics = self.metrics[-1000:]
        
        self._save_metrics()
    
    def get_summary(self, last_n: int = 100) -> Dict:
        """Get summary statistics for recent queries"""
        recent = self.metrics[-last_n:] if len(self.metrics) > last_n else self.metrics
        
        if not recent:
            return {
                "total_queries": 0,
                "avg_top_score": 0.0,
                "avg_latency_ms": 0.0,
                "success_rate": 0.0,
                "cache_hit_rate": 0.0
            }
        
        successful = [m for m in recent if m.get('success', True)]
        cache_hits = [m for m in recent if m.get('cache_hit', False)]
        
        return {
            "total_queries": len(recent),
            "avg_top_score": sum(m['top_score'] for m in recent) / len(recent),
            "avg_latency_ms": sum(m['latency_ms'] for m in recent) / len(recent),
            "success_rate": len(successful) / len(recent) * 100,
            "cache_hit_rate": len(cache_hits) / len(recent) * 100 if recent else 0,
            "score_distribution": {
                "<0.20": len([m for m in recent if m['top_score'] < 0.20]),
                "0.20-0.30": len([m for m in recent if 0.20 <= m['top_score'] < 0.30]),
                "0.30-0.40": len([m for m in recent if 0.30 <= m['top_score'] < 0.40]),
                ">=0.40": len([m for m in recent if m['top_score'] >= 0.40])
            }
        }
    
    def export_report(self) -> str:
        """Generate a human-readable metrics report"""
        summary = self.get_summary(last_n=100)
        
        report = f"""
Vector Memory Metrics Report
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

Summary (Last 100 Queries)
--------------------------
Total Queries: {summary['total_queries']}
Success Rate: {summary['success_rate']:.1f}%
Cache Hit Rate: {summary['cache_hit_rate']:.1f}%

Retrieval Quality
-----------------
Average Top Score: {summary['avg_top_score']:.3f}
Average Latency: {summary['avg_latency_ms']:.1f}ms

Score Distribution
------------------
"""
        for range_name, count in summary['score_distribution'].items():
            bar = '█' * (count // 2)
            report += f"  {range_name:10} : {bar} ({count})\n"
        
        return report


# Singleton instance for global access
_tracker_instance = None

def get_tracker() -> MetricsTracker:
    """Get or create global metrics tracker"""
    global _tracker_instance
    if _tracker_instance is None:
        _tracker_instance = MetricsTracker()
    return _tracker_instance


if __name__ == "__main__":
    import sys
    
    tracker = get_tracker()
    
    if len(sys.argv) > 1 and sys.argv[1] == "report":
        print(tracker.export_report())
    else:
        summary = tracker.get_summary()
        print(json.dumps(summary, indent=2))
