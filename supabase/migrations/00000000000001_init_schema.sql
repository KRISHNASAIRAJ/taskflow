-- TaskFlow initial schema
-- Tables live in the "public" schema. auth.users is managed by Supabase Auth already.

create extension if not exists "pgcrypto"; -- for gen_random_uuid()

create table public.projects (
    id          uuid primary key default gen_random_uuid(),
    owner_id    uuid not null references auth.users (id) on delete cascade,
    name        text not null check (char_length(name) between 1 and 120),
    created_at  timestamptz not null default now()
);

create table public.tasks (
    id          uuid primary key default gen_random_uuid(),
    project_id  uuid not null references public.projects (id) on delete cascade,
    owner_id    uuid not null references auth.users (id) on delete cascade,
    title       text not null check (char_length(title) between 1 and 200),
    description text,
    status      text not null default 'todo' check (status in ('todo', 'in_progress', 'done')),
    created_at  timestamptz not null default now(),
    updated_at  timestamptz not null default now()
);

create table public.task_attachments (
    id          uuid primary key default gen_random_uuid(),
    task_id     uuid not null references public.tasks (id) on delete cascade,
    owner_id    uuid not null references auth.users (id) on delete cascade,
    file_path   text not null, -- path inside the Supabase Storage bucket
    created_at  timestamptz not null default now()
);

-- keep updated_at fresh
create or replace function public.set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger trg_tasks_updated_at
before update on public.tasks
for each row execute function public.set_updated_at();

-- ============================================================
-- Row Level Security: every table is owner-scoped.
-- auth.uid() reads the current user id out of the request's JWT claims.
-- ============================================================

alter table public.projects enable row level security;
alter table public.tasks enable row level security;
alter table public.task_attachments enable row level security;

create policy "Owners manage their own projects"
    on public.projects
    for all
    using (owner_id = auth.uid())
    with check (owner_id = auth.uid());

create policy "Owners manage their own tasks"
    on public.tasks
    for all
    using (owner_id = auth.uid())
    with check (owner_id = auth.uid());

create policy "Owners manage their own attachments"
    on public.task_attachments
    for all
    using (owner_id = auth.uid())
    with check (owner_id = auth.uid());
