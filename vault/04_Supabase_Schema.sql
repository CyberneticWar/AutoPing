-- AutoPing MVP schema (run in Supabase SQL editor)

create table if not exists dealers (
  dealer_id text primary key,
  page_id text not null unique,
  brand_label text not null default 'Renault',
  whatsapp_phone_number_id text,
  whatsapp_access_token text,
  telegram_chat_id text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists leads (
  id uuid primary key,
  dealer_id text not null,
  leadgen_id text not null,
  name text,
  phone text,
  car_model text,
  status text not null,
  whatsapp_ok boolean not null default false,
  telegram_ok boolean not null default false,
  response_time_ms integer,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create index if not exists leads_leadgen_id_idx on leads (leadgen_id);
create index if not exists leads_dealer_id_idx on leads (dealer_id);
create index if not exists leads_created_at_idx on leads (created_at desc);
