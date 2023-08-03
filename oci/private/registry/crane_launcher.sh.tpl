readonly SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
readonly CRANE_REGISTRY_BIN="/Users/thesayyn/Documents/go-containerregistry/main"

function start_registry() {
    local storage_dir="$1/blobs"
    local output="$2"
    local deadline="${3:-5}"

    mkdir -p "$storage_dir"

    # --blobs-to-disk uses go's os.TempDir() function which is equal to TMPDIR under *nix.
    # TODO: windows!!!!!!!!
    TMPDIR="${storage_dir}" "${CRANE_REGISTRY_BIN}" registry serve --blobs-to-disk >> $output 2>&1 &

    local timeout=$((SECONDS+${deadline}))

    while [ "${SECONDS}" -lt "${timeout}" ]; do
        local port=$(cat $output | sed -nr 's/.+serving on port ([0-9]+)/\1/p')
        if [ -n "${port}" ]; then
            break
        fi
    done
    if [ -z "${port}" ]; then
        echo "registry didn't become ready within ${deadline}s." >&2
        return 1
    fi
    echo "127.0.0.1:${port}"
    return 0
}

function stop_registry() { 
    :
}