#!/usr/bin/env bash
set -euo pipefail

CODEX_DIR="$HOME/.codex"
PARTS_DIR="$CODEX_DIR/parts"
BIN_DIR="$HOME/.local/bin"
CONFIG_FILE="$CODEX_DIR/config.toml"
GLOBAL_AGENTS="$CODEX_DIR/AGENTS.md"
GLOBAL_OVERRIDE="$CODEX_DIR/AGENTS.override.md"

mkdir -p "$PARTS_DIR" "$BIN_DIR" "$CODEX_DIR"

write_file() {
  local target="$1"
  cat > "$target"
}

append_if_missing() {
  local file="$1"
  local text="$2"
  touch "$file"
  if ! grep -Fq "$text" "$file"; then
    printf "\n%s\n" "$text" >> "$file"
  fi
}

# =========================
# GLOBAL FILES
# =========================

write_file "$GLOBAL_AGENTS" <<'EOF_AGENTS'
# Global AGENTS

You are a senior TypeScript engineer.

- Always present an implementation plan in Portuguese before coding
- Never modify files without explicit approval
- Always include tests when behavior changes
- Prefer minimal and localized changes
- Follow existing project patterns before introducing new ones
- Never execute destructive or deploy commands
EOF_AGENTS

touch "$GLOBAL_OVERRIDE"

write_file "$CONFIG_FILE" <<'EOF_CONFIG'
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.backend]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.frontend]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.fullstack]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.debug]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[profiles.review]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "read-only"

[profiles.ci]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "read-only"

[profiles.architecture]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "read-only"

[profiles.refactor]
model = "gpt-5.4"
approval_policy = "on-request"
sandbox_mode = "workspace-write"
EOF_CONFIG

# =========================
# PARTS
# =========================

write_file "$PARTS_DIR/global.md" <<'EOF_PART'
## Global Rules

- Always present an implementation plan in Portuguese before coding
- Never create, edit, rename, move, or delete files without explicit approval
- Prefer minimal and localized changes
- Follow existing project patterns before introducing new ones
- Do not assume missing context
- Always include tests when behavior changes
- Never execute destructive or deploy commands
EOF_PART

write_file "$PARTS_DIR/testing.md" <<'EOF_PART'
## Testing Rules (Mandatory)

Tests are not optional.

- Every implemented or changed behavior must be covered by tests
- Never finish a task without creating or updating relevant tests
- Always mention in the plan which tests will be created or updated
- Before finishing, report:
  - tests created
  - tests updated
  - covered scenarios
  - remaining uncovered risks

### Testing standards

- Follow AAA pattern
- Test behavior, not implementation details
- Avoid unnecessary mocks
- Mock only true external boundaries
EOF_PART

write_file "$PARTS_DIR/backend.md" <<'EOF_PART'
## Backend Rules

This project uses Clean Architecture with possible NestJS and Cloudflare Workers boundaries.

- Domain and Use Cases must remain framework-agnostic
- No NestJS, Cloudflare runtime APIs, ORM decorators, or transport objects in the core
- Use Cases should depend on interfaces and prefer Result/Either-style failures
- NestJS only at boundaries
- Workers only in infrastructure/runtime boundaries
- Controllers and handlers must stay thin
EOF_PART

write_file "$PARTS_DIR/frontend.md" <<'EOF_PART'
## Frontend Rules

Do not apply backend Clean Architecture rigidly to the frontend.

- UI is not business logic
- Prefer composition over abstraction-heavy layering
- Keep components simple, declarative, and predictable
- Prefer functional components
- Prefer hooks for reusable stateful logic
- Prefer Server Components by default when App Router is used
EOF_PART

write_file "$PARTS_DIR/strict.md" <<'EOF_PART'
## Strict Mode

- Do not proceed without approval
- Do not assume missing context
- Do not refactor beyond scope
- Do not introduce new abstractions unless required
- Prefer the simplest solution that satisfies the requirement
EOF_PART

write_file "$PARTS_DIR/debug.md" <<'EOF_PART'
## Debug Mode Rules

