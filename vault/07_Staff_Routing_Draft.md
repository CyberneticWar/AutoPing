# AutoPing — Routing staff (bozza, non in produzione)

> **Stato:** bozza di prodotto. **Non implementato** nel flusso WhatsApp.  
> Telegram non è il canale target per Autostars (non usato in salone).

## Problema

Notificare “tutti i venditori” crea rumore e lead persi. Serve **una richiesta → un destinatario**.

## Principio

Routing per **ruolo** e, sul preventivo, per **marca** (Renault / Dacia / usato). Mai blast CC a tutto il commerciale.

## Livello 1 — Day-1 (consigliato)

| Tipo richiesta | Destinatario |
|----------------|--------------|
| Tagliando | Officina (`officina@…` o 1 contatto dedicata) |
| Prova su strada | Commerciale di default / casella condivisa |
| Operatore | Stesso canale commerciale di default |
| Preventivo (prima della marca) | Commerciale di default |

Casella condivisa tipo `commerciale@autostars.it`: chi la gestisce oggi continua a farlo, senza regole complesse.

## Livello 2 — Per marca (con preventivo Renault / Dacia / usato)

| Scelta cliente | Destinatario |
|----------------|--------------|
| Renault | Referente Renault (1 sola email o WA) |
| Dacia | Referente Dacia |
| Usato | Referente usato |
| Fallback | Commerciale di default |

Esempio config futura (non attivo):

```text
ROUTE_OFFICINA=officina@...
ROUTE_RENAULT=...
ROUTE_DACIA=...
ROUTE_USATO=...
ROUTE_DEFAULT_COMMERCIALE=commerciale@...
```

## Livello 3 — Turno / round-robin (opzionale, dopo)

Solo se servono pari opportunità tra N venditori: calendario “di turno” o rotazione. Non necessario al go-live.

## Canale

- **Email** — traccia, inoltro, stampa; meno push immediato.
- **WhatsApp staff** — richiamo rapido (opzionale).
- MVP previsto: email al ruolo/referente + link `wa.me` al cliente nel corpo messaggio.

## Contenuto alert (bozza)

- Intent (tagliando / prova / preventivo / operatore)
- Marca se presente (Renault / Dacia / usato)
- Targa o fascia oraria
- Numero WhatsApp del cliente
- Timestamp (Europe/Rome)
- Link `https://wa.me/39…` per richiamare

## Cosa non fare

- CC a tutti i venditori
- “Chi vuole se lo prende” senza assegnazione
- Routing basato su LLM

## Relazione col flusso attuale

Oggi il codice può ancora avere hook Telegram: **fuori scope Autostars**.  
Quando si implementerà, sostituire/accoppiare con questo routing email (e opzionale WA staff).

Vedi anche roadmap prodotto in presentazione: [`docs/presentazione-autostars.html`](../docs/presentazione-autostars.html).
