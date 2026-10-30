# Flujo completo de Transfermóvil (aprobación manual)

## Diagrama de estados

```
PENDING_PAYMENT
      │
      │  Cliente inicia pago → se muestran datos de tarjeta
      ▼
PENDING_PAYMENT (con payment creado)
      │
      │  Cliente sube captura del SMS
      ▼
PENDING_VERIFICATION
      │
      ├── Admin APRUEBA ──► PAID ──► PROCESSING ──► SHIPPED ──► DELIVERED
      │
      └── Admin RECHAZA ──► CANCELLED
```

## Endpoints involucrados

| Método | Ruta | Quién | Descripción |
|--------|------|-------|-------------|
| POST | `/payments/transfermovil/:orderId` | Cliente | Inicia el pago y recibe datos de la tarjeta |
| POST | `/payments/transfermovil/:paymentId/proof` | Cliente | Sube la imagen del comprobante |
| GET | `/payments/pending-verification` | Admin | Lista todos los pagos esperando revisión |
| POST | `/payments/verify/:paymentId` | Admin | Aprueba o rechaza el pago |

## Datos que se muestran al cliente

```json
{
  "paymentId": "clx...",
  "orderNumber": "ORD-2025-0847",
  "method": "TRANSFERMOVIL_CUP",
  "amount": "12500.00",
  "currency": "CUP",
  "cardNumber": "9225XXXXXXXXXXXX",
  "instructions": [
    "1. Abre Transfermóvil y autentícate con BANDEC",
    "2. Ve a Operaciones → Transferencia",
    "3. Transfiere exactamente 12500.00 CUP a la tarjeta: 9225...",
    "4. En la descripción escribe: ORD-2025-0847",
    "5. Guarda el SMS de confirmación",
    "6. Sube una captura del SMS o del comprobante"
  ],
  "expiresAt": "2025-10-31T15:00:00.000Z"
}
```

## Qué revisa el administrador

1. Que el monto de la captura coincida con el del pedido
2. Que la tarjeta de destino sea la correcta
3. Que la fecha/hora sea coherente
4. (Ideal) Que el número de referencia / autorizo aparezca en el estado de cuenta de BANDEC
5. Que la captura no esté editada de forma sospechosa

## Recomendaciones de producción

- Guardar el historial de quién aprobó/rechazó y con qué notas
- Enviar notificación push + email al cliente cuando se apruebe o rechace
- Tener un timeout (ej. 48h) después del cual el pedido se cancela automáticamente si no se verifica
- Limitar el tamaño de las imágenes de comprobante (máx 2-3 MB)
- Usar un antivirus o revisión de malware en las imágenes subidas
