# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **course repository** for the "Web Services" course at HOGENT (Hogeschool Gent), Belgium. It contains educational material teaching students how to build REST APIs using NestJS and TypeScript. The course content is served as a static documentation website using Docsify.

**Important Context:**

- This is a **documentation repository**, not an application codebase
- The course is being actively migrated from Koa to NestJS framework
- Chapters marked with `(WIP)` are work in progress or not yet converted
- The companion code repository is at: <https://github.com/HOGENT-frontendweb/webservices-budget>

## Development Commands

Start the documentation server (with live reload):

```bash
pnpm start
# Opens at http://localhost:3000
```

The documentation will automatically reload when you edit markdown files.

## Repository Structure

The repository follows a **numbered chapter structure**:

- `0-intro/` - Course introduction, software requirements, exam assignment
- `1-typescript/` - TypeScript fundamentals
- `2-REST_api_intro/` - REST API introduction and concepts
- `3-REST_api_bouwen/` - Building REST APIs
- `4-5-datalaag/` - Data layer (part 1: Drizzle/ORM, part 2: Relations)
- `6-validatie/` - Validation and error handling
- `7-authenticatie/` - Authentication and authorization (JWT, guards, decorators)
- `8-testing/` - Testing with Jest
- `9-api_docs/` - API documentation (Swagger/OpenAPI)
- `10-cicd/` - CI/CD and deployment

Each chapter contains an `index.md` (or multiple `.md` files) with course content.

## Documentation Technology Stack

- **Docsify**: Static documentation generator
- **Markdown**: Content format (with some custom extensions)
- **Plugins**:
  - Copy-to-clipboard for code blocks
  - Tabs support
  - PlantUML diagrams
  - Mermaid diagrams
  - Custom accordion script
  - Syntax highlighting: JSON, JSX, TypeScript

## Content Guidelines

### When Editing Course Content

1. **Language**: All content is in Dutch (Belgian)

2. **Code Examples**:

   - Use NestJS patterns and conventions
   - Reference the BudgetBackend example app at `/Users/thomasaelbrecht/Development/frontendweb/BudgetBackend`
   - Include numbered code annotations (👈 1, 👈 2, etc.) with explanations below
   - Show progressive code building (first empty class, then methods incrementally)

3. **Framework Migration**:

   - The course is transitioning from Koa to NestJS
   - When converting chapters, ensure all code examples use NestJS patterns:
     - Controllers with decorators (`@Controller`, `@Get`, `@Post`, etc.)
     - Services with dependency injection
     - Guards for authentication/authorization
     - DTOs with class-validator
     - Drizzle ORM (not Prisma)
   - Remove Koa-specific patterns (middleware as functions, `ctx` parameter, etc.)
   - Do NOT include `@nestjs/swagger` decorators unless explicitly working on chapter 10

4. **Security Examples**:

   - Show `plainToInstance` with `excludeExtraneousValues: true` when exposing user data
   - Always use `@Expose()` decorator on public DTO fields
   - Never expose `passwordHash` or sensitive fields in responses

5. **Git References**:
   - Use `chapter-X` branch naming convention
   - Example app branches: `chapter-1`, `chapter-2`, etc.
   - Update git checkout commands when adding new chapters

### Markdown Conventions

- Use dash style for unordered lists (enforced by markdownlint)
- Inline HTML is allowed
- No line length restrictions
- Duplicate headings are allowed
- Code blocks must specify language for syntax highlighting

### Code Fragment Structure

When presenting service classes or complex code:

1. First show the class structure with constructor
2. Then add methods one by one in separate code blocks
3. Use comments like `// ... constructor` or `// ... andere functies` to indicate omitted code
4. This progressive approach helps students follow along step-by-step

## Companion Repositories

- **Example Backend**: <https://github.com/HOGENT-frontendweb/webservices-budget>

  - NestJS REST API with Drizzle ORM
  - Budget tracking application
  - Each chapter has a corresponding branch

- **Example Frontend**: <https://github.com/HOGENT-frontendweb/frontendweb-budget>

  - React frontend consuming the API

- **Local BudgetBackend**: `/Users/thomasaelbrecht/Development/frontendweb/BudgetBackend`
  - Reference this for up-to-date code examples
  - Check implementation details before documenting features

## Linting and Quality Checks

The repository uses GitHub Actions for:

- **Markdown linting** (markdownlint) - config in `.markdownlint.json`
- **Link checking** (lychee) - ignores defined in `.lycheeignore`
- Both run on push/PR to main branch

## Key Educational Patterns

### Chapter Progression

Students build up knowledge incrementally:

1. TypeScript basics
2. REST concepts
3. Building endpoints
4. Database integration
5. Validation
6. Authentication/Authorization
7. Testing
8. Documentation
9. Deployment

### Learning by Doing

- Each chapter has exercises
- Students work on their own exam project throughout the course
- Minimal theory, maximum practice
- Reference implementation provided for each chapter

### Modern Best Practices

- JWT authentication (not sessions)
- DTO validation with class-validator
- Dependency injection
- Guard-based authorization
- Separation of concerns (controllers, services, repositories)
- Type safety with TypeScript
- Testing with Jest

## Important Notes for Claude

- When asked to update chapter content, always check the BudgetBackend project first for the current implementation
- Maintain consistency with the numbered annotation style (👈 1, 👈 2, etc.)
- Keep explanations concise but clear - this is educational material
- When converting old Koa code to NestJS, split large code blocks into smaller progressive steps
- Do not add Swagger decorators outside of chapter 10 (API documentation)
- Use `plainToInstance` pattern when showing how to return user data from services
