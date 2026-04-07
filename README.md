# remnanode-installer

Одна команда на сервере: ставит **nano**, **curl**, **Docker** (если нет), открывает **`docker-compose.yml`** — ты вставляешь YAML целиком из панели (**Copy docker-compose.yml**), сохраняешь — скрипт делает `docker compose pull && up -d` и поднимает [Remnawave Node](https://docs.rw/docs/install/remnawave-node/).

## Как пользоваться

1. В панели: **Nodes → Management → +** → заполни форму → **Copy docker-compose.yml**.
2. На **чистом VPS** зайди по **SSH** (нужен обычный терминал, не «без TTY»).

```bash
curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh -o /root/install-remnanode.sh
chmod +x /root/install-remnanode.sh
sudo /root/install-remnanode.sh
```

Скрипт откроет **nano** → вставь YAML → **Ctrl+O**, Enter → **Ctrl+X** → нода запустится.

Почему не `curl ... | sudo bash`: pipe **без TTY** — **nano не откроется**. Скачай файл и запусти, как выше.

Локально (если уже склонировал репо):

```bash
sudo bash install.sh
```

## После установки

В карточке ноды в панели: **Next** → выбери **Config Profile** → **Create**.

На фаерволе ноды открой **NODE_PORT** **только** для IP сервера с панелью ([документация](https://docs.rw/docs/install/remnawave-node/)).

Логи:

```bash
cd /opt/remnanode && docker compose logs -f -t
```

## Переменные (редко)

| Переменная   | По умолчанию     |
|-------------|------------------|
| `INSTALL_DIR` | `/opt/remnanode` |
| `COMPOSE_FILE` | `docker-compose.yml` |

## Выложить репозиторий

```bash
cd remnanode-installer
git add install.sh README.md .gitignore .gitattributes
git commit -m "..."
git remote add origin https://github.com/USER/remnanode-installer.git
git branch -M main
git push -u origin main
```

## Безопасность

Не коммить рабочий `docker-compose.yml` с секретами с сервера в git.
