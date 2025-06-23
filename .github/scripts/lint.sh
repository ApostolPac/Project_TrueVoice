#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo -e "${RED}❌ Конфигурационный файл не найден: $CONFIG${NC}"
  exit 1
fi

echo -e "${NC}0_W_0 Запускаем проверку golangci-lint…${NC}"

cd "$ROOT/services"

MODULE_DIRS=$(find . -mindepth 1 -type f -name "go.mod" -exec dirname {} \;)

all=0
for dir in $MODULE_DIRS; do
  ((all++))
  echo -e "${NC}→ Сервис #$all: проверяем $dir${NC}"
  pushd "$dir" > /dev/null

    echo "   — go mod tidy"
    go mod tidy

    echo "   — golangci-lint run --config=$CONFIG"
    golangci-lint run --config="$CONFIG" ./...

  popd > /dev/null
  echo -e "${GREEN}✔ $dir прошёл проверку${NC}"
  echo ""
done

echo -e "${GREEN}🎉 Готово! Всего проверено модулей: $all${NC}"
