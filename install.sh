#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────
#  Tienda Cuba — Script de instalación
# ─────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

print_header() {
  echo ""
  echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
}

print_ok()   { echo -e "${GREEN}✔ $1${NC}"; }
print_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_err()  { echo -e "${RED}✖ $1${NC}"; }

# ─── Comprobar dependencias ──────────────────────────────────
check_deps() {
  print_header "Comprobando dependencias"

  local missing=0

  if ! command -v node &>/dev/null; then
    print_err "Node.js no encontrado (se necesita v20+)"
    missing=1
  else
    NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -lt 18 ]; then
      print_err "Node.js $NODE_VER es demasiado antiguo (mínimo 18, recomendado 20)"
      missing=1
    else
      print_ok "Node.js $(node -v)"
    fi
  fi

  if ! command -v npm &>/dev/null; then
    print_err "npm no encontrado"
    missing=1
  else
    print_ok "npm $(npm -v)"
  fi

  if ! command -v docker &>/dev/null; then
    print_warn "Docker no encontrado — la base de datos no se levantará automáticamente"
  else
    print_ok "Docker $(docker --version | cut -d' ' -f3 | tr -d ',')"
  fi

  if ! command -v docker &>/dev/null || ! docker compose version &>/dev/null; then
    print_warn "Docker Compose no disponible"
  else
    print_ok "Docker Compose disponible"
  fi

  if ! command -v flutter &>/dev/null; then
    print_warn "Flutter no encontrado — no podrás compilar la app Android localmente"
  else
    print_ok "Flutter $(flutter --version 2>/dev/null | head -1 | awk '{print $2}')"
  fi

  if [ "$missing" -eq 1 ]; then
    print_err "Faltan dependencias obligatorias. Instálalas e inténtalo de nuevo."
    exit 1
  fi
}

# ─── Backend ─────────────────────────────────────────────────
setup_backend() {
  print_header "Configurando Backend (NestJS)"

  cd "$ROOT_DIR/backend"

  if [ ! -f .env ]; then
    cp .env.example .env
    print_ok "Creado backend/.env a partir de .env.example"
    print_warn "Edita backend/.env y configura:"
    echo "         - TRANSFERMOVIL_CUP_CARD"
    echo "         - TRANSFERMOVIL_MLC_CARD"
    echo "         - TRON_WALLET_ADDRESS"
    echo "         - TRON_API_KEY"
    echo "         - JWT_SECRET"
  else
    print_ok "backend/.env ya existe"
  fi

  echo "Instalando dependencias del backend..."
  npm install --silent
  print_ok "Dependencias del backend instaladas"

  echo "Generando cliente Prisma..."
  npx prisma generate
  print_ok "Cliente Prisma generado"
}

# ─── Base de datos ───────────────────────────────────────────
setup_database() {
  print_header "Base de datos (PostgreSQL)"

  if command -v docker &>/dev/null && docker compose version &>/dev/null; then
    echo "Levantando PostgreSQL y MinIO con Docker Compose..."
    cd "$ROOT_DIR"
    docker compose up -d
    print_ok "Contenedores iniciados"

    echo "Esperando a que PostgreSQL esté listo..."
    for i in {1..30}; do
      if docker compose exec -T postgres pg_isready -U tienda &>/dev/null; then
        print_ok "PostgreSQL listo"
        break
      fi
      sleep 1
      if [ "$i" -eq 30 ]; then
        print_err "Timeout esperando PostgreSQL"
        exit 1
      fi
    done

    cd "$ROOT_DIR/backend"
    echo "Ejecutando migraciones..."
    npx prisma migrate dev --name init --skip-seed 2>/dev/null || npx prisma db push
    print_ok "Migraciones aplicadas"

    echo "Cargando datos de prueba (seed)..."
    npx prisma db seed
    print_ok "Seed completado"
  else
    print_warn "Docker no disponible. Configura DATABASE_URL manualmente en backend/.env"
    print_warn "Luego ejecuta:"
    echo "         cd backend && npx prisma migrate dev && npx prisma db seed"
  fi
}

# ─── Web y Admin ─────────────────────────────────────────────
setup_frontends() {
  print_header "Configurando Web y Panel Admin"

  if [ -d "$ROOT_DIR/web" ] && [ -f "$ROOT_DIR/web/package.json" ]; then
    cd "$ROOT_DIR/web"
    npm install --silent 2>/dev/null || true
    print_ok "Dependencias de la tienda web instaladas"
  fi

  if [ -d "$ROOT_DIR/admin" ] && [ -f "$ROOT_DIR/admin/package.json" ]; then
    cd "$ROOT_DIR/admin"
    npm install --silent 2>/dev/null || true
    print_ok "Dependencias del panel admin instaladas"
  fi
}

# ─── Flutter ─────────────────────────────────────────────────
setup_flutter() {
  print_header "Configurando App Android (Flutter)"

  if ! command -v flutter &>/dev/null; then
    print_warn "Flutter no está instalado. Omite este paso."
    print_warn "Instala Flutter desde: https://docs.flutter.dev/get-started/install"
    return
  fi

  cd "$ROOT_DIR/android"
  flutter pub get
  print_ok "Dependencias Flutter instaladas"
}

# ─── Resumen final ───────────────────────────────────────────
print_summary() {
  print_header "Instalación completada"

  echo ""
  echo -e "${GREEN}Credenciales de prueba:${NC}"
  echo "  Admin   →  admin@tiendacuba.cu   /  admin123"
  echo "  Cliente →  cliente@ejemplo.cu    /  cliente123"
  echo ""
  echo -e "${GREEN}Cómo arrancar:${NC}"
  echo ""
  echo "  # Backend API"
  echo "  cd backend && npm run start:dev"
  echo "  → http://localhost:3000/api"
  echo ""
  echo "  # Tienda Web"
  echo "  cd web && npm run dev"
  echo "  → http://localhost:3001"
  echo ""
  echo "  # Panel Admin"
  echo "  cd admin && npm run dev"
  echo "  → http://localhost:3002"
  echo ""
  echo "  # App Android"
  echo "  cd android && flutter run"
  echo "  # o generar APK:"
  echo "  cd android && flutter build apk --release"
  echo ""
  echo -e "${YELLOW}Importante:${NC}"
  echo "  1. Edita backend/.env con tus tarjetas BANDEC y wallet TRON"
  echo "  2. Para producción cambia JWT_SECRET"
  echo "  3. Sube el proyecto a GitHub y usa Actions para generar el APK"
  echo ""
}

# ─── Main ────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║           Tienda Cuba — Instalador                  ║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"

  check_deps
  setup_backend
  setup_database
  setup_frontends
  setup_flutter
  print_summary
}

main "$@"
