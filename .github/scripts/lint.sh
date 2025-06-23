#!/usr/bin/env bash
set -e
set -x

ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo "Конфигурация не найдена: $CONFIG"
  exit 1
fi

mapfile -t MODULE_DIRS < <(find "$ROOT/services" -mindepth 1 -type f -name go.mod -exec dirname {} \;)

if [[ ${#MODULE_DIRS[@]} -eq 0 ]]; then
  echo "Не найден ни один go.mod в services/*"
  exit 1
fi

count=0
for dir in "${MODULE_DIRS[@]}"; do
  count=$((count+1))
  echo "--- [$count] LINT $dir ---"
  if [[ ! -f "$dir/go.sum" ]]; then
    go mod tidy -modfile="$dir/go.mod" -modcache="$(go env GOMODCACHE)" -go=1.23 -mod="$dir"
  fi
  golangci-lint run --config="$CONFIG" "$dir/..."
done

echo "Все $count модуля(-ей) успешно прошли проверку"
