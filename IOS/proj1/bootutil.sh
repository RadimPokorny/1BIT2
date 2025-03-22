#!/bin/bash

# Výchozí adresář pro záznamy zavaděče
BOOT_ENTRIES_DIR="/boot/loader/entries"

# Zpracování argumentů
while getopts "b:" opt; do
  case $opt in
    b) BOOT_ENTRIES_DIR="$OPTARG" ;;
    *) echo "Neznámá volba: -$OPTARG"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

COMMAND="$1"
shift

# Funkce pro výpis záznamů
list_entries() {
  local sort_by_file=false
  local sort_by_key=false
  local kernel_regex=""
  local title_regex=""

  while getopts "fsk:t:" opt; do
    case $opt in
      f) sort_by_file=true ;;
      s) sort_by_key=true ;;
      k) kernel_regex="$OPTARG" ;;
      t) title_regex="$OPTARG" ;;
      *) echo "Neznámá volba: -$OPTARG"; exit 1 ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ ! -d "$BOOT_ENTRIES_DIR" ]; then
    echo "Chyba: Adresář $BOOT_ENTRIES_DIR neexistuje." >&2
    exit 1
  fi

  entries=()

  for entry in "$BOOT_ENTRIES_DIR"/*.conf; do
    [ -f "$entry" ] || continue

    title=$(grep -E '^title' "$entry" | tail -n1 | cut -d' ' -f2-)
    version=$(grep -E '^version' "$entry" | tail -n1 | cut -d' ' -f2-)
    kernel=$(grep -E '^linux' "$entry" | tail -n1 | cut -d' ' -f2-)
    sort_key=$(grep -E '^sort-key' "$entry" | tail -n1 | cut -d' ' -f2-)

    # Filtrace podle kernelu a title
    if [[ -n "$kernel_regex" && ! "$kernel" =~ $kernel_regex ]]; then
      continue
    fi
    if [[ -n "$title_regex" && ! "$title" =~ $title_regex ]]; then
      continue
    fi

    entries+=("$entry|$title|$version|$kernel|$sort_key")
  done

  # Řazení
  if $sort_by_key; then
    IFS=$'\n' entries=($(printf "%s\n" "${entries[@]}" | sort -t'|' -k5,5 -k1,1))
  elif $sort_by_file; then
    IFS=$'\n' entries=($(printf "%s\n" "${entries[@]}" | sort))
  fi

  # Výpis
  for entry in "${entries[@]}"; do
    IFS='|' read -r file title version kernel _ <<< "$entry"
    echo "$title ($version, $kernel)"
  done
}

# Funkce pro generování unikátního názvu
get_unique_filename() {
  local base="$1"
  local counter=1
  while [ -e "$BOOT_ENTRIES_DIR/${base}.${counter}.conf" ]; do
    ((counter++))
  done
  echo "$BOOT_ENTRIES_DIR/${base}.${counter}.conf"
}

# Funkce pro duplikaci záznamů s úpravou příkazového řádku
duplicate_entry() {
  local add_params=()
  local remove_params=()
  local new_title=""
  local make_default=false

  while getopts "a:r:t:d:m" opt; do
    case $opt in
      a) add_params+=("$OPTARG") ;;
      r) remove_params+=("$OPTARG") ;;
      t) new_title="$OPTARG" ;;
      d) destination="$OPTARG" ;;
      m) make_default=true ;;
      *) echo "Neznámá volba: -$OPTARG"; exit 1 ;;
    esac
  done

  shift $((OPTIND - 1))

  local entry="$1"

  if [ ! -f "$BOOT_ENTRIES_DIR/$entry" ]; then
    echo "Chyba: Záznam $entry neexistuje." >&2
    exit 1
  fi

  local new_entry
  if [ -n "$destination" ]; then
    new_entry="$destination"
  else
    new_entry=$(get_unique_filename "${entry%.conf}")
  fi

  cp "$BOOT_ENTRIES_DIR/$entry" "$new_entry"

  # Nastavení vutfit_default
  if $make_default; then
    sed -i "s/^vutfit_default.*/vutfit_default n/" "$BOOT_ENTRIES_DIR"/*.conf
    echo "vutfit_default y" >> "$new_entry"
  else
    echo "vutfit_default n" >> "$new_entry"
  fi

  # Úprava příkazového řádku
  local cmdline=$(grep -E '^options' "$new_entry" | tail -n1 | cut -d' ' -f2-)

  for param in "${remove_params[@]}"; do
    if [[ "$param" == *=* ]]; then
      cmdline=$(echo "$cmdline" | sed -E "s/\b${param}\b//g")
    else
      cmdline=$(echo "$cmdline" | sed -E "s/\b${param}(=[^ ]*)?\b//g")
    fi
  done

  for param in "${add_params[@]}"; do
    if [[ ! "$cmdline" =~ \b${param%%=*}\b ]]; then
      cmdline+=" $param"
    fi
  done

  sed -i "s/^options.*/options $cmdline/" "$new_entry"

  # Úprava názvu
  if [ -n "$new_title" ]; then
    sed -i "s/^title.*/title $new_title/" "$new_entry"
  fi

  echo "Záznam byl duplikován: $new_entry"
}

case "$COMMAND" in
  list) list_entries "$@" ;;
  duplicate) duplicate_entry "$@" ;;
  *) echo "Neznámý příkaz: $COMMAND"; exit 1 ;;
esac