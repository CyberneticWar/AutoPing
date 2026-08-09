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
DEFAULT_DEALER_NAME=Autostars
PROVA_GUIDA_SLOTS=Sabato 10:00|Sabato 15:00|Domenica 11:00|Altro - richiamo
```

```powershell
.\scripts\verify_live_setup.ps1
uvicorn app.main:app --reload --port 8000
```

## Test copy + intent

```powershell
# Preventivo (solo testo)
.\scripts\send_test_lead.ps1 -Phone "+393485720768" -Name "Mario Rossi" -Brand "Renault" -CarModel "Austral" -Intent "preventivo"

# Prova guida (testo + lista interattiva)
.\scripts\send_test_lead.ps1 -Phone "+393485720768" -Name "Mario Rossi" -Brand "Dacia" -CarModel "Duster" -Intent "prova_guida"
```

Risposta attesa prova guida: `whatsapp_ok: true`, `interactive_slots_sent: true`.

## Webhook risposte WhatsApp (scelta fascia)

- Verify: `GET /api/v1/webhooks/whatsapp` (stesso `META_VERIFY_TOKEN`)
- Events: `POST /api/v1/webhooks/whatsapp`

In sandbox locale senza ngrok, Meta non può richiamarti: la lista sul telefono funziona comunque; per ricevere il tap in AutoPing serve URL pubblico (piano successivo).

Test parser locale: inviare un JSON di prova a `POST /whatsapp` (vedi `vault/02_API_Routes.md`).

## Troubleshooting

| Sintomo | Causa |
|---------|--------|
| `(#190)` OAuth | Token scaduto/troncato → Genera + Copia |
| Lista non arriva | intent non `prova_guida` / errore interactive API |
| Tap non arriva ad AutoPing | webhook WA non esposto pubblicamente |
