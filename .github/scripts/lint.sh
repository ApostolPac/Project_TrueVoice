#!/usr/bin/env bash
set -euo pipefail

set -x

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${NC}=== START golangci-lint CI SCRIPT ===${NC}"

ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo -e "${RED}❌ Конфигурационный файл не найден: $CONFIG${NC}"
  exit 1
fi

cd "$ROOT/services"

MODULE_DIRS=$(find . -mindepth 1 -type f -name "go.mod" -exec dirname {} \;)

if [[ -z "$MODULE_DIRS" ]]; then
  echo -e "${RED}⚠️  Не найден ни один go.mod в services/*${NC}"
  exit 1
fi

all=0
for dir in $MODULE_DIRS; do
  ((all++))
  echo -e "${NC}--- [$all] LINT $dir ---${NC}"
  pushd "$dir" > /dev/null

    echo "→ golangci-lint run --config $CONFIG ./..."
    golangci-lint run --config="$CONFIG" ./...

  popd > /dev/null
  echo -e "${GREEN}✔ $dir OK${NC}"
  echo ""
done

echo -e "${GREEN}🎉 DONE! Всего проверено модулей: $all${NC}"
