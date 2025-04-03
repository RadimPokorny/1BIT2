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

list_entries() {
    local sort_by_file=false
    local sort_by_key=false
    local kernel_filter=""
    local title_filter=""
    local filter_kernel=false
    local filter_title=false
    local no_filters=true  # Flag to track if no filters are applied

    # Process options
    while getopts "fsk:t:" opt; do
        case $opt in
            f) sort_by_file=true; no_filters=false ;;
            s) sort_by_key=true; no_filters=false ;;
            k) kernel_filter="$OPTARG"; filter_kernel=true; no_filters=false ;;
            t) title_filter="$OPTARG"; filter_title=true; no_filters=false ;;
            *) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1))

    validate_boot_dir

    # If no filters or sorting options are provided, just print all entries simply
    if $no_filters; then
        local found_any=false
        for file in "$BOOT_ENTRIES_DIR"/*.conf; do
            [ -f "$file" ] || continue

            local title="" version="" linux=""
            
            while IFS= read -r line; do
                key="${line%% *}"
                value="${line#* }"
                case "$key" in
                    title) title="$value";;
                    version) version="$value";;
                    linux) linux="$value";;
                esac
            done < "$file"

            # Skip entries with missing required fields
            if [[ -n "$title" && -n "$version" && -n "$linux" ]]; then
                echo "$title ($version, $linux)"
                found_any=true
            fi
        done
        $found_any || true  # Ensure exit status 0 even when no entries found
        return 0
    fi

    # Original processing with filters and sorting
    local with_sortkey=()
    local without_sortkey=()
    local found_any=false

    for file in "$BOOT_ENTRIES_DIR"/*.conf; do
        [ -f "$file" ] || continue

        local title="" version="" linux="" sort_key=""
        
        while IFS= read -r line; do
            key="${line%% *}"
            value="${line#* }"
            case "$key" in
                title) title="$value";;
                version) version="$value";;
                linux) linux="$value";;
                sort-key) sort_key="$value";;
            esac
        done < "$file"

        # Skip entries with missing required fields
        if [[ -z "$title" || -z "$version" || -z "$linux" ]]; then
            continue
        fi

        local match=true

        # Apply kernel filter if specified
        if $filter_kernel; then
            if ! echo "$linux" | grep -qE "$kernel_filter"; then
                match=false
            fi
        fi

        # Apply title filter if specified
        if $filter_title; then
            if ! echo "$title" | grep -qE "$title_filter"; then
                match=false
            fi
        fi

        if $match; then
            found_any=true
            local filename=$(basename "$file")
            local entry_display="$title ($version, $linux)"
            
            if [[ -n "$sort_key" ]]; then
                with_sortkey+=("$sort_key|$filename|$entry_display")
            else
                without_sortkey+=("$filename|$entry_display")
            fi
        fi
    done

    # If no matches found, return empty output with status 0
    if ! $found_any; then
        return 0
    fi

    # Handle sorting based on options
    if $sort_by_file; then
        # Sort by filename
        { 
            printf '%s\n' "${with_sortkey[@]}" | sort -t'|' -k2,2 
            printf '%s\n' "${without_sortkey[@]}" | sort -t'|' -k1,1 
        } | while IFS='|' read -r _ _ entry; do
            echo "$entry"
        done
    elif $sort_by_key; then
        # Sort by sort-key
        { 
            printf '%s\n' "${with_sortkey[@]}" | sort -t'|' -k1,1 -k2,2 
            printf '%s\n' "${without_sortkey[@]}" | sort -t'|' -k1,1 
        } | while IFS='|' read -r _ _ entry; do
            echo "$entry"
        done
    else
        # Default sort (by title)
        {
            # Sort entries with sort-key by title (field 3)
            printf '%s\n' "${with_sortkey[@]}" | awk -F'|' '{print $3 "|" $1 "|" $2 "|" $3}' | sort -t'|' -k1,1 | cut -d'|' -f4
            # Sort entries without sort-key by title (field 2)
            printf '%s\n' "${without_sortkey[@]}" | awk -F'|' '{print $2 "|" $1}' | sort -t'|' -k1,1 | cut -d'|' -f2
        }
    fi
}

remove_entries() {
    local title_regex="$1"
    validate_boot_dir

    if [[ -z "$title_regex" ]]; then
        echo "Error: Title regex must be specified." >&2
        exit 1
    fi

    # Remove entries silently
    for entry in "$BOOT_ENTRIES_DIR"/*.conf; do
        [ -f "$entry" ] || continue
        title=$(get_entry_field "$entry" "title")
        [[ -n "$title" ]] || continue
        
        if echo "$title" | grep -Eq "$title_regex"; then
            rm -f "$entry"
        fi
    done
}

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
        # First check if parameter already exists
        if ! echo "$cmdline" | xargs -n1 | grep -qE "^${param_name}(=|$)"; then
          cmdline="${cmdline} ${param}"
        fi
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