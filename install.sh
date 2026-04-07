#!/usr/bin/env bash
# Remnawave Node — установка одной командой (Docker + compose).
# Документация: https://docs.rw/docs/install/remnawave-node/
#
# В панели: Nodes → Management → + → скопируй NODE_PORT и SECRET_KEY из «Copy docker-compose».
#
# Примеры:
#   curl -fsSL https://raw.githubusercontent.com/USER/remnanode-installer/main/install.sh | sudo bash -s -- -p 2222 -k 'YOUR_SECRET_KEY'
#   sudo NODE_PORT=2222 SECRET_KEY='...' bash install.sh

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/remnanode}"
IMAGE="${IMAGE:-remnawave/node:latest}"

usage() {
  sed 's/^    //' <<EOF
    Использование:
      sudo bash install.sh --node-port PORT --secret-key KEY
      sudo NODE_PORT=... SECRET_KEY=... bash install.sh

    Переменные окружения (альтернатива флагам):
      NODE_PORT, SECRET_KEY, INSTALL_DIR, IMAGE

    Опции:
      -p, --node-port   Порт API ноды (как в панели)
      -k, --secret-key  SECRET_KEY из панели
      -h, --help        Эта справка
EOF
}

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запусти от root: sudo bash $0" >&2
  exit 1
fi

NODE_PORT="${NODE_PORT:-}"
SECRET_KEY="${SECRET_KEY:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--node-port) NODE_PORT="${2:-}"; shift 2 ;;
    -k|--secret-key) SECRET_KEY="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "${NODE_PORT}" || -z "${SECRET_KEY}" ]]; then
  echo "Ошибка: задай NODE_PORT и SECRET_KEY (панель → Nodes → Copy docker-compose)." >&2
  usage
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq ca-certificates curl
fi

if ! command -v docker >/dev/null 2>&1; then
  echo ">>> Устанавливаю Docker..."
  curl -fsSL https://get.docker.com | sh
fi

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

umask 077
cat > .env <<ENVEOF
NODE_PORT=${NODE_PORT}
SECRET_KEY=${SECRET_KEY}
ENVEOF
chmod 600 .env

cat > docker-compose.yml <<EOF
services:
  remnanode:
    container_name: remnanode
    hostname: remnanode
    image: ${IMAGE}
    restart: always
    network_mode: host
    env_file:
      - .env
EOF

echo ">>> Каталог: ${INSTALL_DIR}"
echo ">>> Запуск контейнера..."
docker compose pull
docker compose up -d

echo ""
docker compose ps
echo ""
echo "Логи: cd ${INSTALL_DIR} && docker compose logs -f -t"
echo "Открой NODE_PORT в файрволе только для IP панели (см. документацию Remnawave)."
