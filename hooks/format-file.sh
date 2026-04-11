#!/bin/bash
# Auto-format files based on type after Edit/Write operations
# Also returns linting warnings as additionalContext to the model
# Receives JSON input via stdin from Claude Code hooks

set -euo pipefail

# Extract file path from hook input
file_path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')

if [[ -z "$file_path" ]]; then
    exit 0
fi

# Get file extension
ext="${file_path##*.}"

# Collect linting warnings to send back to model
LINT_WARNINGS=""

# Format based on file type
case "$ext" in
    # JavaScript/TypeScript - Prettier + ESLint
    js|jsx|ts|tsx|mjs|cjs)
        npx prettier --write "$file_path" 2>/dev/null || true
        # Run ESLint and capture warnings
        if command -v eslint &>/dev/null; then
            LINT_OUTPUT=$(npx eslint "$file_path" 2>&1 || true)
            if [[ -n "$LINT_OUTPUT" && "$LINT_OUTPUT" != *"0 problems"* ]]; then
                LINT_WARNINGS="$LINT_OUTPUT"
            fi
        fi
        ;;

    # JSON/YAML/Markdown - Prettier
    json|yaml|yml|md|mdx)
        npx prettier --write "$file_path" 2>/dev/null || true
        ;;

    # CSS/SCSS/LESS - Prettier
    css|scss|sass|less)
        npx prettier --write "$file_path" 2>/dev/null || true
        ;;

    # HTML/Vue/Svelte - Prettier
    html|htm|vue|svelte)
        npx prettier --write "$file_path" 2>/dev/null || true
        ;;

    # Python - Black + isort + pylint
    py)
        if command -v black &>/dev/null; then
            black --quiet "$file_path" 2>/dev/null || true
        fi
        if command -v isort &>/dev/null; then
            isort --quiet "$file_path" 2>/dev/null || true
        fi
        # Run pylint and capture warnings
        if command -v pylint &>/dev/null; then
            LINT_OUTPUT=$(pylint "$file_path" 2>&1 || true)
            if [[ "$LINT_OUTPUT" == *"warning"* || "$LINT_OUTPUT" == *"error"* ]]; then
                LINT_WARNINGS="$LINT_OUTPUT"
            fi
        fi
        ;;

    # Go - gofmt + goimports
    go)
        if command -v goimports &>/dev/null; then
            goimports -w "$file_path" 2>/dev/null || true
        elif command -v gofmt &>/dev/null; then
            gofmt -w "$file_path" 2>/dev/null || true
        fi
        ;;

    # Rust - rustfmt
    rs)
        if command -v rustfmt &>/dev/null; then
            rustfmt --edition 2021 "$file_path" 2>/dev/null || true
        fi
        ;;

    # Swift - swift-format
    swift)
        if command -v swift-format &>/dev/null; then
            swift-format -i "$file_path" 2>/dev/null || true
        fi
        ;;

    # Shell scripts - shfmt
    sh|bash|zsh)
        if command -v shfmt &>/dev/null; then
            shfmt -w -i 4 "$file_path" 2>/dev/null || true
        fi
        ;;

    # Ruby - rubocop
    rb)
        if command -v rubocop &>/dev/null; then
            rubocop -a --fail-level=error "$file_path" 2>/dev/null || true
        fi
        ;;

    # Lua - stylua
    lua)
        if command -v stylua &>/dev/null; then
            stylua "$file_path" 2>/dev/null || true
        fi
        ;;

    # Terraform - terraform fmt
    tf|tfvars)
        if command -v terraform &>/dev/null; then
            terraform fmt "$file_path" 2>/dev/null || true
        fi
        ;;

    # SQL - sql-formatter or pg_format
    sql)
        if command -v sql-formatter &>/dev/null; then
            sql-formatter --fix "$file_path" 2>/dev/null || true
        elif command -v pg_format &>/dev/null; then
            pg_format -i "$file_path" 2>/dev/null || true
        fi
        ;;

    # C/C++ - clang-format
    c|cpp|cc|cxx|h|hpp|hxx)
        if command -v clang-format &>/dev/null; then
            clang-format -i "$file_path" 2>/dev/null || true
        fi
        ;;

    # Java/Kotlin - google-java-format or ktlint
    java)
        if command -v google-java-format &>/dev/null; then
            google-java-format -i "$file_path" 2>/dev/null || true
        fi
        ;;
    kt|kts)
        if command -v ktlint &>/dev/null; then
            ktlint -F "$file_path" 2>/dev/null || true
        fi
        ;;

    # XML - xmllint
    xml|xsl|xslt|plist)
        if command -v xmllint &>/dev/null; then
            xmllint --format "$file_path" --output "$file_path" 2>/dev/null || true
        fi
        ;;

    # TOML - taplo
    toml)
        if command -v taplo &>/dev/null; then
            taplo format "$file_path" 2>/dev/null || true
        fi
        ;;

    # Nix - nixfmt
    nix)
        if command -v nixfmt &>/dev/null; then
            nixfmt "$file_path" 2>/dev/null || true
        fi
        ;;

    # Zig - zig fmt
    zig)
        if command -v zig &>/dev/null; then
            zig fmt "$file_path" 2>/dev/null || true
        fi
        ;;

    # Elixir - mix format
    ex|exs)
        if command -v mix &>/dev/null; then
            mix format "$file_path" 2>/dev/null || true
        fi
        ;;

    # Dart - dart format
    dart)
        if command -v dart &>/dev/null; then
            dart format "$file_path" 2>/dev/null || true
        fi
        ;;

    # Other files - no formatting
    *)
        ;;
esac

# Return additionalContext to the model if there are linting warnings
if [[ -n "$LINT_WARNINGS" ]]; then
    jq -n --arg warnings "$LINT_WARNINGS" --arg file "$file_path" '{
        "additionalContext": "⚠️ Linting warnings for \($file):\n\n\($warnings)\n\nConsider addressing these issues to improve code quality."
    }'
fi

exit 0
