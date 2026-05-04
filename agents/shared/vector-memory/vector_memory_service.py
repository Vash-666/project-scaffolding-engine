#!/usr/bin/env python3
"""
Vector Memory Service - ARCH-002
Shared semantic search for agent context retrieval
"""

import os
import json
import hashlib
from datetime import datetime
from typing import List, Dict, Optional
from dataclasses import dataclass

import chromadb
from chromadb.config import Settings


@dataclass
class SearchResult:
    """Result from vector memory search"""
    content: str
    source: str
    score: float
    timestamp: str
    metadata: Dict


class VectorMemoryService:
    """
    Lightweight vector memory layer for agent context search.
    
    Features:
    - Semantic search across context files
    - Document chunking with overlap
    - Persistent storage via ChromaDB
    - Simple query interface for agents
    """
    
    def __init__(
        self,
        persist_directory: str = ".vector_memory",
        collection_name: str = "agent_context",
        embedding_model: str = "all-MiniLM-L6-v2"
    ):
        """Initialize vector memory service"""
        self.persist_directory = persist_directory
        self.collection_name = collection_name
        self.embedding_model = embedding_model
        
        # Initialize ChromaDB client
        self.client = chromadb.PersistentClient(
            path=persist_directory,
            settings=Settings(
                anonymized_telemetry=False,
                allow_reset=True
            )
        )
        
        # Get or create collection
        self.collection = self.client.get_or_create_collection(
            name=collection_name,
            metadata={"hnsw:space": "cosine"}
        )
        
        print(f"[VectorMemory] Initialized with {self.collection.count()} documents")
    
    def chunk_document(
        self,
        content: str,
        chunk_size: int = 512,
        overlap: int = 50
    ) -> List[str]:
        """Split document into overlapping chunks"""
        words = content.split()
        chunks = []
        
        start = 0
        while start < len(words):
            end = start + chunk_size
            chunk = " ".join(words[start:end])
            chunks.append(chunk)
            start += chunk_size - overlap
        
        return chunks
    
    def add_document(
        self,
        content: str,
        source: str,
        metadata: Optional[Dict] = None,
        chunk_size: int = 512
    ) -> List[str]:
        """
        Add a document to vector memory.
        
        Args:
            content: Document content
            source: Source file path
            metadata: Optional metadata dict
            chunk_size: Tokens per chunk
            
        Returns:
            List of chunk IDs
        """
        # Chunk the document
        chunks = self.chunk_document(content, chunk_size=chunk_size)
        
        # Prepare data for insertion
        ids = []
        documents = []
        metadatas = []
        
        for i, chunk in enumerate(chunks):
            # Generate unique ID
            chunk_hash = hashlib.md5(f"{source}:{i}:{chunk[:100]}".encode()).hexdigest()
            chunk_id = f"{source.replace('/', '_')}_{i}_{chunk_hash[:8]}"
            
            ids.append(chunk_id)
            documents.append(chunk)
            
            # Build metadata
            chunk_metadata = {
                "source": source,
                "chunk_index": i,
                "total_chunks": len(chunks),
                "timestamp": datetime.now().isoformat(),
                **(metadata or {})
            }
            metadatas.append(chunk_metadata)
        
        # Add to collection
        self.collection.add(
            ids=ids,
            documents=documents,
            metadatas=metadatas
        )
        
        print(f"[VectorMemory] Added {len(chunks)} chunks from {source}")
        return ids
    
    def search(
        self,
        query: str,
        top_k: int = 5,
        min_score: float = 0.7,
        sources: Optional[List[str]] = None
    ) -> List[SearchResult]:
        """
        Search vector memory semantically.
        
        Args:
            query: Search query
            top_k: Number of results to return
            min_score: Minimum similarity score (0-1)
            sources: Filter by source files (optional)
            
        Returns:
            List of SearchResult objects
        """
        # Build where clause if sources specified
        where_clause = None
        if sources:
            where_clause = {"source": {"$in": sources}}
        
        # Query collection
        results = self.collection.query(
            query_texts=[query],
            n_results=top_k,
            where=where_clause,
            include=["documents", "metadatas", "distances"]
        )
        
        # Parse results
        search_results = []
        
        if results["documents"] and results["documents"][0]:
            for i, doc in enumerate(results["documents"][0]):
                distance = results["distances"][0][i]
                metadata = results["metadatas"][0][i]
                
                # Convert distance to similarity score (cosine similarity)
                # ChromaDB returns distance, so 1 - distance = similarity
                score = 1 - distance
                
                if score >= min_score:
                    search_results.append(SearchResult(
                        content=doc,
                        source=metadata.get("source", "unknown"),
                        score=score,
                        timestamp=metadata.get("timestamp", ""),
                        metadata=metadata
                    ))
        
        # Sort by score descending
        search_results.sort(key=lambda x: x.score, reverse=True)
        
        print(f"[VectorMemory] Query '{query[:50]}...' returned {len(search_results)} results")
        return search_results
    
    def get_stats(self) -> Dict:
        """Get vector memory statistics"""
        return {
            "total_documents": self.collection.count(),
            "collection_name": self.collection_name,
            "persist_directory": self.persist_directory,
            "embedding_model": self.embedding_model
        }
    
    def clear(self):
        """Clear all documents (use with caution)"""
        self.client.delete_collection(self.collection_name)
        self.collection = self.client.create_collection(
            name=self.collection_name,
            metadata={"hnsw:space": "cosine"}
        )
        print("[VectorMemory] Cleared all documents")


# CLI interface for testing
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: vector_memory_service.py <command> [args]")
        print("Commands:")
        print("  add <file_path>     - Add a document to memory")
        print("  search <query>      - Search memory")
        print("  stats               - Show statistics")
        print("  clear               - Clear all documents")
        sys.exit(1)
    
    command = sys.argv[1]
    service = VectorMemoryService()
    
    if command == "add" and len(sys.argv) >= 3:
        file_path = sys.argv[2]
        with open(file_path, 'r') as f:
            content = f.read()
        service.add_document(content, file_path)
        
    elif command == "search" and len(sys.argv) >= 3:
        query = " ".join(sys.argv[2:])
        results = service.search(query, top_k=5)
        print(f"\nResults for: {query}\n")
        for i, result in enumerate(results, 1):
            print(f"{i}. [{result.score:.2f}] {result.source}")
            print(f"   {result.content[:200]}...\n")
            
    elif command == "stats":
        stats = service.get_stats()
        print(json.dumps(stats, indent=2))
        
    elif command == "clear":
        confirm = input("Clear all documents? (yes/no): ")
        if confirm.lower() == "yes":
            service.clear()
        else:
            print("Cancelled")
    else:
        print("Unknown command or missing arguments")
