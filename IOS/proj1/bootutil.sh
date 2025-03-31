#!/bin/bash

BOOT_ENTRIES_DIR="/boot/loader/entries"

# Global arguments processing
while getopts "b:" opt; do
  case $opt in
    b) BOOT_ENTRIES_DIR="$OPTARG" ;;
    *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Helper functions
get_entry_field() {
  local entry="$1"
  local field="$2"
  grep -E "^$field" "$entry" | tail -n1 | cut -d' ' -f2-
}

get_default_entry() {
  find "$BOOT_ENTRIES_DIR" -name '*.conf' -exec grep -l '^vutfit_default y' {} + | head -n1
}

validate_boot_dir() {
  if [ ! -d "$BOOT_ENTRIES_DIR" ]; then
    echo "Error: Directory $BOOT_ENTRIES_DIR does not exist." >&2
    exit 1
  fi
}

# list command
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
      *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  validate_boot_dir

  local entries=()
  while IFS= read -r -d '' entry; do
    [ -f "$entry" ] || continue

    local title=$(get_entry_field "$entry" "title")
    local version=$(get_entry_field "$entry" "version")
    local kernel=$(get_entry_field "$entry" "linux")
    local sort_key=$(get_entry_field "$entry" "sort-key")

    if [[ -z "$title" || -z "$version" || -z "$kernel" ]]; then
      continue
    fi

    local match=true
    
    if [[ -n "$kernel_regex" && ! "$kernel" =~ $kernel_regex ]]; then
      match=false
    fi
    
    if [[ -n "$title_regex" && ! "$title" =~ $title_regex ]]; then
      match=false
    fi

    if $match; then
      # Use filename as fallback sort key if sort-key is empty
      local effective_sort_key="${sort_key:-$(basename "$entry")}"
      entries+=("$(basename "$entry")|$title|$version|$kernel|$effective_sort_key")
    fi
  done < <(find "$BOOT_ENTRIES_DIR" -maxdepth 1 -type f -name '*.conf' -print0)

  # Determine sorting method
  local sort_field=2  # Default sort by title (field 2)
  if $sort_by_key; then
    sort_field=5      # Sort by sort-key (field 5)
  elif $sort_by_file; then
    sort_field=1      # Sort by filename (field 1)
  fi

  # Sort entries
  IFS=$'\n' sorted_entries=($(printf "%s\n" "${entries[@]}" | sort -t'|' -k${sort_field},${sort_field} -k1,1))

  # Output results
  for entry in "${sorted_entries[@]}"; do
    IFS='|' read -r _ title version kernel _ <<< "$entry"
    echo "$title ($version, $kernel)"
  done
}

# remove command
remove_entries() {
  local title_regex="$1"
  validate_boot_dir

  if [[ -z "$title_regex" ]]; then
    echo "Error: Title regex must be specified." >&2
    exit 1
  fi

  find "$BOOT_ENTRIES_DIR" -maxdepth 1 -type f -name '*.conf' -print0 | while IFS= read -r -d '' entry; do
    title=$(get_entry_field "$entry" "title")
    if [[ "$title" =~ $title_regex ]]; then
      rm -f "$entry" && echo "Removed: $entry"
    fi
  done
}