- Do not jump to conclusions
- Form hypotheses
- Validate assumptions step by step
- Prefer root-cause analysis over guesswork
- Propose the smallest safe fix
EOF_PART

write_file "$PARTS_DIR/review.md" <<'EOF_PART'
## Review Mode Rules

You are also acting as a senior reviewer.

- Review consistency with project patterns
- Review typing correctness
- Review edge cases
- Review error handling
- Review test adequacy
- Avoid overengineering
EOF_PART

write_file "$PARTS_DIR/ci.md" <<'EOF_PART'
## CI Mode Rules

- Ensure TypeScript compiles without errors
- Ensure tests pass
- Ensure lint-sensitive issues are considered
- Warn if something may break CI
EOF_PART

write_file "$PARTS_DIR/planner.md" <<'EOF_PART'
## Planner Mode Rules

- Break the problem into steps
- Define implementation boundaries
- Identify impacted files
- Identify test impact
- Do not code
EOF_PART

write_file "$PARTS_DIR/executor.md" <<'EOF_PART'
## Executor Mode Rules

- Implement only the approved plan
- Do not expand scope
- Keep changes localized
- Update tests with the implementation
EOF_PART

write_file "$PARTS_DIR/reviewer.md" <<'EOF_PART'
## Reviewer Mode Rules

- Critically evaluate the implementation
- Identify risks and regressions
- Suggest simplifications
- Validate test coverage adequacy
EOF_PART

write_file "$PARTS_DIR/architecture.md" <<'EOF_PART'
## Architecture Mode Rules

- Analyze boundaries and module responsibilities
- Identify coupling and dependency leaks
- Identify violations of layering or separation of concerns
- Prefer minimal architectural recommendations
- Do not suggest broad rewrites unless clearly necessary
EOF_PART

write_file "$PARTS_DIR/refactor.md" <<'EOF_PART'
## Refactor Mode Rules

- Refactor only with explicit approval
- Preserve behavior
- Keep changes incremental
- Avoid mixing refactor with feature work unless requested
- Update tests when behavior-adjacent code changes
EOF_PART

# =========================
# COMMON
# =========================

write_file "$BIN_DIR/codex-common.sh" <<'EOF_COMMON'
#!/usr/bin/env bash
set -euo pipefail

codex_parts_dir() { echo "$HOME/.codex/parts"; }
codex_state_dir() { local d="${1:-.}"; echo "$d/.codex"; }
codex_agents_file() { local d="${1:-.}"; echo "$d/AGENTS.md"; }
codex_override_file() { echo "$HOME/.codex/AGENTS.override.md"; }
codex_profile_file() { local d="${1:-.}"; echo "$d/.codex/profile"; }
codex_mode_file() { local d="${1:-.}"; echo "$d/.codex/mode"; }
codex_base_file() { local d="${1:-.}"; echo "$d/.codex/AGENTS.base.md"; }
codex_backup_file() { local d="${1:-.}"; echo "$d/.codex/AGENTS.pre-codex-build.backup.md"; }

codex_ensure_state_dir() {
  local d="${1:-.}"
  mkdir -p "$(codex_state_dir "$d")"
}

codex_append_file() {
  local file="$1"
  [[ -f "$file" ]] || { echo "Arquivo não encontrado: $file"; exit 1; }
  cat "$file"
  echo
}

codex_is_home_dir() {
  local d
  d="$(cd "${1:-.}" && pwd)"
  [[ "$d" == "$HOME" ]]
}

codex_is_project_dir() {
  local d="${1:-.}"
  [[ -f "$d/package.json" || -d "$d/.git" || -f "$d/tsconfig.json" || -f "$d/pnpm-workspace.yaml" ]]
}

