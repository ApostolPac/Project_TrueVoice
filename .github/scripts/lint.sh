#!/usr/bin/env bash
set -euo pipefail
set -x

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo -e "${RED}❌ Конфигурационный файл не найден: $CONFIG${NC}"
  exit 1
fi

cd "$ROOT/services"

MODULE_DIRS=$(find . -mindepth 1 -type f -name "go.mod" -exec dirname {} \;)

if [[ -z "$MODULE_DIRS" ]]; then
  echo -e "${RED}⚠️  В services/* не найдено ни одного go.mod${NC}"
  exit 1
fi

count=0
for dir in $MODULE_DIRS; do
  ((count++))
  echo -e "${NC}--- [$count] SERVICE: $dir ---${NC}"
  pushd "$dir" > /dev/null

  if [[ ! -f go.sum ]]; then
    echo "→ go mod tidy"
    go mod tidy
  fi

  echo "→ golangci-lint run --config=\"$CONFIG\" ./..."
  if ! golangci-lint run --config="$CONFIG" ./...; then
    echo -e "${RED}❌ LINT FAILED IN $dir${NC}"
    popd > /dev/null
    exit 1
  fi

  popd > /dev/null
  echo -e "${GREEN}✔ $dir OK${NC}"
  echo ""
done

echo -e "${GREEN}🎉 ALL $count modules passed golangci-lint!${NC}"
