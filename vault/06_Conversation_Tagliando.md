# AutoPing — Conversazione WhatsApp (hub)

## Obiettivo

Menu keyword + pulsanti (non chatbot AI) per i servizi tipici di salone e officina: **Tagliando**, **Prova su strada**, **Preventivo**.

Stack: **PyWa** + **TurnStack**.

## Menu (ordine)

1. Tagliando  
2. Prova su strada  
3. Preventivo  

Dopo ogni intent → conferma → **menu hub** (*Posso aiutarla con altro?*).

## Flussi

### Tagliando

1. Targa italiana  
2. Auto sostitutiva **gratuita?** Sì/No  
3. Conferma (orari accettazione + “l'officina la ricontatterà”)  
4. Anti-duplicati: 1 pending/targa (72h), max 3/giorno per WA (`data/tagliando_requests.json`)  
5. Notifica staff → **officina** (`ROUTE_OFFICINA`)

### Prova su strada

1. Lista fasce da `PROVA_GUIDA_SLOTS`  
2. Conferma con fascia + sede + richiamo commerciale  
3. Notifica staff → **commerciale default** (`ROUTE_DEFAULT_COMMERCIALE`)

### Preventivo

1. Scelta linea veicolo (es. **marca A / marca B / usato** — configurabile per dealer multi-brand)  
2. Conferma + link promo configurabile (`PREVENTIVO_PROMO_URL`)  
3. Notifica staff → referente linea (`ROUTE_BRAND_A` / `ROUTE_BRAND_B` / `ROUTE_USATO`, fallback commerciale)

### Operatore

Handover testo → notifica **commerciale default**.

## Keywords

| Intent | Env | Esempi |
|--------|-----|--------|
| Tagliando | `TAGLIANDO_KEYWORDS` | tagliando, manutenzione, service… |
| Prova | `PROVA_KEYWORDS` | prova, test drive… |
| Preventivo | `PREVENTIVO_KEYWORDS` | preventivo, quotazione… |
| Menu | `MENU_KEYWORDS` | menu, aiuto, opzioni… |
| Operatore | `OPERATOR_KEYWORDS` | operatore, persona… |

## Fuori orario

Primo messaggio fuori L–V 8–12/14–18 (Europe/Rome) → avviso + menu senza secondo Buongiorno.

## Persistenza e monitoring

- Sessioni conversazione: `data/sessions.json` (sopravvivono al restart)
- Richieste completate: `data/conversation_requests.json`
- Fallimenti WA/email: `data/notify_failures.jsonl` + `/health`
- Admin opzionale: `NOTIFY_ADMIN_EMAIL` su errore notifica

## Limiti MVP

- Nessun calendario CRM di marca / DB per slot officina  
- Nessuno scrape listino modelli  
- Round-robin venditori non attivo  
- Telegram non è il canale staff primario del prodotto

## File

- [`app/conversation/flows/tagliando.py`](../app/conversation/flows/tagliando.py)
- [`app/conversation/router.py`](../app/conversation/router.py)
- [`app/conversation/pywa_app.py`](../app/conversation/pywa_app.py)
- [`app/conversation/session_store.py`](../app/conversation/session_store.py)
- [`app/services/staff_notify.py`](../app/services/staff_notify.py)
- [`app/core/config.py`](../app/core/config.py)
- Routing: [`07_Staff_Routing_Draft.md`](07_Staff_Routing_Draft.md)
- Hosting: [`08_Hosting_Webhook.md`](08_Hosting_Webhook.md)