codex_guard_project_dir() {
  local d="${1:-.}"
  local force="${2:-0}"

  if codex_is_home_dir "$d"; then
    echo "❌ Bloqueado: você está tentando rodar no diretório HOME ($HOME)"
    echo "👉 Entre em um projeto ou use --force se realmente quiser"
    exit 1
  fi

  if codex_is_project_dir "$d"; then
    return 0
  fi

  if [[ "$force" == "1" ]]; then
    echo "⚠️ Executando com --force em diretório não identificado como projeto"
    return 0
  fi

  echo "❌ Diretório não parece ser um projeto: $d"
  echo "👉 Use --force se quiser gerar mesmo assim"
  exit 1
}

codex_detect_stack() {
  local d="${1:-.}"
  local has_backend=0
  local has_frontend=0

  [[ -f "$d/nest-cli.json" ]] && has_backend=1
  [[ -f "$d/wrangler.toml" ]] && has_backend=1
  [[ -f "$d/next.config.js" || -f "$d/next.config.mjs" || -f "$d/next.config.ts" ]] && has_frontend=1

  if [[ -f "$d/package.json" ]]; then
    grep -Eq '"@nestjs/|\"wrangler\"|\"@cloudflare/' "$d/package.json" && has_backend=1 || true
    grep -Eq '"next"|\"react\"|\"react-dom\"' "$d/package.json" && has_frontend=1 || true
  fi

  if [[ $has_backend -eq 1 && $has_frontend -eq 1 ]]; then
    echo "fullstack"
  elif [[ $has_backend -eq 1 ]]; then
    echo "backend"
  elif [[ $has_frontend -eq 1 ]]; then
    echo "frontend"
  else
    echo "unknown"
  fi
}

codex_suggest_native_profile() {
  local stack="${1:-unknown}"
  local mode="${2:-default}"

  case "$mode" in
    debug) echo "debug" ;;
    review) echo "review" ;;
    ci) echo "ci" ;;
    architecture) echo "architecture" ;;
    refactor) echo "refactor" ;;
    *)
      case "$stack" in
        backend) echo "backend" ;;
        frontend) echo "frontend" ;;
        fullstack) echo "fullstack" ;;
        *) echo "unknown" ;;
      esac
      ;;
  esac
}
EOF_COMMON

chmod +x "$BIN_DIR/codex-common.sh"

# =========================
# BUILD
# =========================

write_file "$BIN_DIR/codex-build" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROFILE=""
PROJECT_DIR="."
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    backend|frontend|fullstack)
      PROFILE="$1"
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    *)
      PROJECT_DIR="$1"
      shift
      ;;
  esac
done

if [[ -z "$PROFILE" ]]; then
  echo "Uso: codex-build [backend|frontend|fullstack] [diretorio] [--force]"
  exit 1
fi

codex_guard_project_dir "$PROJECT_DIR" "$FORCE"
codex_ensure_state_dir "$PROJECT_DIR"

PARTS_DIR="$(codex_parts_dir)"
OUTPUT_FILE="$(codex_agents_file "$PROJECT_DIR")"
BASE_FILE="$(codex_base_file "$PROJECT_DIR")"
BACKUP_FILE="$(codex_backup_file "$PROJECT_DIR")"

if [[ -f "$OUTPUT_FILE" && ! -f "$BACKUP_FILE" ]]; then
  cp "$OUTPUT_FILE" "$BACKUP_FILE"
fi

{
  echo "# AGENTS.md"
  echo
  echo "<!-- Generated by codex-build v8 -->"
  echo
  codex_append_file "$PARTS_DIR/global.md"
  codex_append_file "$PARTS_DIR/testing.md"

  case "$PROFILE" in
    backend)
      codex_append_file "$PARTS_DIR/backend.md"
      codex_append_file "$PARTS_DIR/strict.md"
      ;;
    frontend)
      codex_append_file "$PARTS_DIR/frontend.md"
      codex_append_file "$PARTS_DIR/strict.md"
      ;;
    fullstack)
      codex_append_file "$PARTS_DIR/backend.md"
      codex_append_file "$PARTS_DIR/frontend.md"
      codex_append_file "$PARTS_DIR/strict.md"
      ;;
  esac
} > "$OUTPUT_FILE"

