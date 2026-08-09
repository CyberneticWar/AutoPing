# AutoPing

Hub WhatsApp per **concessionarie auto**: un canale unico per **tagliando**, **prova su strada** e **preventivo**, con flussi guidati in tono formale (**Lei**).

Il cliente sceglie un percorso chiaro. Lo staff riceve **una richiesta → un destinatario** (ruolo / marca). Niente chatbot LLM generico, niente blast a tutto il commerciale.

Questo repository è la **vetrina pubblica** di prodotto: presentazione e documentazione. Il codice applicativo resta fuori dal repo.

## Presentazione

Apri in browser (schermo intero consigliato):

**[Presentazione AutoPing](docs/presentazione-autoping.html)**

Navigazione: frecce o spazio · clic sinistra/destra · Esc torna all’inizio.

## A chi è rivolto

Concessionarie e saloni che vogliono gestire su WhatsApp le richieste operative più frequenti — officina, prova guida, preventivo — con routing interno ordinato e copy controllato.

## Cosa fa

| Percorso | Cosa raccoglie | Chi viene avvisato |
|----------|----------------|--------------------|
| **Tagliando** | Targa, auto sostitutiva, conferma | Officina |
| **Prova su strada** | Fascia oraria, conferma | Commerciale |
| **Preventivo** | Linea veicolo (es. marca A / marca B / usato), conferma | Referente di linea |

Dopo ogni richiesta il menu hub ripropone: *Posso aiutarla con altro?*

## Principi prodotto

- **Flussi guidati** — menu e pulsanti, non un assistente che improvvisa.
- **Tono formale (Lei)** — copy professionale, coerente con il salone.
- **Routing mirato** — una richiesta, un destinatario; mai CC a tutti i venditori.
- **Staff via email** (WhatsApp staff opzionale) — Telegram non è il canale primario per lo staff.
- **Niente chatbot LLM** — percorsi e messaggi sono controllati.
- **Pronto per produzione** — hosting con URL stabile, webhook Meta fisso, persistenza sessioni e monitoraggio fallimenti.

## Documentazione (vault)

| Documento | Contenuto |
|-----------|-----------|
| [06 · Conversazione](vault/06_Conversation_Tagliando.md) | Hub menu e flussi |
| [07 · Routing staff](vault/07_Staff_Routing_Draft.md) | Email/WA mirati — una richiesta → un destinatario |
| [08 · Hosting / webhook](vault/08_Hosting_Webhook.md) | URL pubblico stabile + Meta webhook |
| [01 · Architecture](vault/01_Architecture.md) | Architettura di riferimento |
| [03 · Dealer config](vault/03_Dealer_Config.md) | Multi-tenant / template |
| [05 · Live WhatsApp test](vault/05_Live_WhatsApp_Test.md) | Setup sandbox Meta |

## Capacità (overview)

- Routing staff per ruolo e, sul preventivo, per linea veicolo
- Sessioni e richieste persistenti + monitoraggio fallimenti di notifica
- Preventivo con scelta linea e copy di conferma configurabile
- Hosting: `PUBLIC_BASE_URL` e webhook Meta fisso
- Numero WhatsApp Business: Phone Number ID e token System User in produzione

---

© AutoPing — hub WhatsApp per concessionarie
