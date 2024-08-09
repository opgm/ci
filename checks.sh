function fail_if_file_missing() {
    if [ ! -f "$1" ]; then
        echo "File $1 is missing"
        return 1
    fi
    return 0
}

# Commonly-missed files either from .gitignore or LFS
fail_if_file_missing panda/board/obj/.placeholder || exit 1
fail_if_file_missing selfdrive/modeld/models/supercombo.onnx || fail_if_file_missing selfdrive/modeld/models/supercombo.thneed || exit 1

fail_if_file_missing README.md || exit 1
if [ ! -s README.md ]; then
    echo "README.md is empty"
    exit 1
fi
ci/test-panda.sh || exit 1

echo "All checks passed"
