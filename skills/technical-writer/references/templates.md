# Technical Documentation Templates

Use these structural templates when drafting new documentation artifacts. Adjust sections to match project context, but maintain the logical ordering.

---

## 1. Project README Template

```markdown
# <Project Name>

<One to two sentence summary explaining what the project does and the problem it solves.>

## Features

- <Feature 1: outcome-focused description>
- <Feature 2: outcome-focused description>
- <Feature 3: outcome-focused description>

## Prerequisites

- <Dependency / Runtime 1 (e.g., Node.js >= 20.0.0)>
- <Dependency / Runtime 2 (e.g., Docker Engine 24+)>

## Quickstart

Get up and running in under two minutes:

1. Clone and install dependencies:
   ```bash
   git clone <repo-url>
   cd <repo-name>
   make install
   ```

2. Configure environment:
   ```bash
   cp .env.example .env
   ```

3. Start local development:
   ```bash
   make dev
   ```

Visit `http://localhost:<PORT>` to verify the service is running.

## Configuration

| Environment Variable | Description | Default | Required |
|----------------------|-------------|---------|----------|
| `PORT` | Listening port | `8080` | No |
| `DATABASE_URL` | PostgreSQL connection string | - | Yes |

## Architecture Overview

<Brief high-level description or Mermaid diagram showing service components.>

For detailed design decisions, see [Architecture Documentation](docs/architecture/).

## Contributing

1. Create a topic branch: `git checkout -b feature/<name>`
2. Run test suite: `make test`
3. Submit a merge request targeting `main`.
```

---

## 2. Architecture Decision Record (ADR) Template

```markdown
# ADR-<NUMBER>: <Concise Title of Decision>

- Status: <Proposed | Accepted | Superseded | Deprecated>
- Date: <YYYY-MM-DD>
- Deciders: <List of stakeholders / team members>

## Context and Problem Statement

<Describe the context, technical problem, requirements, and constraints driving this decision. What forces are in play?>

## Decision Outcome

Chosen option: <Option Name>, because <primary justification and trade-off acceptance>.

### Positive Consequences

- <Benefit 1>
- <Benefit 2>

### Negative Consequences and Trade-offs

- <Downside or complexity 1>
- <Mitigation for downside 1>

## Alternatives Considered

### Option 1: <Alternative Name>

- Description: <Summary>
- Pros: <Key advantages>
- Cons: <Why it was rejected>

### Option 2: <Alternative Name>

- Description: <Summary>
- Pros: <Key advantages>
- Cons: <Why it was rejected>
```

---

## 3. API Reference Template

```markdown
# <Endpoint Name>

`<METHOD> <PATH>`

<One paragraph describing what this operation accomplishes.>

## Authentication

- Type: `<Bearer Token | API Key | Session>`
- Required scopes: `<scope1>`, `<scope2>`

## Request

### Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Authorization` | string | Yes | Bearer token format |
| `Content-Type` | string | Yes | `application/json` |

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (UUID) | Yes | Unique resource identifier |

### Request Body

```json
{
  "name": "example-service",
  "active": true
}
```

## Response

### Status 200 OK

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "example-service",
  "status": "ready",
  "created_at": "2025-01-01T00:00:00Z"
}
```

### Error Responses

| Status Code | Code | Reason |
|-------------|------|--------|
| `400 Bad Request` | `INVALID_PAYLOAD` | Missing required field |
| `404 Not Found` | `RESOURCE_NOT_FOUND` | ID does not exist |

## Example

```bash
curl -X POST https://api.example.com/v1/resources \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"name": "test"}'
```
```

---

## 4. How-To Guide Template

```markdown
# How to <Accomplish Specific Goal>

<Brief paragraph defining the goal and who this guide is for.>

## Prerequisites

Before starting, ensure you have:
- Access to `<required system or credential>`
- Installed `<required CLI tool version>`

## Step 1: <Action Verb + Specific Task>

<Action description with clear instruction.>

```bash
<command>
```

Expected output:
```text
<sample output verifying success>
```

## Step 2: <Action Verb + Specific Task>

<Action description.>

## Verification

To verify that the procedure succeeded:

1. Run verification command:
   ```bash
   <verification command>
   ```
2. Confirm the state matches: `<expected state description>`.

## Troubleshooting

- **Error: `<Common Error Message>`**:
  - Cause: `<Brief explanation>`
  - Solution: `<Concrete fix command or adjustment>`
```

---

## 5. Operations Runbook Template

```markdown
# Runbook: <Service Name> - <Alert or Issue Name>

- Severity: `<P1-Critical | P2-High | P3-Moderate>`
- Affected Component: `<Component / Service name>`
- Primary Dashboard: `<URL to metrics dashboard>`

## Symptoms

- <Alert condition or error rate threshold>
- <User-facing impact>

## Diagnostic Steps

1. Check service status:
   ```bash
   kubectl get pods -n <namespace> -l app=<app-name>
   ```

2. Inspect error logs:
   ```bash
   kubectl logs -n <namespace> -l app=<app-name> --tail=100 | grep ERROR
   ```

3. Check resource utilization:
   ```bash
   kubectl top pods -n <namespace>
   ```

## Remediation

### Immediate Mitigation

1. Restart failing pods:
   ```bash
   kubectl rollout restart deployment/<deployment-name> -n <namespace>
   ```
2. Verify recovery:
   ```bash
   kubectl rollout status deployment/<deployment-name> -n <namespace>
   ```

### Escalation

If error rate does not drop within 10 minutes:
- Page on-call team lead: `<pager duty alias or rotation>`
- Post incident ticket in: `<incident management channel>`
```

---

## 6. Changelog Template (Keep a Changelog Standard)

```markdown
# Changelog

All notable changes to this project will be documented in this file.
The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]

### Added
- Feature description with context.

### Changed
- Refactored component behavior.

### Fixed
- Fixed bug with link to issue.

## [1.2.0] - 2025-01-15

### Added
- Support for token-based authentication.

### Fixed
- Resolved connection leak under high concurrency.
```
