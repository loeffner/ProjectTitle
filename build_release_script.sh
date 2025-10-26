#!/usr/bin/env bash
set -u
# Do not set -e so we can report failures per-step and continue where sensible.

# --- Configuration ---
PROJECT_TITLE="projecttitle"
OUT_DIR="${PROJECT_TITLE}.koplugin"
ZIP_NAME="${PROJECT_TITLE}.zip"
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
L10N_DIR="$BASEDIR/l10n"

# --- Helpers ---
err() { printf '%s\n' "$*" >&2; }
info() { printf '%s\n' "$*"; }

# --- Check tools ---
MISSING=0
for cmd in xgettext msgmerge msgfmt; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        err "Error: $cmd not found in PATH"
        MISSING=1
    fi
done

if [ "$MISSING" -eq 1 ]; then
    err ""
    err "Please install gettext tools first (xgettext, msgmerge, msgfmt)."
    err "On Debian/Ubuntu: sudo apt install gettext"
    exit 1
fi
info "All required tools are available."
info

# --- Compile PO -> MO ---
info "Starting MO files compilation..."
COMPILE_COUNT=0

# Make sure l10n directory exists
if [ ! -d "$L10N_DIR" ]; then
    err "l10n directory not found at: $L10N_DIR"
else
    # iterate directories inside l10n
    for d in "$L10N_DIR"/*/; do
        [ -d "$d" ] || continue
        PO="$d/koreader.po"
        MO="$d/koreader.mo"
        if [ -f "$PO" ]; then
            info "Compiling: $(basename "$d")/koreader.po -> $(basename "$d")/koreader.mo"
            if msgfmt -o "$MO" "$PO"; then
                COMPILE_COUNT=$((COMPILE_COUNT + 1))
            else
                err "Error: Failed to compile $(basename "$d")/koreader.po"
            fi
        fi
    done
fi

info "Compilation completed, successfully generated $COMPILE_COUNT MO files"
info

# --- Prepare output folder ---
# remove old folder if present
if [ -d "$OUT_DIR" ]; then
    info "Removing existing $OUT_DIR"
    rm -rf "$OUT_DIR"
fi
info "Creating $OUT_DIR"
mkdir -p "$OUT_DIR"

# --- Copy files into the plugin folder ---
# allow globs that may not match
shopt -s nullglob

# copy lua files
lua_files=(*.lua)
if [ "${#lua_files[@]}" -gt 0 ]; then
    info "Copying Lua files..."
    cp -a -- "${lua_files[@]}" "$OUT_DIR/"
else
    info "No .lua files found in $BASEDIR"
fi

# helper to copy directories if they exist
copy_dir_if_exists() {
    local src="$1"
    local dst="$2"
    if [ -d "$src" ]; then
        info "Copying $src -> $dst"
        cp -a "$src" "$dst"
    else
        info "Skipping missing directory: $src"
    fi
}

copy_dir_if_exists "$BASEDIR/fonts" "$OUT_DIR/fonts"
copy_dir_if_exists "$BASEDIR/icons" "$OUT_DIR/icons"
copy_dir_if_exists "$BASEDIR/resources" "$OUT_DIR/resources"
copy_dir_if_exists "$BASEDIR/l10n" "$OUT_DIR/l10n"

shopt -u nullglob

# --- Cleanup unwanted files in the package ---
if [ -f "$OUT_DIR/resources/collage.jpg" ]; then
    info "Removing $OUT_DIR/resources/collage.jpg"
    rm -f "$OUT_DIR/resources/collage.jpg"
fi

if [ -f "$OUT_DIR/resources/licenses.txt" ]; then
    info "Removing $OUT_DIR/resources/licenses.txt"
    rm -f "$OUT_DIR/resources/licenses.txt"
fi

# If you want to remove .po files, uncomment the following line:
# find "$OUT_DIR" -name '*.po' -type f -delete

# --- Create zip archive ---
info "Creating zip archive $ZIP_NAME"
if command -v 7z >/dev/null 2>&1; then
    # 7z will create a zip with compression
    if 7z a -tzip "$ZIP_NAME" "$OUT_DIR" >/dev/null; then
        info "Created $ZIP_NAME using 7z"
    else
        err "7z failed to create $ZIP_NAME"
        exit 1
    fi
elif command -v zip >/dev/null 2>&1; then
    # zip -r will include the directory
    if zip -r "$ZIP_NAME" "$OUT_DIR" >/dev/null; then
        info "Created $ZIP_NAME using zip"
    else
        err "zip failed to create $ZIP_NAME"
        exit 1
    fi
else
    err "Neither 7z nor zip found. Please install p7zip-full or zip."
    exit 1
fi

# --- Remove the temporary folder ---
info "Removing temporary folder $OUT_DIR"
rm -rf "$OUT_DIR"

info "Done. Output: $ZIP_NAME"
