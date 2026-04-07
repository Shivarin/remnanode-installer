# remnanode-installer

Одна команда: ставит **Docker** (если нет), создаёт `/opt/remnanode`, пишет `docker-compose.yml` + `.env`, поднимает [Remnawave Node](https://docs.rw/docs/install/remnawave-node/).

`SECRET_KEY` и `NODE_PORT` берутся из панели: **Nodes → Management → +** → в карточке ноды **Copy docker-compose.yml** (те же значения в `environment`).

## Быстрый старт

После создания репозитория на GitHub замени `USER` и `REPO` на свои:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh | sudo bash -s -- \
  --node-port 2222 \
  --secret-key 'ВСТАВЬ_SECRET_KEY_ИЗ_ПАНЕЛИ'
```

Или локально склонировал репозиторий:

```bash
sudo bash install.sh -p 2222 -k 'SECRET_KEY'
```

Через переменные окружения:

```bash
sudo NODE_PORT=2222 SECRET_KEY='...' bash install.sh
```

Необязательно:

- `INSTALL_DIR` — каталог установки (по умолчанию `/opt/remnanode`)
- `IMAGE` — образ (по умолчанию `remnawave/node:latest`)

## После установки

1. В панели в мастере создания ноды нажми **Next**, выбери **Config Profile** → **Create**.
2. На фаерволе ноды открой **NODE_PORT** **только** для IP сервера с панелью ([документация](https://docs.rw/docs/install/remnawave-node/)).

Логи:

```bash
cd /opt/remnanode && docker compose logs -f -t
```

## Требования

- Linux с **root**, желательно Debian/Ubuntu (скрипт ставит `curl`/`ca-certificates` через `apt-get`). На других дистрибутивах установи Docker и `curl` вручную, затем запусти `install.sh`.

## Нужно ли вручную вставлять YAML?

**Нет.** Скрипт **не открывает** `nano` и не просит вставить целый `docker-compose.yml`. Он сам создаёт минимальный `docker-compose.yml` и `.env` в `/opt/remnanode` и подставляет **`NODE_PORT`** и **`SECRET_KEY`**, которые ты передаёшь в команде (или через переменные окружения). Эти два значения бери из панели: **Copy docker-compose.yml** — там же в `environment` видны `NODE_PORT` и `SECRET_KEY`.

Если панель выдаёт **другой** compose (дополнительные `volumes` и т.д.) — отредактируй файл на сервере после установки: `nano /opt/remnanode/docker-compose.yml`, затем `docker compose up -d`.

## Безопасность

- Файл `.env` создаётся с правами `600`.
- Не публикуй `SECRET_KEY` и не коммить `.env` в git.

## Выложить репозиторий (GitHub или свой сервер)

**GitHub:** создай пустой репозиторий, затем с машины, где лежит `remnanode-installer`:

```bash
cd remnanode-installer
git add install.sh README.md .gitignore
git commit -m "chore: initial remnanode installer"
git branch -M main
git remote add origin https://github.com/USER/remnanode-installer.git
git push -u origin main
```

**Свой bare-репозиторий на VPS** (без GitHub):

```bash
# на сервере
mkdir -p ~/git/remnanode-installer.git && cd ~/git/remnanode-installer.git && git init --bare

# на своём ПК (после commit)
git remote add vps user@ТВОЙ_СЕРВЕР:~/git/remnanode-installer.git
git push -u vps main
```

Потом на сервере ноды одна команда с `curl` по raw-URL из GitHub или с `git clone` по SSH.