cp "$OUTPUT_FILE" "$BASE_FILE"
echo "$PROFILE" > "$(codex_profile_file "$PROJECT_DIR")"
echo "default" > "$(codex_mode_file "$PROJECT_DIR")"

echo "✅ Gerado: $OUTPUT_FILE"
echo "👉 Perfil: $PROFILE"
EOF_BIN

chmod +x "$BIN_DIR/codex-build"

# =========================
# MODE
# =========================

write_file "$BIN_DIR/codex-mode" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

MODE="${1:-}"
PROJECT_DIR="${2:-.}"
OVERRIDE_FILE="$(codex_override_file)"
PARTS_DIR="$(codex_parts_dir)"

if [[ -z "$MODE" ]]; then
  echo "Uso: codex-mode <mode> [diretorio]"
  exit 1
fi

[[ -f "$(codex_agents_file "$PROJECT_DIR")" ]] || {
  echo "❌ AGENTS.md não encontrado no projeto."
  exit 1
}

if [[ "$MODE" == "default" ]]; then
  : > "$OVERRIDE_FILE"
  echo "default" > "$(codex_mode_file "$PROJECT_DIR")"
  echo "✅ Modo default ativado"
  exit 0
fi

MODE_FILE="$PARTS_DIR/$MODE.md"

if [[ ! -f "$MODE_FILE" ]]; then
  echo "❌ Modo não encontrado: $MODE"
  echo "👉 Crie com: codex-new-mode $MODE"
  exit 1
fi

cp "$MODE_FILE" "$OVERRIDE_FILE"
echo "$MODE" > "$(codex_mode_file "$PROJECT_DIR")"

echo "✅ Modo ativado: $MODE"
echo "👉 Fonte: $MODE_FILE"
echo "👉 Override: $OVERRIDE_FILE"
EOF_BIN

chmod +x "$BIN_DIR/codex-mode"

# =========================
# STATUS / INFO
# =========================

write_file "$BIN_DIR/codex-status" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROJECT_DIR="${1:-.}"
STACK="$(codex_detect_stack "$PROJECT_DIR")"
MODE="default"
PROFILE="unknown"

[[ -f "$(codex_mode_file "$PROJECT_DIR")" ]] && MODE="$(cat "$(codex_mode_file "$PROJECT_DIR")")"
[[ -f "$(codex_profile_file "$PROJECT_DIR")" ]] && PROFILE="$(cat "$(codex_profile_file "$PROJECT_DIR")")"

echo "📍 Projeto: $PROJECT_DIR"
echo "🕵️  Stack: $STACK"
echo "🧩 Perfil: $PROFILE"
echo "🎛️  Modo: $MODE"
echo "💡 Profile nativo sugerido: $(codex_suggest_native_profile "$STACK" "$MODE")"
echo "🌍 Override global: $HOME/.codex/AGENTS.override.md"
EOF_BIN

chmod +x "$BIN_DIR/codex-status"

write_file "$BIN_DIR/codex-project-info" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
codex-status "${1:-.}"
EOF_BIN

chmod +x "$BIN_DIR/codex-project-info"

# =========================
# INIT / PROFILE / SYNC / RESTORE
# =========================

write_file "$BIN_DIR/codex-init" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROJECT_DIR="${1:-.}"
PROFILE="${2:-auto}"
FORCE="${3:-}"

if [[ "$PROFILE" == "auto" ]]; then
  PROFILE="$(codex_detect_stack "$PROJECT_DIR")"
  [[ "$PROFILE" != "unknown" ]] || {
    echo "❌ Não foi possível detectar a stack."
    echo "Use backend, frontend ou fullstack manualmente."
    exit 1
  }
fi

if [[ "$FORCE" == "--force" ]]; then
  codex-build "$PROFILE" "$PROJECT_DIR" --force
else
  codex-build "$PROFILE" "$PROJECT_DIR"
fi
EOF_BIN

chmod +x "$BIN_DIR/codex-init"

