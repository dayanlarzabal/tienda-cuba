# Tienda Cuba 🇨🇺

E-commerce completo para el mercado cubano.

| Componente | Tecnología |
|------------|------------|
| **App Android** | Flutter 3 |
| **API** | NestJS + Prisma + PostgreSQL |
| **Tienda Web** | Next.js 14 |
| **Panel Admin** | Next.js 14 |
| **Pagos** | Transfermóvil BANDEC (CUP/MLC – aprobación manual) + TRX / USDT TRC20 |
| **CI/CD** | GitHub Actions (genera el APK automáticamente) |

---

## Instalación rápida

```bash
# 1. Entrar en la carpeta del proyecto
cd tienda-cuba

# 2. Ejecutar el instalador
./install.sh
```

El script comprueba dependencias, levanta PostgreSQL + MinIO con Docker, instala paquetes, aplica migraciones y carga datos de prueba.

### Requisitos

| Herramienta | Obligatorio | Notas |
|-------------|-------------|-------|
| Node.js 20+ | Sí | Backend, web y admin |
| Docker + Compose | Recomendado | Base de datos y MinIO |
| Flutter 3.22+ | Para la app | Solo si compilas localmente |
| Git | Sí | Para subir a GitHub |

---

## Arranque manual (sin el script)

### 1. Base de datos

```bash
docker compose up -d
```

### 2. Backend

```bash
cd backend
cp .env.example .env
# Edita .env (tarjetas BANDEC, wallet TRON, JWT_SECRET)
npm install
npx prisma generate
npx prisma migrate dev
npx prisma db seed
npm run start:dev
# → http://localhost:3000/api
```

### 3. Tienda Web

```bash
cd web
npm install
npm run dev
# → http://localhost:3001
```

### 4. Panel Admin

```bash
cd admin
npm install
npm run dev
# → http://localhost:3002
```

### 5. App Android

```bash
cd android
flutter pub get
flutter run
# Generar APK local:
flutter build apk --release
```

---

## Credenciales de prueba (después del seed)

| Rol | Email | Password |
|-----|-------|----------|
| **Admin** | `admin@tiendacuba.cu` | `admin123` |
| **Cliente** | `cliente@ejemplo.cu` | `cliente123` |

---

## Configuración importante (`backend/.env`)

```env
DATABASE_URL="postgresql://tienda:tienda123@localhost:5432/tienda_cuba"

JWT_SECRET="cambia-esto-por-un-secreto-muy-largo-y-aleatorio"

# Tarjetas reales de BANDEC donde recibes los pagos
TRANSFERMOVIL_CUP_CARD="9225XXXXXXXXXXXX"
TRANSFERMOVIL_MLC_CARD="9225XXXXXXXXXXXX"

# Wallet TRON que recibe TRX y USDT-TRC20
TRON_API_KEY="tu-api-key-de-trongrid"
TRON_WALLET_ADDRESS="TXxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

---

## Subir a GitHub y generar el APK

```bash
cd tienda-cuba
git init
git add .
git commit -m "Tienda Cuba - proyecto completo"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/tienda-cuba.git
git push -u origin main
```

1. En GitHub abre la pestaña **Actions**
2. Selecciona el workflow **Build Android APK**
3. Pulsa **Run workflow** (o haz push a `main` / `develop`)
4. Cuando termine, descarga el artefacto **app-release-apk**

El APK queda listo para instalar en cualquier dispositivo Android.

---

## Flujo de pagos

### Transfermóvil BANDEC (CUP / MLC) — aprobación manual

1. El cliente elige Transfermóvil y la moneda.
2. La app muestra el número de tarjeta, el monto y la referencia del pedido.
3. El cliente realiza la transferencia desde Transfermóvil.
4. Sube una captura del SMS/comprobante.
5. El pedido pasa a estado **PENDING_VERIFICATION**.
6. El administrador revisa en el panel y **aprueba** o **rechaza**.
7. Si se aprueba → estado **PAID** y se procesa el pedido.

### TRX / USDT TRC20 — automático

1. El cliente elige crypto.
2. Se muestra la dirección de depósito y el monto exacto.
3. Un worker consulta TronGrid cada 30 segundos.
4. Al detectar la transferencia correcta → estado **PAID** automáticamente.

Documentación detallada: [`docs/flujo-transfermovil.md`](docs/flujo-transfermovil.md)

---

## Estructura del proyecto

```
tienda-cuba/
├── install.sh                 # Script de instalación
├── docker-compose.yml         # PostgreSQL + MinIO
├── README.md
├── LICENSE
├── .gitignore
│
├── backend/                   # API NestJS
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── products/
│   │   │   ├── orders/
│   │   │   ├── payments/     # Transfermóvil + Crypto
│   │   │   └── users/
│   │   └── main.ts
│   └── .env.example
│
├── android/                   # App Flutter
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   ├── checkout_screen.dart
│   │   │   ├── payment_transfermovil_screen.dart
│   │   │   └── payment_crypto_screen.dart
│   │   ├── services/api_service.dart
│   │   └── providers/
│   └── pubspec.yaml
│
├── web/                       # Tienda pública (Next.js)
├── admin/                     # Panel administrativo (Next.js)
├── docs/
│   └── flujo-transfermovil.md
└── .github/workflows/
    └── build-apk.yml          # Genera el APK en cada push
```

---

## Endpoints principales de la API

| Método | Ruta | Descripción |
|--------|------|-------------|
| `POST` | `/api/auth/register` | Registro de usuario |
| `POST` | `/api/auth/login` | Login (devuelve JWT) |
| `GET`  | `/api/products` | Listar productos |
| `POST` | `/api/orders` | Crear pedido |
| `GET`  | `/api/orders/my` | Pedidos del usuario |
| `POST` | `/api/payments/transfermovil/:orderId` | Iniciar pago Transfermóvil |
| `POST` | `/api/payments/transfermovil/:paymentId/proof` | Subir comprobante |
| `POST` | `/api/payments/crypto/:orderId` | Iniciar pago TRX/USDT |
| `GET`  | `/api/payments/pending-verification` | (Admin) Cola de verificación |
| `POST` | `/api/payments/verify/:paymentId` | (Admin) Aprobar / rechazar |

---

## Estados de un pedido

| Estado | Significado |
|--------|-------------|
| `PENDING_PAYMENT` | Esperando que el cliente pague |
| `PENDING_VERIFICATION` | Comprobante Transfermóvil subido, esperando admin |
| `PAID` | Pago confirmado |
| `PROCESSING` | En preparación |
| `SHIPPED` | Enviado |
| `DELIVERED` | Entregado |
| `CANCELLED` | Cancelado |
| `REFUNDED` | Reembolsado |

---

## Licencia

MIT — ver [LICENSE](LICENSE)
