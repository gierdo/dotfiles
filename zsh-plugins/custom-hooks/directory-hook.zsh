dir_hook() {
    # Set all lock files to chmod 600 to enable smooth automation of virtual environment enablement
    setopt nullglob
    for file in *.lock; do
        chmod 600 "$file"
    done
    unsetopt nullglob
}

# Run on session start
dir_hook

# Run on directory change
chpwd() { dir_hook }
