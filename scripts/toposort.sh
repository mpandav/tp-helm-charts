#!/bin/bash
set -euo pipefail

declare -A chart_paths
declare -A deps
declare -A reverse_deps

# Collect chart names and dependencies
for chart_yaml in $(find charts/ -name Chart.yaml); do
  dir=$(dirname "$chart_yaml")
  name=$(yq '.name' "$chart_yaml")
  chart_paths["$name"]=$dir
  for dep in $(yq -r '.dependencies[]?.name' "$chart_yaml"); do
    deps["$name"]+="$dep "
    reverse_deps["$dep"]+="$name "
  done
done

# Topo sort
queue=()
for name in "${!chart_paths[@]}"; do
  [[ -z "${deps[$name]:-}" ]] && queue+=("$name")
done

result=()
while ((${#queue[@]})); do
  chart="${queue[0]}"
  queue=("${queue[@]:1}")
  result+=("$chart")

  for dependent in ${reverse_deps[$chart]:-}; do
    deps[$dependent]=${deps[$dependent]//$chart/}
    [[ -z "${deps[$dependent]// }" ]] && queue+=("$dependent")
  done
done

# Output chart paths in order
for chart in "${result[@]}"; do
  echo "${chart_paths[$chart]}"
done