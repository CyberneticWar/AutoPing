# AutoPing — Architecture

> Documentazione prodotto AutoPing (vetrina pubblica).

## Obiettivo

MVP backend asincrono che azzera lo **Speed-to-Lead** delle concessionarie auto: dal webhook Meta Lead Ads a WhatsApp + alert Telegram in **&lt; 3 secondi**.

## Stack

| Layer | Tecnologia |
|-------|------------|
| API | FastAPI (async) + Uvicorn |
| Validation | Pydantic v2 + pydantic-settings |
| HTTP esterno | httpx.AsyncClient |
| WhatsApp | Meta Cloud API (Graph) + PyWa hub |
| Alert staff | Email mirata (Resend/SMTP) + WA staff opzionale |
| Alert legacy Lead Ads | Telegram Bot API (opzionale) |
| Persistence | JSON locale (`data/`) + Supabase (leads / mirror opzionale) |

## Indice moduli

```
app/
  main.py                 # App FastAPI, lifespan (httpx + supabase)
  api/
    deps.py               # Dependency injection
    v1/
      router.py           # Aggrega route v1
      webhooks.py         # GET/POST /api/v1/webhooks/meta
  core/
    config.py             # Settings da env
    exceptions.py         # Errori di dominio
  models/
    enums.py              # LeadStatus
    schemas.py            # Lead, Meta payloads, DealerConfig
  services/
    lead_parser.py        # Estrazione campi lead (locale + Graph opzionale)
    dealers.py            # Multi-tenant: page_id → dealer
    messages.py           # Template testo + lista slot prova guida
    whatsapp.py           # Messaggi Cloud API (testo + interactive)
    whatsapp_inbound.py   # Parse list_reply / button_reply
    telegram.py           # Alert legacy Lead Ads (opzionale)
    logger.py             # Insert/update leads su Supabase
    dispatcher.py         # asyncio.gather WA + TG
    routing.py            # Intent/marca → un destinatario staff
    email.py              # Resend / SMTP
    staff_notify.py       # Alert email (+ WA staff opzionale)
    conversation_store.py # Persistenza richieste hub
    notify_monitor.py     # Log fallimenti invio
  conversation/
    session_store.py      # Sessioni TurnStack su file JSON
  clients/
    http.py               # Factory httpx con timeout stretti
    supabase.py           # Client Supabase + wrapper async
```

API webhook aggiuntiva: `GET/POST /api/v1/webhooks/whatsapp` per scelte fasce orarie.
Conversazione keyword (hub): PyWa su `GET/POST /api/v1/webhooks/pywa` + TurnStack (`app/conversation/`).  
Vedi [`06_Conversation_Tagliando.md`](06_Conversation_Tagliando.md), [`07_Staff_Routing_Draft.md`](07_Staff_Routing_Draft.md), [`08_Hosting_Webhook.md`](08_Hosting_Webhook.md).
## Flusso dati

```
Meta Lead Ads
    │ POST /api/v1/webhooks/meta
    ▼
Webhook Receiver
    │ parse lead (leadgen_id, name, phone, car_model)
    │ resolve dealer (page_id)
    │ INSERT leads status=RECEIVED
    ▼
Dispatcher Engine
    │ asyncio.gather (parallelo)
    ├──► WhatsApp Cloud API  → welcome al cliente
    └──► Telegram Bot API    → alert al venditore
    │
    │ UPDATE leads (WHATSAPP_SENT / ALERT_DISPATCHED / RESPONSE_TIME_MS)
    ▼
HTTP 200 → Meta
```

## Budget latenza &lt; 3s

1. **Parallelismo**: WhatsApp e Telegram partono insieme con `asyncio.gather`; un canale non attende l'altro.
2. **Isolamento errori**: ogni canale ha try/except dedicato (`return_exceptions=True`); un fallimento Telegram non blocca WhatsApp.
3. **Timeout HTTP**: `httpx` con timeout totale ~2.5s per chiamata esterna, così il percorso critico resta sotto 3s.
4. **DB non serializza i messaggi**: l'INSERT `RECEIVED` avviene prima del gather; gli UPDATE di stato dopo. Il logging non mette WA e TG in coda sequenziale.
5. **Nessuna coda pesante nell'MVP**: risposta a Meta dopo il gather (tipicamente &lt;3s). Evoluzione futura: enqueue + 200 immediato se servisse scalare.

## Persistence

DDL eseguibile: [`04_Supabase_Schema.sql`](04_Supabase_Schema.sql) (tabelle `dealers` + `leads`).

Se `SUPABASE_URL` / `SUPABASE_SERVICE_KEY` mancano, [`app/services/logger.py`](../app/services/logger.py) usa un fallback in-memory (dry-run locale).

### Tabella `leads`

| Colonna | Tipo | Note |
|---------|------|------|
| id | uuid PK | generato in app |
| dealer_id | text | riferimento logico a dealers |
| leadgen_id | text | id Meta |
| name | text | |
| phone | text | |
| car_model | text | es. Austral |
| status | text | `RECEIVED`, `WHATSAPP_SENT`, `ALERT_DISPATCHED`, `PARTIAL_FAILURE`, `FAILED` |
| whatsapp_ok | boolean | |
| telegram_ok | boolean | |
| response_time_ms | integer | wall-clock dal RECEIVED al post-gather |
| raw_payload | jsonb | opzionale |
| created_at | timestamptz | default now() |

### Status dopo dispatch

| whatsapp_ok | telegram_ok | status |
|-------------|-------------|--------|
| true | true | `ALERT_DISPATCHED` |
| true | false | `WHATSAPP_SENT` |
| false | true | `PARTIAL_FAILURE` |
| false | false | `FAILED` |

## Fuori scope MVP

UI, Redis/Celery, verifica firma `X-Hub-Signature-256` obbligatoria, multi-lingua, sync CRM, auth dealer.