write_file "$BIN_DIR/codex-profile" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
PROFILE="${1:-}"
PROJECT_DIR="${2:-.}"
[[ -n "$PROFILE" ]] || { echo "Uso: codex-profile [backend|frontend|fullstack] [diretorio]"; exit 1; }
codex-build "$PROFILE" "$PROJECT_DIR"
EOF_BIN

chmod +x "$BIN_DIR/codex-profile"

write_file "$BIN_DIR/codex-sync" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROJECT_DIR="${1:-.}"

[[ -f "$(codex_profile_file "$PROJECT_DIR")" ]] || {
  echo "❌ Perfil não encontrado no projeto."
  exit 1
}

PROFILE="$(cat "$(codex_profile_file "$PROJECT_DIR")")"
MODE="default"
[[ -f "$(codex_mode_file "$PROJECT_DIR")" ]] && MODE="$(cat "$(codex_mode_file "$PROJECT_DIR")")"

codex-build "$PROFILE" "$PROJECT_DIR" --force
codex-mode "$MODE" "$PROJECT_DIR"
echo "✅ Projeto sincronizado"
EOF_BIN

chmod +x "$BIN_DIR/codex-sync"

write_file "$BIN_DIR/codex-restore" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROJECT_DIR="${1:-.}"
BACKUP_FILE="$(codex_backup_file "$PROJECT_DIR")"
AGENTS_FILE="$(codex_agents_file "$PROJECT_DIR")"

[[ -f "$BACKUP_FILE" ]] || { echo "❌ Backup não encontrado."; exit 1; }
cp "$BACKUP_FILE" "$AGENTS_FILE"
echo "✅ AGENTS.md restaurado"
EOF_BIN

chmod +x "$BIN_DIR/codex-restore"

# =========================
# RUN / FLOW
# =========================

write_file "$BIN_DIR/codex-run" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

MODE="${1:-default}"
PROJECT_DIR="${2:-.}"

STACK="$(codex_detect_stack "$PROJECT_DIR")"
SUGGESTED_PROFILE="$(codex_suggest_native_profile "$STACK" "$MODE")"

codex-mode "$MODE" "$PROJECT_DIR"

echo "✅ Ambiente preparado"
echo "🕵️  Stack: $STACK"
echo "🎛️  Modo: $MODE"
echo "💡 Profile nativo sugerido no Codex: $SUGGESTED_PROFILE"
EOF_BIN

chmod +x "$BIN_DIR/codex-run"

write_file "$BIN_DIR/codex-flow" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"

echo "🧠 Planner"
codex-mode planner "$PROJECT_DIR"

echo "⚙️ Executor"
codex-mode executor "$PROJECT_DIR"

echo "🔍 Reviewer"
codex-mode reviewer "$PROJECT_DIR"

echo "✅ Fluxo planner → executor → reviewer preparado"
EOF_BIN

chmod +x "$BIN_DIR/codex-flow"

# =========================
# TEST GEN / CI
# =========================

write_file "$BIN_DIR/codex-test-gen" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
  echo "Uso: codex-test-gen <arquivo>"
  exit 1
fi

echo "Generate tests for the following file:"
echo
echo "- Use AAA pattern"
echo "- Cover happy path, edge cases, and failures"
echo "- Avoid mocks unless necessary"
echo "- Test behavior, not implementation details"
echo
echo "FILE: $FILE"
EOF_BIN

chmod +x "$BIN_DIR/codex-test-gen"

write_file "$BIN_DIR/codex-ci-run" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Running CI checks..."

if [[ -f package.json ]]; then
  if command -v npx >/dev/null 2>&1; then
    if [[ -f tsconfig.json ]]; then
      echo "👉 Type check"
      npx tsc --noEmit
    fi
  fi

  if grep -q '"test"' package.json; then
    echo "👉 Tests"
    npm test
  fi

  if grep -q '"lint"' package.json; then
    echo "👉 Lint"
    npm run lint
  fi
fi

echo "✅ CI checks passed"
EOF_BIN

chmod +x "$BIN_DIR/codex-ci-run"

