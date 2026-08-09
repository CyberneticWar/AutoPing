# AutoPing — API Routes

Base path: `/api/v1`

Implementazione: [`app/api/v1/webhooks.py`](../app/api/v1/webhooks.py).

## Health

### `GET /health`

```json
{ "status": "ok", "service": "autoping" }
```

---

## Meta Webhooks

### `GET /api/v1/webhooks/meta` — Verifica subscription

Query params (Meta hub challenge):

| Param | Descrizione |
|-------|-------------|
| `hub.mode` | Deve essere `subscribe` |
| `hub.verify_token` | Deve coincidere con `META_VERIFY_TOKEN` |
| `hub.challenge` | Stringa da restituire come body plain text |

**Response 200:** body = valore di `hub.challenge` (text/plain)

**Response 403:** token non valido

---

### `POST /api/v1/webhooks/meta` — Nuovo lead

Accetta:

1. **Payload nativo Meta** (`object: page`, `entry[].changes[].field == leadgen`)
2. **Payload normalizzato di test** (dev/local) con campi già espansi

#### Esempio payload Meta (semplificato)

```json
{
  "object": "page",
  "entry": [
    {
      "id": "PAGE_ID_123",
      "time": 1710000000,
      "changes": [
        {
          "field": "leadgen",
          "value": {
            "leadgen_id": "120330000000000001",
            "page_id": "PAGE_ID_123",
            "form_id": "FORM_ID",
            "created_time": 1710000000
          }
        }
      ]
    }
  ]
}
```

Se il webhook non include `field_data`, il servizio arricchisce il lead con:

`GET https://graph.facebook.com/v21.0/{leadgen_id}?access_token=...`

#### Esempio payload normalizzato (test)

```json
{
  "leadgen_id": "test-lead-001",
  "page_id": "PAGE_ID_123",
  "created_time": 1710000000,
  "name": "Mario Rossi",
  "phone_number": "+393331112233",
  "brand": "Dacia",
  "car_model": "Duster",
  "intent": "prova_guida"
}
```

#### Campi estratti

| Campo | Sorgente tipica |
|-------|-----------------|
| `leadgen_id` | `value.leadgen_id` |
| `created_time` | `value.created_time` |
| `name` | field_data / Graph |
| `phone_number` | field_data / Graph |
| `brand` | field_data (`brand`, `marca`) o payload test |
| `car_model` | field_data / payload test |
| `intent` | field_data / payload test (`preventivo`, `prova_guida`) |

#### Response 200

```json
{
  "status": "ok",
  "processed": 1,
  "results": [
    {
      "leadgen_id": "120330000000000001",
      "whatsapp_ok": true,
      "telegram_ok": true,
      "response_time_ms": 842,
      "status": "ALERT_DISPATCHED",
      "interactive_slots_sent": true
    }
  ]
}
```

---

## WhatsApp inbound (scelta fascia prova guida)

### `GET /api/v1/webhooks/whatsapp` — Verifica

Stessi query param hub di Meta; stesso `META_VERIFY_TOKEN`.

### `POST /api/v1/webhooks/whatsapp` — Messaggi / list_reply

Esempio minimo (test locale):

```json
{
  "object": "whatsapp_business_account",
  "entry": [
    {
      "changes": [
        {
          "value": {
            "messages": [
              {
                "from": "393485720768",
                "id": "wamid.test",
                "type": "interactive",
                "interactive": {
                  "type": "list_reply",
                  "list_reply": {
                    "id": "slot_1",
                    "title": "Sabato 15:00"
                  }
                }
              }
            ]
          }
        }
      ]
    }
  ]
}
```

Response:

```json
{
  "status": "ok",
  "processed": 1,
  "telegram_notified": 0,
  "selections": [
    { "from": "393485720768", "slot_id": "slot_1", "title": "Sabato 15:00" }
  ]
}
```

Nota: errori

| Codice | Quando |
|--------|--------|
| 422 | Body non valido / lead incompleto |
| 404 | `page_id` senza dealer configurato |
| 500 | Errore non recuperabile lato server |

Nota: errori su un singolo canale (WA/TG) **non** fanno fallire l'HTTP 200 se il lead è stato accettato e loggato; i flag `whatsapp_ok` / `telegram_ok` riportano l'esito.