# duplicate command
duplicate_entry() {
  local add_params=()
  local remove_params=()
  local new_title=""
  local new_kernel=""
  local new_initrd=""
  local destination=""
  local make_default=false

  # Process all arguments in order
  local process_options=true
  local entry_path=""
  local ordered_ops=()

  while [[ $# -gt 0 ]]; do
    if $process_options && [[ "$1" =~ ^- ]]; then
      case "$1" in
        -a) ordered_ops+=("a" "$2"); shift 2 ;;
        -r) ordered_ops+=("r" "$2"); shift 2 ;;
        -t) new_title="$2"; shift 2 ;;
        -k) new_kernel="$2"; shift 2 ;;
        -i) new_initrd="$2"; shift 2 ;;
        -d) destination="$2"; shift 2 ;;
        --make-default) make_default=true; shift ;;
        --) process_options=false; shift ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
      esac
    else
      entry_path="$1"
      shift
    fi
  done

  # If no entry path specified, use default
  if [[ -z "$entry_path" ]]; then
    entry_path=$(get_default_entry)
    if [[ -z "$entry_path" ]]; then
      echo "Error: No default entry found and no entry specified." >&2
      exit 1
    fi
  fi

  # If not absolute path, prepend BOOT_ENTRIES_DIR
  if [[ "$entry_path" != /* ]]; then
    entry_path="$BOOT_ENTRIES_DIR/$entry_path"
  fi

  validate_boot_dir

  if [[ ! -f "$entry_path" ]]; then
    echo "Error: Source file '$entry_path' does not exist." >&2
    exit 1
  fi

  # Generate new entry filename
  local new_entry
  if [[ -n "$destination" ]]; then
    new_entry="$destination"
    [[ "${new_entry##*.}" != "conf" ]] && new_entry="${new_entry}.conf"
  else
    local base_name=$(basename "$entry_path" .conf)
    local counter=1
    new_entry="$BOOT_ENTRIES_DIR/${base_name}-copy-${counter}.conf"

    while [[ -e "$new_entry" ]]; do
      ((counter++))
      new_entry="$BOOT_ENTRIES_DIR/${base_name}-copy-${counter}.conf"
    done
  fi

  # Read and modify content
  local content=$(cat "$entry_path")

  # Update fields if specified
  if [[ -n "$new_title" ]]; then
    content=$(sed "/^title /s/.*/title $new_title/" <<< "$content")
  fi
  if [[ -n "$new_kernel" ]]; then
    content=$(sed "/^linux /s|.*|linux $new_kernel|" <<< "$content")
  fi
  if [[ -n "$new_initrd" ]]; then
    content=$(sed "/^initrd /s|.*|initrd $new_initrd|" <<< "$content")
  fi

  # Process options line
  local cmdline=$(grep -E '^options' <<< "$content" | tail -n1 | cut -d' ' -f2-)

  # Process operations in the order they were given
  for ((i=0; i<${#ordered_ops[@]}; i+=2)); do
    op="${ordered_ops[i]}"
    param_group="${ordered_ops[i+1]}"

    if [[ "$op" == "a" ]]; then
      # Add parameters
      while read -r param; do
        param_name="${param%%=*}"
        # First remove any existing instance
        cmdline=$(echo "$cmdline" | xargs -n1 | grep -vE "^${param_name}(=|$)" | xargs)
        # Then add the new one
        cmdline="${cmdline} ${param}"
      done < <(echo "$param_group" | xargs -n1)
    elif [[ "$op" == "r" ]]; then
      # Remove parameters
      while read -r param; do
        param_name="${param%%=*}"
        cmdline=$(echo "$cmdline" | xargs -n1 | grep -vE "^${param_name}(=|$)" | xargs)
      done < <(echo "$param_group" | xargs -n1)
    fi
  done

  # Clean up spaces
  cmdline=$(echo "$cmdline" | sed -E 's/ +/ /g;s/^ //;s/ $//')

  # Update content with modified cmdline
  content=$(sed "/^options /s/.*/options $cmdline/" <<< "$content")

  # Handle default setting
  content=$(sed '/^vutfit_default/d' <<< "$content")
  if $make_default; then
    # Clear defaults from all other files
    find "$BOOT_ENTRIES_DIR" -name '*.conf' -exec sed -i '/^vutfit_default/d' {} +
    find "$BOOT_ENTRIES_DIR" -name '*.conf' -exec sh -c 'echo "vutfit_default n" >> "$1"' sh {} \;
    content+=$'\n'"vutfit_default y"
  else
    content+=$'\n'"vutfit_default n"
  fi

  # Write the new file
  echo "$content" > "$new_entry"
  echo "Created: $new_entry"
}

# show-default command
show_default_entry() {
  local show_file_only=false

  while getopts "f" opt; do
    case $opt in
      f) show_file_only=true ;;
      *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  validate_boot_dir

  local default_entry=$(get_default_entry)
  if [[ -z "$default_entry" ]]; then
    echo "No default entry found." >&2
    exit 1
  fi

  if $show_file_only; then
    echo "$default_entry"
  else
    cat "$default_entry"
  fi
}

# make-default command
make_default_entry() {
  local entry_path="$1"
  validate_boot_dir

  if [[ ! -f "$entry_path" ]]; then
    echo "Error: File $entry_path does not exist." >&2
    exit 1
  fi

  # Clear existing defaults
  find "$BOOT_ENTRIES_DIR" -name '*.conf' -exec sed -i 's/^vutfit_default .*/vutfit_default n/' {} +
  
  # Set new default
  sed -i '/^vutfit_default/d' "$entry_path"
  echo "vutfit_default y" >> "$entry_path"
}

# Main command processing
COMMAND="$1"
shift

case "$COMMAND" in
  list) list_entries "$@" ;;
  remove) remove_entries "$@" ;;
  duplicate) duplicate_entry "$@" ;;
  show-default) show_default_entry "$@" ;;
  make-default) make_default_entry "$@" ;;
  *) echo "Unknown command: $COMMAND" >&2; exit 1 ;;
esac