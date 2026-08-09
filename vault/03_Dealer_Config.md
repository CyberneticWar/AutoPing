# AutoPing — Dealer Config (Multi-tenant)

## Pattern

Ogni concessionaria è un **tenant** identificato da:

- `dealer_id` — chiave interna (slug, es. `autostars-lario`)
- `page_id` — Facebook Page ID collegata alle Lead Ads

Il webhook risolve il tenant così:

```
page_id (dal payload Meta) → DealerConfig → canali WA/TG + template + slot
```

**Autostars:** vendono Renault, Dacia e usato di altre marche. Il messaggio usa `{brand}` + `{car_model}` dal lead (non hardcodare solo Renault). `dealer_name` resta **Autostars**.

## Schema `dealers` (Supabase)

| Colonna | Tipo | Note |
|---------|------|------|
| dealer_id | text PK | slug univoco |
| page_id | text UNIQUE | Facebook Page ID |
| brand_label | text | fallback brand veicolo se assente sul lead |
| dealer_name | text | es. Autostars |
| whatsapp_phone_number_id | text | Phone Number ID Cloud API |
| whatsapp_access_token | text | token WA (o eredita env globale) |
| telegram_chat_id | text | chat/gruppo venditore di turno |
| whatsapp_*_template | text | opzionale, override copy |
| prova_guida_slots | text | pipe-separated fasce |
| is_active | boolean | default true |
| created_at | timestamptz | |

## Implementazione

Lookup: [`app/services/dealers.py`](../app/services/dealers.py) → `get_dealer_by_page_id`.  
Template engine: [`app/services/messages.py`](../app/services/messages.py).

## Fallback MVP

Default dealer da env (`DEFAULT_DEALER_*`, template, `PROVA_GUIDA_SLOTS`).

## Template messaggi (tono professionale / Lei)

Placeholder: `{name}`, `{brand}`, `{car_model}`, `{phone_number}`, `{intent}`, `{dealer_name}`.

**Intent → WhatsApp**

| intent | Template |
|--------|----------|
| (vuoto) | welcome |
| `preventivo` | preventivo |
| `prova_guida` | prova guida + **lista interattiva** fasce orarie |

**Telegram (venditore):** alert lead +, su tap fascia, alert “SCELTA PROVA GUIDA”.

## Slot prova guida

```env
PROVA_GUIDA_SLOTS=Sabato 10:00|Sabato 15:00|Domenica 11:00|Altro - richiamo
```

Inbound: `POST /api/v1/webhooks/whatsapp` (list_reply / button_reply).

## Isolamento

- Nessun lead di un `page_id` va ai canali di un altro dealer.
- Token WA per-dealer sovrascrivono il globale.
