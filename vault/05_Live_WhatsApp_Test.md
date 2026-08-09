# AutoPing — prova live WhatsApp (da zero)

## Idea

- **FROM:** numero di prova Meta (es. `+1 555 670 3500`)
- **TO:** il tuo WhatsApp personale (max 5 numeri in sandbox)
- AutoPing simula un lead con `POST /api/v1/webhooks/meta` (payload normalizzato)
- Con `intent=prova_guida` arriva anche la **lista fasce orarie** da toccare

## Config

```env
WHATSAPP_PHONE_NUMBER_ID=...
WHATSAPP_ACCESS_TOKEN=...   # temporary ~24h in sandbox; System User in prod
DEFAULT_DEALER_NAME=Concessionaria Demo
PROVA_GUIDA_SLOTS=Sabato 10:00|Sabato 15:00|Domenica 11:00|Altro - richiamo
```

```powershell
.\scripts\verify_live_setup.ps1
uvicorn app.main:app --reload --port 8000
```

## Test copy + intent

```powershell
# Preventivo (solo testo)
.\scripts\send_test_lead.ps1 -Phone "+393485720768" -Name "Mario Rossi" -Brand "MarcaA" -CarModel "ModelloX" -Intent "preventivo"

# Prova guida (testo + lista interattiva)
.\scripts\send_test_lead.ps1 -Phone "+393485720768" -Name "Mario Rossi" -Brand "MarcaB" -CarModel "ModelloY" -Intent "prova_guida"
```

Risposta attesa prova guida: `whatsapp_ok: true`, `interactive_slots_sent: true`.

## Webhook risposte WhatsApp (scelta fascia)

- Hub conversazione (preferito): `GET/POST /api/v1/webhooks/pywa`
- Legacy slot Lead Ads: `GET/POST /api/v1/webhooks/whatsapp`
- Verify: stesso `META_VERIFY_TOKEN`

**Produzione:** URL pubblico stabile (`PUBLIC_BASE_URL`) — vedi [`08_Hosting_Webhook.md`](08_Hosting_Webhook.md).  
Tunnel Cloudflare/ngrok solo per sandbox locale.

Test parser locale: inviare un JSON di prova a `POST /whatsapp` (vedi `vault/02_API_Routes.md`).

## Troubleshooting

| Sintomo | Causa |
|---------|--------|
| `(#190)` OAuth | Token scaduto/troncato → Genera + Copia |
| Lista non arriva | intent non `prova_guida` / errore interactive API |
| Tap non arriva ad AutoPing | webhook WA non esposto pubblicamente |
