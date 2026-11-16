# Diataxis Documentation Framework

The Diataxis framework (diataxis.fr) organizes documentation into four distinct quadrants based on user needs and tasks:

```
                  PRACTICAL (Action)
                         │
          Tutorials      │    How-To Guides
      (Learning-oriented)│  (Problem-oriented)
                         │
── Acquisition ──────────┼────────── Application ──
                         │
         Explanation     │      Reference
    (Understanding-orient) (Information-oriented)
                         │
                 THEORETICAL (Knowledge)
```

## The Four Quadrants

### 1. Tutorials (Learning-Oriented)
- Goal: Help a beginner learn the system and achieve a meaningful first success.
- Focus: The learning experience, not building a production system.
- Structure: A guided, step-by-step lesson with a predetermined outcome.
- Key principles:
  - Provide a safe, guided sandbox where nothing can go wrong.
  - Do not offer choices, alternatives, or branching paths ("Do X, then do Y").
  - Do not explain technical architecture in depth here; provide just enough to complete the step.
  - Ensure the reader sees tangible results immediately ("Hello World", first successful test).
- Common artifacts: Getting Started tutorial, First API call walkthrough, Beginner workshop.

### 2. How-To Guides (Problem-Oriented)
- Goal: Help a competent user solve a specific, real-world task or achieve a distinct goal.
- Focus: The task and practical completion.
- Structure: Clear prerequisites, sequential action steps, expected result, and troubleshooting.
- Key principles:
  - Assume the reader already understands core concepts and setup.
  - Focus on a specific practical problem ("How to configure Redis caching with TLS").
  - Provide recipes, not theoretical lectures.
  - Omit exploratory discussions; focus on repeatable instructions.
- Common artifacts: Recipes, integration guides, migration guides, deployment runbooks.

### 3. Reference (Information-Oriented)
- Goal: Provide exact, authoritative, and complete technical facts.
- Focus: The machinery itself.
- Structure: Structured, consistent catalogs matching code architecture (APIs, CLI flags, configuration parameters, schemas).
- Key principles:
  - Be dry, precise, unambiguous, and complete.
  - Describe what exists, its type, constraints, defaults, and possible return values.
  - Do not teach or walk through tutorials in reference docs.
  - Keep descriptions synchronized with the actual codebase.
- Common artifacts: API endpoints, CLI reference, configuration schema, data models.

### 4. Explanation (Understanding-Oriented)
- Goal: Clarify concepts, architectural background, design choices, and trade-offs.
- Focus: Understanding the "why".
- Structure: Discursive, conceptual discussion examining context, rationale, and alternatives.
- Key principles:
  - Step back from immediate tasks and code lines.
  - Explain why the system was built this way and what trade-offs were made.
  - Discuss alternative approaches and why they were not chosen.
  - Connect individual components into a coherent mental model.
- Common artifacts: Architecture overview, Architecture Decision Records (ADRs), concept guides.

## The Rule of Quadrant Separation

The most common documentation flaw is mixing quadrants within a single document:
- Do not put tutorial steps into reference documentation.
- Do not turn a how-to guide into an architectural dissertation.
- Do not let tutorials branch into advanced how-to variations.
- Do not omit technical specifications from reference docs to make them "approachable".

When writing or editing, determine the primary quadrant first and link out to other quadrants rather than inlining them.
