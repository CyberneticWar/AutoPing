# AutoPing — Routing staff (implementato)

> Documentazione prodotto AutoPing (vetrina pubblica).

> **Stato:** attivo nel flusso WhatsApp hub.  
> Telegram non è il canale staff primario del prodotto.

## Principio

Routing per **ruolo** e, sul preventivo, per **linea veicolo**.  
**Una richiesta → un destinatario.** Mai blast CC a tutto il commerciale.

## Livello 1 — Day-1

| Tipo richiesta | Destinatario env |
|----------------|------------------|
| Tagliando | `ROUTE_OFFICINA` |
| Prova su strada | `ROUTE_DEFAULT_COMMERCIALE` |
| Operatore | `ROUTE_DEFAULT_COMMERCIALE` |
| Preventivo (prima della linea) | N/A — il cliente sceglie la linea |

## Livello 2 — Per linea (preventivo)

Esempio multi-brand (i nomi env vanno allineati alla configurazione dealer):

| Scelta cliente | Destinatario env |
|----------------|------------------|
| Marca A | `ROUTE_BRAND_A` (fallback commerciale) |
| Marca B | `ROUTE_BRAND_B` (fallback commerciale) |
| Usato | `ROUTE_USATO` (fallback commerciale) |

Opzionale: stessi ruoli via WhatsApp staff (`ROUTE_*_WA`) se `STAFF_NOTIFY_WA_ENABLED=true`.

## Canale

- **Email** (default): Resend (`RESEND_API_KEY`) oppure SMTP (`SMTP_*`) + `EMAIL_FROM`
- **WhatsApp staff** (opzionale): un solo numero per ruolo
- Corpo alert: intent, linea, targa/fascia, tel cliente, orario Rome, link `wa.me`
- Esempi caselle: `officina@…`, `commerciale@…` (dominio della concessionaria)

## Codice

- [`app/services/routing.py`](../app/services/routing.py)
- [`app/services/staff_notify.py`](../app/services/staff_notify.py)
- [`app/services/email.py`](../app/services/email.py)

## Cosa non fare

- CC a tutti i venditori
- “Chi vuole se lo prende” senza assegnazione
- Routing basato su LLM
- Round-robin (Livello 3) finché non richiesto esplicitamente
