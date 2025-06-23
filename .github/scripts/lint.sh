#!/usr/bin/env bash
set -e
set -x

ROOT="$(git rev-parse --show-toplevel)"
CONFIG="$ROOT/.github/workflows/golangci.yml"

if [[ ! -f "$CONFIG" ]]; then
  echo "Конфигурация не найдена: $CONFIG"
  exit 1
fi

cd "$ROOT/services"

mapfile -t MODULE_DIRS < <(find . -mindepth 1 -type f -name "go.mod" -exec dirname {} \;)
if [[ ${#MODULE_DIRS[@]} -eq 0 ]]; then
  echo "Не найден ни один go.mod в services/*"
  exit 1
fi

count=0
for dir in "${MODULE_DIRS[@]}"; do
  count=$((count + 1))
  echo "--- [$count] Проверка $dir ---"
  pushd "$dir" > /dev/null
    [[ ! -f go.sum ]] && go mod tidy
    golangci-lint run --config="$CONFIG" ./...
  popd > /dev/null
done

echo "Все $count модуля(-ей) успешно прошли проверку"
