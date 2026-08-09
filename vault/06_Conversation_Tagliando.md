# AutoPing — Conversazione WhatsApp (hub Autostars)

## Obiettivo

Menu keyword + pulsanti (non chatbot AI), allineato ai servizi del [sito Autostars](https://www.auto-stars.it/servizi): **Tagliando**, **Prova su strada**, **Preventivo**.

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
3. Conferma (senza placeholder intestatario)  
4. Anti-duplicati: 1 pending/targa (72h), max 3/giorno per WA  
5. Notifica staff — **bozza:** routing officina (vedi [`07_Staff_Routing_Draft.md`](07_Staff_Routing_Draft.md)); non in flusso email oggi  

### Prova su strada

1. Lista fasce da `PROVA_GUIDA_SLOTS`  
2. Conferma con fascia + open/closed  
3. Notifica staff — **bozza:** commerciale di default ([`07`](07_Staff_Routing_Draft.md))  

### Preventivo

1. Oggi: sola conferma + link promo `https://www.auto-stars.it/promoauto`  
2. **Roadmap:** 1 domanda **Renault / Dacia / usato**, poi conferma + link  
3. Notifica staff — **bozza:** referente per marca ([`07`](07_Staff_Routing_Draft.md)); **niente blast a tutti i venditori**

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

## Limiti MVP

- Nessun calendario Renault/DB per slot officina  
- Nessuno scrape listino modelli  
- Registro anti-abuso locale `data/tagliando_requests.json`  
- Sessioni in-memory  
- **Email / routing staff:** solo documentato in bozza — **non nel flusso runtime**  
- Telegram non è il canale operativo per Autostars (non usato in salone)

## File

- [`app/conversation/flows/tagliando.py`](../app/conversation/flows/tagliando.py)
- [`app/conversation/router.py`](../app/conversation/router.py)
- [`app/conversation/pywa_app.py`](../app/conversation/pywa_app.py)
- [`app/core/config.py`](../app/core/config.py)