# =========================
# REVIEW / ARCHITECTURE / CHANGELOG / REFACTOR
# =========================

write_file "$BIN_DIR/codex-pr-review" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

echo "PR Review Checklist"
echo
echo "- Is the solution consistent with project patterns?"
echo "- Are there hidden side effects?"
echo "- Is typing strict and correct?"
echo "- Are edge cases handled?"
echo "- Is error handling correct?"
echo "- Are tests adequate?"
echo "- Is there unnecessary abstraction?"
EOF_BIN

chmod +x "$BIN_DIR/codex-pr-review"

write_file "$BIN_DIR/codex-architecture-report" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

echo "Architecture Review Checklist"
echo
echo "- Check boundary violations"
echo "- Check dependency direction"
echo "- Check coupling between modules"
echo "- Check framework leakage into core"
echo "- Check over-centralized services/components"
echo "- Check opportunities for simpler structure"
EOF_BIN

chmod +x "$BIN_DIR/codex-architecture-report"

write_file "$BIN_DIR/codex-changelog-gen" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "# Changelog Draft"
  echo
  git log --pretty=format:"- %s" -20
else
  echo "❌ Not a git repository"
  exit 1
fi
EOF_BIN

chmod +x "$BIN_DIR/codex-changelog-gen"

write_file "$BIN_DIR/codex-auto-refactor" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${1:-.}"

codex-mode refactor "$PROJECT_DIR"
echo "✅ Refactor mode preparado"
echo "⚠️ Lembrete: refactor só deve acontecer com aprovação explícita"
EOF_BIN

chmod +x "$BIN_DIR/codex-auto-refactor"

# =========================
# CUSTOM MODES / PROFILES
# =========================

write_file "$BIN_DIR/codex-new-mode" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-}"
PARTS_DIR="$HOME/.codex/parts"

if [[ -z "$NAME" ]]; then
  echo "Uso: codex-new-mode <nome>"
  exit 1
fi

TARGET="$PARTS_DIR/$NAME.md"
[[ ! -f "$TARGET" ]] || { echo "❌ Já existe: $TARGET"; exit 1; }

cat > "$TARGET" <<MODEFILE
## ${NAME^} Mode Rules

Describe here how Codex should behave in $NAME mode.
MODEFILE

echo "✅ Modo criado: $TARGET"
EOF_BIN

chmod +x "$BIN_DIR/codex-new-mode"

write_file "$BIN_DIR/codex-new-profile" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-}"
MODEL="${2:-gpt-5.4}"
APPROVAL="${3:-on-request}"
SANDBOX="${4:-workspace-write}"
CONFIG_FILE="$HOME/.codex/config.toml"

if [[ -z "$NAME" ]]; then
  echo "Uso: codex-new-profile <nome> [model] [approval_policy] [sandbox_mode]"
  exit 1
fi

{
  echo
  echo "[profiles.$NAME]"
  echo "model = \"$MODEL\""
  echo "approval_policy = \"$APPROVAL\""
  echo "sandbox_mode = \"$SANDBOX\""
} >> "$CONFIG_FILE"

echo "✅ Profile criado em $CONFIG_FILE: $NAME"
EOF_BIN

chmod +x "$BIN_DIR/codex-new-profile"

# =========================
# LINT / DOCTOR / LIST / DETECT
# =========================

write_file "$BIN_DIR/codex-lint-agents" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"

PROJECT_DIR="${1:-.}"
AGENTS_FILE="$(codex_agents_file "$PROJECT_DIR")"

[[ -f "$AGENTS_FILE" ]] || { echo "❌ AGENTS.md não encontrado."; exit 1; }

echo "🔎 Lintando $AGENTS_FILE"

grep -qi "tests" "$AGENTS_FILE" && echo "✅ regra de testes encontrada" || echo "⚠️ falta regra forte de testes"
grep -qi "approval" "$AGENTS_FILE" && echo "✅ regra de aprovação encontrada" || echo "⚠️ falta regra de aprovação"

LINES="$(wc -l < "$AGENTS_FILE" | tr -d ' ')"
echo "📏 Linhas: $LINES"

