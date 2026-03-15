#cd ..
mkdir -p ./_packed/update/

commit_a="PLACE COMMIT_A HASH"
commit_b="PLACE COMMIT_B HASH"

exclude_path=("_packed" "appdata" "import" "resources" "sources" "Temp")
include_path=("bin" "gamedata/meshes" "gamedata/sounds" "gamedata/textures")

is_excluded() {
	local path="$1"
	for d in "${exclude_path[@]}"; do
		if [[ "$path" == "$d" || "$path" == "$d"/* ]]; then
			return 0
		fi
	done
	return 1
}

is_included() {
	local path="$1"
	for d in "${include_path[@]}"; do
		if [[ "$path" == "$d"/* || "$path" == "$d" ]]; then
			return 0
		fi
	done
	return 1
}

git diff --name-only "$commit_a" "$commit_b" | while IFS= read -r file; do
	if ! is_excluded "$file"; then
		mkdir -p "./_packed/update/$(dirname "$file")"
		git show "$commit_b:$file" > "./_packed/update/$file"
	fi
done

old_ts=$(git show -s --format=%ct "$commit_a")
new_ts=$(git show -s --format=%ct "$commit_b")

copy_if_in_range() {
	local file="$1"
	if [ -f "$file" ] && ! is_excluded "$file"; then
		file_ts=$(date -r "$file" +%s 2>/dev/null)
		if [ -n "$file_ts" ] && [ "$file_ts" -gt "$old_ts" ] && [ "$file_ts" -lt "$new_ts" ]; then
			mkdir -p "./_packed/update/$(dirname "$file")"
			cp "$file" "./_packed/update/$file"
		fi
	fi
}

git ls-files --others --ignored --exclude-standard | while IFS= read -r file; do
	if is_included "$file"; then
		copy_if_in_range "$file"
	fi
done