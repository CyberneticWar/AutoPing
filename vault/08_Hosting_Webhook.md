# AutoPing — Hosting stabile e webhook fisso

> Documentazione prodotto AutoPing (vetrina pubblica).

## Obiettivo

Sostituire tunnel temporanei (es. Cloudflare trycloudflare) con un **URL pubblico stabile** e configurare Meta una sola volta.

## Endpoint webhook hub

| Uso | Path |
|-----|------|
| Conversazione PyWa (hub WhatsApp) | `GET/POST /api/v1/webhooks/pywa` |
| Lead Ads (legacy speed-to-lead) | `GET/POST /api/v1/webhooks/meta` |
| Slot Lead Ads | `GET/POST /api/v1/webhooks/whatsapp` |

Verify token: `META_VERIFY_TOKEN`.

## Env

```env
PUBLIC_BASE_URL=https://autoping.example.com
WEBHOOK_PUBLIC_PATH=/api/v1/webhooks/pywa
```

URL completo esposto anche da `GET /health` → `webhook_public_url`.

## Checklist Meta

1. Deploy su host fisso (VPS, Railway, Fly, Render, …) con HTTPS.
2. In Meta Developer → WhatsApp → Configuration → Webhook Callback URL =  
   `{PUBLIC_BASE_URL}/api/v1/webhooks/pywa`
3. Verify token = stesso valore di `META_VERIFY_TOKEN`.
4. Sottoscrivere `messages`.
5. WABA collegata all’app; token **System User** permanente (non token utente Graph Explorer).
6. Quando è pronto il **numero WhatsApp Business** della concessionaria, aggiornare:
   - `WHATSAPP_PHONE_NUMBER_ID`
   - `WHATSAPP_ACCESS_TOKEN` (stesso System User, asset sul nuovo numero)
   - `WHATSAPP_BUSINESS_DISPLAY_NUMBER` (etichetta ops, es. `+39…`)

## Dev locale

Tunnel ok per test; in produzione usare solo `PUBLIC_BASE_URL` stabile.  
Dopo ogni cambio URL: aggiornare la console Meta (altrimenti inbound muore in silenzio).

## Health

`GET /health` riporta:

- `webhook_public_url`
- `staff_email_configured`
- `whatsapp_business_display_number`
- `notify_failure_count` / `recent_notify_failures`
