#!/usr/bin/env bash
# Remnawave Node — Docker + nano: вставляешь docker-compose.yml из панели, сохраняешь — нода стартует.
# ОС: ориентир Ubuntu / Debian (apt-get). На других дистрибутивах — Docker и curl вручную.
# https://docs.rw/docs/install/remnawave-node/
#
# Панель: Nodes → Management → + → Copy docker-compose.yml → вставить в nano.
#
# Запуск только в интерактивной SSH-сессии (не через «голый» curl|bash без TTY).
#
# Скачать с GitHub:
#   curl -fsSL https://raw.githubusercontent.com/Shivarin/remnanode-installer/main/install.sh -o /root/install-remnanode.sh && chmod +x /root/install-remnanode.sh && sudo /root/install-remnanode.sh

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/remnanode}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

usage() {
  sed 's/^    //' <<EOF
    Использование:
      sudo bash install.sh              # поставит зависимости, откроет nano для вставки compose
      sudo bash install.sh --help

    Переменные окружения:
      INSTALL_DIR   каталог (по умолчанию /opt/remnanode)
      COMPOSE_FILE  имя файла (по умолчанию docker-compose.yml)

    Важно: открой nano, вставь YAML из панели, сохрани: Ctrl+O, Enter, выход: Ctrl+X.
EOF
}

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Запусти от root: sudo bash $0" >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
  echo ""
  echo ">>> Нет интерактивного терминала (TTY)."
  echo "    Скрипт открывает nano — зайди по SSH на сервер и выполни:"
  echo "    curl -fsSL URL/install.sh -o /root/install-remnanode.sh && chmod +x /root/install-remnanode.sh && sudo /root/install-remnanode.sh"
  echo ""
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq nano ca-certificates curl
fi

if ! command -v docker >/dev/null 2>&1; then
  echo ">>> Устанавливаю Docker..."
  curl -fsSL https://get.docker.com | sh
fi

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

if [[ ! -f "${COMPOSE_FILE}" ]]; then
  : > "${COMPOSE_FILE}"
fi

echo ""
echo ">>> Сейчас откроется nano: вставь сюда целиком docker-compose.yml из панели (Copy docker-compose)."
echo "    Сохранить: Ctrl+O, Enter  |  Выйти: Ctrl+X"
echo ""
read -r -p "Нажми Enter чтобы открыть nano..."

nano "${COMPOSE_FILE}"

if [[ ! -s "${COMPOSE_FILE}" ]]; then
  echo "Файл ${INSTALL_DIR}/${COMPOSE_FILE} пустой — остановка." >&2
  exit 1
fi

echo ""
echo ">>> Каталог: ${INSTALL_DIR}"
echo ">>> Запуск контейнера..."
docker compose -f "${COMPOSE_FILE}" pull
docker compose -f "${COMPOSE_FILE}" up -d

echo ""
docker compose -f "${COMPOSE_FILE}" ps
echo ""
echo "Логи: cd ${INSTALL_DIR} && docker compose -f ${COMPOSE_FILE} logs -f -t"
echo "В панели ноды: Next → Config Profile → Create."
echo "Фаервол: NODE_PORT только для IP панели (см. https://docs.rw/docs/install/remnawave-node/)."
