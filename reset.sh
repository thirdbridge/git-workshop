#!/bin/bash

git fetch --all

git checkout -b tempxyz

source_raw=$(git branch -r | grep 'source/')
origin_raw=$(git branch -r | grep 'origin/' | grep -v 'HEAD')
local_raw=$(git branch | grep -v 'tempxyz')

source_array=()
origin_array=()
local_array=()

while IFS= read -r line; do
  branch_name=$(echo $line | sed 's/^[^\/]*\///')
  source_array+=("$branch_name")
done <<< "$source_raw"

while IFS= read -r line; do
  branch_name=$(echo $line | sed 's/^[^\/]*\///')
  origin_array+=("$branch_name")
done <<< "$origin_raw"

while IFS= read -r line; do
  local_array+=("$line")
done <<< "$local_raw"

remote_diff_array=($(comm -13 <(printf "%s\n" "${source_array[@]}" | sort) <(printf "%s\n" "${origin_array[@]}" | sort)))
local_diff_array=($(comm -13 <(printf "%s\n" "${source_array[@]}" | sort) <(printf "%s\n" "${local_array[@]}" | sort)))

echo "${local_diff_array[@]}"

for branch in "${source_array[@]}"; do
  git branch -f $branch source/$branch
  git branch $branch -u origin/$branch
  git push -f origin $branch
done

for branch in "${remote_diff_array[@]}"; do
  git push --delete origin $branch
done

for branch in "${local_diff_array[@]}"; do
    git branch -D $branch
done

git checkout -- .
git branch -f main origin/main
git branch main -u origin
git checkout main
git branch -D tempxyz