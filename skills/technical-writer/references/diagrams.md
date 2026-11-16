# Mermaid Diagram Guidelines

Mermaid diagrams provide maintainable, text-based visual architecture in Markdown. They render natively in GitLab, GitHub, and docs-as-code documentation engines.

## 1. Core Principles

- Keep diagrams focused: A diagram should answer one architectural or flow question. Do not crowd a single diagram with every database table and helper function.
- Readable direction: Use top-to-bottom (`TD` or `TB`) for hierarchies and component architectures. Use left-to-right (`LR`) for pipelines and timelines.
- Clean node labels: Always use quoted strings inside brackets (e.g., `id["Label Text"]`) to avoid syntax breaks caused by special characters or parentheses.
- Maintainability: Prefer standard Mermaid node shapes (`[...]`, `(...)`, `[(...)]`) over custom CSS styles.

---

## 2. Common Diagram Patterns

### Sequence Diagram (API & Auth Flow)

Use sequence diagrams to show interactions between actors, services, and external APIs over time.

````markdown
```mermaid
sequenceDiagram
    autonumber
    actor Client
    participant Gateway as API Gateway
    participant Auth as Auth Service
    participant DB as User Database

    Client->>Gateway: POST /v1/login (credentials)
    Gateway->>Auth: ValidateCredentials(req)
    Auth->>DB: QueryUser(email)
    DB-->>Auth: UserRecord(hash)
    Auth->>Auth: VerifyPasswordHash()
    alt Valid credentials
        Auth-->>Gateway: JWT Token
        Gateway-->>Client: 200 OK (token)
    else Invalid credentials
        Auth-->>Gateway: Error: Unauthorized
        Gateway-->>Client: 401 Unauthorized
    end
```
````

### Architecture / Component Diagram

Use flowcharts to illustrate component topologies, services, message queues, and databases.

````markdown
```mermaid
flowchart TD
    Client["Web / Mobile Client"]
    LB["Load Balancer (Traefik)"]
    API1["API Worker 1"]
    API2["API Worker 2"]
    Queue[("Redis Job Queue")]
    Worker["Background Worker"]
    DB[("PostgreSQL Primary")]

    Client -->|HTTPS| LB
    LB --> API1
    LB --> API2
    API1 -->|Read / Write| DB
    API2 -->|Read / Write| DB
    API1 -->|Enqueue Task| Queue
    Queue -->|Consume Task| Worker
    Worker -->|Update State| DB
```
````

### State Machine Diagram

Use state diagrams to document lifecycle transitions for tasks, jobs, orders, or connections.

````markdown
```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> PendingReview: Submit
    PendingReview --> ChangesRequested: Request Revision
    ChangesRequested --> PendingReview: Re-submit
    PendingReview --> Approved: Approve
    Approved --> Deployed: Deploy
    Deployed --> [*]

    Draft --> Cancelled: Cancel
    PendingReview --> Cancelled: Cancel
    Cancelled --> [*]
```
````

### Entity Relationship (ER) Diagram

Use ER diagrams to document data models, foreign key relationships, and cardinalities.

````markdown
```mermaid
erDiagram
    ORGANIZATION ||--o{ TEAM : contains
    TEAM ||--o{ USER : includes
    USER ||--o{ MERGE_REQUEST : authors
    MERGE_REQUEST ||--o{ COMMENT : receives

    ORGANIZATION {
        uuid id PK
        string name
        timestamp created_at
    }
    USER {
        uuid id PK
        uuid team_id FK
        string email
        string display_name
    }
    MERGE_REQUEST {
        uuid id PK
        uuid author_id FK
        string title
        string state
    }
```
````

---

## 3. Best Practices Checklist

- Test rendering: Ensure brackets, parentheses, and quotes are balanced.
- Clear naming: Use distinct alphanumeric node identifiers (e.g., `gw`, `db_auth`) separate from the visible label.
- Meaningful edge labels: Label arrows with protocol, method, or payload description (e.g., `-->|gRPC|`, `-->|JSON|`).
