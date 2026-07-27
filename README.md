# TaskFlow

A task-tracking REST API built with Spring Boot, backed by Supabase (Postgres + Auth + Storage).

## Status

This is a **learning-in-progress** project. Current step: Step 3 (Spring Boot scaffold + first migration).

## What's here so far

- `pom.xml` — Spring Boot 3.3 project (Web, JPA, Security/OAuth2 resource server, Validation, WebFlux for calling Supabase's REST APIs, Lombok, Testcontainers)
- `src/main/java/com/taskflow/TaskflowApplication.java` — entry point
- `src/main/resources/application.yml` — config, reads Supabase connection details from environment variables (never commit real secrets)
- `supabase/migrations/00000000000001_init_schema.sql` — schema: `projects`, `tasks`, `task_attachments`, all with Row Level Security policies scoping rows to their owner

## Setup you still need to do locally

1. **Initialize the Supabase CLI project** (this repo only has the migrations folder pre-written):
   ```bash
   supabase init
   ```
   This creates `supabase/config.toml` and other scaffolding. Our `supabase/migrations/00000000000001_init_schema.sql` file will already be in place, so the CLI will pick it up.

2. **Link to your hosted Supabase project:**
   ```bash
   supabase login
   supabase link --project-ref <your-project-ref>
   ```
   (Find `<your-project-ref>` in your Supabase project URL: `https://app.supabase.com/project/<project-ref>`)

3. **Push the migration to your hosted database:**
   ```bash
   supabase db push
   ```

4. **Set environment variables** (create a `.env` file locally — it's gitignored — or export them in your shell):
   ```bash
   SUPABASE_DB_URL=jdbc:postgresql://db.<project-ref>.supabase.co:5432/postgres
   SUPABASE_DB_USER=postgres
   SUPABASE_DB_PASSWORD=<your db password>
   SUPABASE_URL=https://<project-ref>.supabase.co
   SUPABASE_ANON_KEY=<your anon key>
   SUPABASE_JWT_SECRET=<your jwt secret>
   ```

5. **Run it:**
   ```bash
   mvn spring-boot:run
   ```

## Next steps (coming up)

- Entities/repositories for `projects` and `tasks`
- Supabase Auth JWT validation wired into Spring Security
- The RLS + JDBC nuance: how to make `auth.uid()` work when Spring Boot connects directly instead of through Supabase's PostgREST layer
- Storage integration for task attachments
- Tests: unit, Testcontainers integration tests, pgTAP database tests
- GitHub Actions CI/CD pipeline
