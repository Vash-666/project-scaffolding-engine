# ARCH-002: Shared Vector Memory for Agents

**Status:** IN PROGRESS  
**Start Date:** 2026-05-04  
**Target:** Minimum viable vector search for agent context retrieval

---

## Objective

Give agents the ability to **semantically search** existing context and memory instead of only reading entire files at spawn time. This improves decision quality and reduces reliance on @switch for context retrieval.

---

## Scope (v1 - Minimum Viable)

### In Scope
- [ ] Lightweight vector memory layer
- [ ] Semantic search across key context files
- [ ] Read/search only (no agent writes in v1)
- [ ] Integration with @scaffolder and @switch
- [ ] Simple, maintainable implementation

### Out of Scope (v1)
- Agent memory writes
- Complex embedding models
- Real-time updates
- Multi-modal search

---

## Technical Approach

### Option 1: ChromaDB (Recommended)
- **Pros:** Purpose-built, simple API, persistent storage
- **Cons:** Additional dependency
- **Effort:** Medium

### Option 2: Lightweight Custom (SQLite + embeddings)
- **Pros:** No new dependencies, full control
- **Cons:** More implementation work
- **Effort:** Higher

### Decision: ChromaDB
Rationale: Focus on capability, not infrastructure. ChromaDB is lightweight and purpose-built for this use case.

---

## Implementation Plan

### Phase 1: Infrastructure (Day 1)
- [ ] Install and configure ChromaDB
- [ ] Create vector memory service wrapper
- [ ] Design document chunking strategy

### Phase 2: Ingestion (Day 1-2)
- [ ] Chunk key context files (SESSION-CONTEXT.md, MEMORY.md snippets)
- [ ] Generate embeddings (use lightweight model: all-MiniLM-L6-v2)
- [ ] Store in ChromaDB with metadata

### Phase 3: Query Interface (Day 2)
- [ ] Create query function for agents
- [ ] Implement similarity search
- [ ] Return top-k relevant chunks with scores

### Phase 4: Integration (Day 2-3)
- [ ] Integrate into @scaffolder workflow
- [ ] Add to @switch context retrieval
- [ ] Test end-to-end

### Phase 5: Validation (Day 3)
- [ ] Performance testing (<200ms query time)
- [ ] Accuracy testing (relevant results)
- [ ] Documentation

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   @scaffolder   │────▶│  Vector Memory   │────▶│    ChromaDB     │
│   or @switch    │     │   Service        │     │   (embedded)    │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │  all-MiniLM-L6-v2│
                        │  (embeddings)    │
                        └──────────────────┘
```

---

## API Design

### Agent Query Interface

```typescript
// Search memory semantically
searchMemory(query: string, options?: {
  topK?: number;        // default: 5
  minScore?: number;    // default: 0.7
  sources?: string[];   // filter by source files
}): Promise<SearchResult[]>

interface SearchResult {
  content: string;
  source: string;
  score: number;
  timestamp: string;
}
```

### Usage Example

```typescript
// In @scaffolder
const relevantContext = await searchMemory(
  "What was the decision about authentication in blog projects?",
  { topK: 3, sources: ["MEMORY.md", "SESSION-CONTEXT.md"] }
);

// Returns:
// [
//   { content: "Decided to use JWT...", source: "MEMORY.md", score: 0.92 },
//   { content: "Blog projects need auth...", source: "SESSION-CONTEXT.md", score: 0.85 }
// ]
```

---

## Data Sources

### Primary Sources
1. **SESSION-CONTEXT.md** - Current session state
2. **MEMORY.md** - Long-term strategic memory (selected chunks)
3. **AGENTS.md** - System procedures (relevant sections)
4. **USER.md** - User preferences

### Chunking Strategy
- **Size:** 512 tokens per chunk
- **Overlap:** 50 tokens between chunks
- **Metadata:** source file, timestamp, tags

---

## Success Criteria

| Criterion | Target | Measurement |
|-----------|--------|-------------|
| Query latency | <200ms | Average response time |
| Result relevance | >80% top-3 | Human evaluation |
| Coverage | 5 key files | All major context files |
| Stability | 99% uptime | Error rate monitoring |
| Integration | 2 agents | @scaffolder + @switch |

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| ChromaDB dependency | Medium | Lightweight, can swap later |
| Embedding model size | Low | Use all-MiniLM-L6-v2 (~80MB) |
| Query accuracy | Medium | Tune similarity threshold |
| Maintenance burden | Low | Simple API, well-documented |

---

## Timeline

| Day | Focus | Deliverable |
|-----|-------|-------------|
| 1 | Infrastructure | ChromaDB setup, service wrapper |
| 2 | Ingestion + Query | Documents indexed, query working |
| 3 | Integration + Validation | Agents using search, tests pass |

---

## Documentation

- Architecture diagram
- API reference
- Usage examples
- Troubleshooting guide

---

## Next Steps

1. Install ChromaDB
2. Create vector memory service
3. Begin document ingestion
4. Build query interface
5. Integrate with agents

---

**Status:** Planning complete, ready for implementation
