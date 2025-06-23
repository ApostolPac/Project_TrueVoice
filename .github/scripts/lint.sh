#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'


cd "$(dirname "$0")/../services"


ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo -e "${RED}Конфиг не найден: $CONFIG${NC}"
  exit 1
fi

echo -e "${NC}0_W_0 Проверка кода...${NC}"

MODULE_DIRS=$(find . -mindepth 1 -type f -name "go.mod" -exec dirname {} \;)

all=0
for d in $MODULE_DIRS; do
  ((all++))
  echo -e "${NC}→ lint $d${NC}"
  pushd "$d" > /dev/null
    golangci-lint run --config="$CONFIG" ./...
  popd  > /dev/null
  echo -e "${GREEN}✔ $d OK${NC}"
done

echo -e "${GREEN}Все $all модуля(ей) прошли проверку!${NC}"