if [[ "$LINES" -gt 400 ]]; then
  echo "⚠️ AGENTS.md está longo; considere simplificar."
fi
EOF_BIN

chmod +x "$BIN_DIR/codex-lint-agents"

write_file "$BIN_DIR/codex-doctor" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

for f in \
  "$HOME/.codex/config.toml" \
  "$HOME/.codex/AGENTS.md" \
  "$HOME/.codex/AGENTS.override.md" \
  "$HOME/.codex/parts/global.md" \
  "$HOME/.local/bin/codex-build" \
  "$HOME/.local/bin/codex-mode" \
  "$HOME/.local/bin/codex-run" \
  "$HOME/.local/bin/codex-ci-run" \
  "$HOME/.local/bin/codex-pr-review" \
  "$HOME/.local/bin/codex-architecture-report"
do
  [[ -e "$f" ]] && echo "✅ $f" || echo "❌ $f"
done
EOF_BIN

chmod +x "$BIN_DIR/codex-doctor"

write_file "$BIN_DIR/codex-list-modes" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

PARTS_DIR="$HOME/.codex/parts"

echo "Modes disponíveis:"
echo
for file in "$PARTS_DIR"/*.md; do
  name="$(basename "$file" .md)"
  echo "- $name"
done
EOF_BIN

chmod +x "$BIN_DIR/codex-list-modes"

write_file "$BIN_DIR/codex-stack-detect" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.local/bin/codex-common.sh"
codex_detect_stack "${1:-.}"
EOF_BIN

chmod +x "$BIN_DIR/codex-stack-detect"

# =========================
# GIT HOOKS
# =========================

write_file "$BIN_DIR/codex-install-hooks" <<'EOF_BIN'
#!/usr/bin/env bash
set -euo pipefail

HOOKS_DIR=".git/hooks"

[[ -d ".git" ]] || {
  echo "❌ Not a git repo"
  exit 1
}

mkdir -p "$HOOKS_DIR"

cat > "$HOOKS_DIR/pre-commit" <<'HOOK'
#!/usr/bin/env bash
codex-lint-agents || {
  echo "❌ AGENTS.md lint failed"
  exit 1
}
HOOK

cat > "$HOOKS_DIR/commit-msg" <<'HOOK'
#!/usr/bin/env bash
MSG_FILE="$1"

grep -qE "^(feat|fix|chore|refactor|test):" "$MSG_FILE" || {
  echo "❌ Commit must follow Conventional Commits"
  exit 1
}
HOOK

chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/commit-msg"

echo "✅ Git hooks installed"
EOF_BIN

chmod +x "$BIN_DIR/codex-install-hooks"

# =========================
# SHELL SETUP
# =========================

ensure_shell_setup() {
  local rc_file="$1"
  touch "$rc_file"

  if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$rc_file"; then
    {
      echo
      echo '# Codex V8 tools'
      echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> "$rc_file"
  fi

  append_if_missing "$rc_file" 'alias cmdebug="codex-mode debug"'
  append_if_missing "$rc_file" 'alias cmreview="codex-mode review"'
  append_if_missing "$rc_file" 'alias cmci="codex-mode ci"'
  append_if_missing "$rc_file" 'alias cmdefault="codex-mode default"'
  append_if_missing "$rc_file" 'alias cmstatus="codex-status"'
  append_if_missing "$rc_file" 'alias cminit="codex-init"'
  append_if_missing "$rc_file" 'alias cmrun="codex-run"'
  append_if_missing "$rc_file" 'alias cmflow="codex-flow"'
}

ensure_shell_setup "$HOME/.zshrc"
ensure_shell_setup "$HOME/.bashrc"

echo "✅ Codex Toolkit V8 instalado"
echo
echo "Próximos passos:"
echo "1. source ~/.zshrc   ou   source ~/.bashrc"
echo "2. cd /seu/projeto"
echo "3. codex-init . auto"
echo "4. codex-run debug"
echo "5. codex-status"
