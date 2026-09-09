#!/usr/bin/env bash
# fck eval runner — pure bash + pi + jq. No node, no npm.
#
# Usage:
#   run.sh                                     # all cases, default model, both arms
#   run.sh --model openrouter,z-ai/glm-5.3-flash
#   run.sh --model openrouter,z-ai/glm-5.3-flash --model openrouter,anthropic/claude-sonnet-5
#   run.sh --kind trigger,negative
#   run.sh --arm kit                            # skip the no-kit baseline
#
# Every case runs once per (model, arm). Arm "kit" loads this repo's four
# skills via --skill; arm "no-kit" is the baseline (--no-skills). The
# interesting output is the DELTA between arms, not absolute scores.
#
# Env: OPENROUTER_API_KEY must be set (or pi already authenticated).
#      JUDGE_MODEL overrides the judge (default: openrouter,anthropic/claude-opus-4.7).

set -uo pipefail

EVAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_DIR="$(dirname "$EVAL_DIR")"
SKILL_NAMES=(fck for-fucks-sake no-shit would-you-please-fucking-stop)

# ------------------------------------------------------------------ args

MODELS=(); KINDS=(); ARMS=(kit no-kit); JUDGE="${JUDGE_MODEL:-openrouter,~anthropic/claude-opus-latest}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODELS+=("$2"); shift 2 ;;
    --kind)  IFS=',' read -ra KINDS <<< "$2"; shift 2 ;;
    --arm)   IFS=',' read -ra ARMS <<< "$2"; shift 2 ;;
    --judge) JUDGE="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done
[[ ${#MODELS[@]} -eq 0 ]] && MODELS=("openrouter,z-ai/glm-5.3-flash")
JUDGE_PROVIDER="${JUDGE%%,*}"; JUDGE_ID="${JUDGE#*,}"

command -v pi >/dev/null || { echo "pi not found in PATH" >&2; exit 1; }
command -v jq >/dev/null  || { echo "jq is required" >&2; exit 1; }

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
RUN_DIR="$EVAL_DIR/results/$RUN_ID"
mkdir -p "$RUN_DIR/cases"

# ------------------------------------------------------------- helpers

# Extract the final assistant text from a pi --mode json transcript (raw).
extract_response() {
  jq -rs '[.[] | select(.type=="message_end") | .message | select(.role=="assistant")]
         | last | .content | map(select(.type=="text") | .text) | join("\n")' "$1" 2>/dev/null
}

# Total cost from all message_end events.
extract_cost() {
  jq -s '[.[] | select(.type=="message_end") | .message.usage.cost.total // 0] | add // 0' "$1"
}

# Deterministic checks -> checks.json
run_checks() {
  local case_json="$1" response="$2" out="$3"
  jq -n --slurpfile case "$case_json" --arg resp "$response" '
    [ ($case[0].expect.must // [])[]           | . as $chk | {type: "must",           check: ., pass: ($resp | test($chk; "i"))} ]
  + [ ($case[0].expect.must_not // [])[]       | . as $chk | {type: "must_not",       check: ., pass: ($resp | test($chk; "i") | not)} ]
  + [ ($case[0].expect.must_not_regex // [])[] | . as $chk | {type: "must_not_regex", check: ., pass: ($resp | test($chk; "i") | not)} ]
  ' > "$out"
}

# LLM-as-judge -> judge.json
run_judge() {
  local case_json="$1" case_id="$2" input="$3" work="$4" provider="$5" id="$6"
  local ground judge_hints prompt judge_raw

  ground="$(jq -r .groundTruth "$case_json")"
  judge_hints="$(jq -r '.judgeHints // empty' "$case_json")"
  local context_file="$work/context.md"

  judge_input="$(mktemp)"
  {
    cat "$EVAL_DIR/judge.md"
    echo; echo "## Ground truth";            echo "$ground"
    [[ -n "$judge_hints" ]] && { echo; echo "## Calibration notes"; echo "$judge_hints"; }
    echo; echo "## Sandbox context";         sed 's/^/    /' "$context_file"
    echo; echo "## Files in the working directory"
    (cd "$work/sandbox" && find . -type f | sort | while read -r f; do
       echo "--- $f ---"; sed 's/^/    /' "$f"; done)
    echo; echo "## User message";            echo "$input"
    echo; echo "## Agent response";          echo "$(<"$work/response.md")"
  } > "$judge_input"

  if timeout 300 pi -p --mode json --no-session --no-skills \
       --model "$provider/$id" "$(cat "$judge_input")" \
       > "$work/judge-transcript.jsonl" 2>>"$work/error.log"; then
    judge_out="$(extract_response "$work/judge-transcript.jsonl")"
    parsed="$(printf '%s' "$judge_out" | jq -Rs 'capture("(?<j>\\{[\\s\\S]*\\})") | .j | fromjson | {lines, total, max, verdict}' 2>/dev/null)"
    if [[ -n "$parsed" ]]; then
      printf '%s' "$parsed" > "$work/judge.json"
    else
      echo '{"lines":[],"total":0,"max":14,"verdict":"judge output unparseable"}' > "$work/judge.json"
    fi
  else
    echo '{"lines":[],"total":0,"max":14,"verdict":"judge call failed"}' > "$work/judge.json"
  fi
  rm -f "$judge_input"
}

# ------------------------------------------------------------------ run

echo "run $RUN_ID — models: ${MODELS[*]} — arms: ${ARMS[*]} ${KINDS:+— kinds: ${KINDS[*]}}" >&2

for case_dir in "$EVAL_DIR"/cases/*/; do
  case_json="$case_dir/case.json"
  case_id="$(basename "$case_dir")"
  kind="$(jq -r .kind "$case_json")"
  if [[ -n "${KINDS:-}" ]]; then
    keep=0; for k in "${KINDS[@]}"; do [[ "$k" == "$kind" ]] && keep=1; done
    [[ $keep -eq 0 ]] && continue
  fi

  for model in "${MODELS[@]}"; do
    provider="${model%%,*}"; id="${model#*,}"
    model_slug="$(echo "$id" | tr '/.' '--')"

    for arm in "${ARMS[@]}"; do
      work="$RUN_DIR/cases/$case_id/$model_slug.$arm"
      mkdir -p "$work"
      cp -r "$case_dir/sandbox" "$work/sandbox"

      # context.md: scripted prior turns + last command (stdin-merged into the prompt)
      {
        if jq -e '.script | length > 0' "$case_json" >/dev/null 2>&1; then
          echo "Earlier in this session:"
          echo
          jq -r '.script[] | "User: \(.user)\n\nAssistant: \(.assistant)\n"' "$case_json"
          echo
        fi
        if jq -e '.lastCommand != null and .lastCommand != ""' "$case_json" >/dev/null 2>&1; then
          echo "Last command and its output:"
          echo
          jq -r .lastCommand "$case_json"
        fi
      } > "$work/context.md"

      # skills flags: explicit kit paths still load under --no-skills
      skill_flags=(--no-skills)
      if [[ "$arm" == "kit" ]]; then
        for s in "${SKILL_NAMES[@]}"; do
          skill_flags+=(--skill "$KIT_DIR/skills/$s")
        done
      fi

      input="$(jq -r .input "$case_json")"
      echo "  $case_id [$arm] $provider/$id" >&2

      if ( cd "$work/sandbox" && timeout 300 \
           pi -p --mode json --no-session "${skill_flags[@]}" \
              --model "$provider/$id" \
              "$input" ) \
           < "$work/context.md" \
           > "$work/transcript.jsonl" 2>>"$work/error.log"; then
        extract_response "$work/transcript.jsonl" > "$work/response.md"
      else
        echo "runner error (see transcript.jsonl/err)" > "$work/response.md"
      fi
      extract_cost "$work/transcript.jsonl" > "$work/cost.txt"

      run_checks "$case_json" "$(cat "$work/response.md")" "$work/checks.json"
      run_judge "$case_json" "$case_id" "$input" "$work" "$JUDGE_PROVIDER" "$JUDGE_ID"
    done
  done
done

# ------------------------------------------------------------- summary

summary="$RUN_DIR/summary.md"
{
  echo "# fck eval — run $RUN_ID"
  echo
  echo "models: ${MODELS[*]} · arms: ${ARMS[*]} · judge: $JUDGE_PROVIDER/$JUDGE_ID"
  echo
  echo "| case | kind | model | arm | det | judge | cost |"
  echo "|---|---|---|---|---|---|"
  for d in "$RUN_DIR"/cases/*/*/; do
    [[ -d "$d" ]] || continue
    rel="${d#"$RUN_DIR"/cases/}"
    case_id="${rel%%/*}"; slug="${rel#*/}"
    kind="$(jq -r .kind "$EVAL_DIR/cases/$case_id/case.json")"
    det_pass="$(jq '[.[] | select(.pass)] | length' "$d/checks.json" 2>/dev/null)"
    det_total="$(jq 'length' "$d/checks.json" 2>/dev/null)"
    jtotal="$(jq -r '.total // "?"' "$d/judge.json" 2>/dev/null)"
    jmax="$(jq -r '.max // "?"' "$d/judge.json" 2>/dev/null)"
    cost="$(cat "$d/cost.txt" 2>/dev/null)"
    echo "| $case_id | $kind | ${slug%%.*} (${slug#*.}) | $det_pass/$det_total | $jtotal/$jmax | \$$cost |"
  done
} > "$summary"

# verdict.md per case: kit vs no-kit side by side (only when both arms ran)
for case_dir in "$EVAL_DIR"/cases/*/; do
  case_id="$(basename "$case_dir")"
  mkdir -p "$RUN_DIR/cases/$case_id"
  if ! find "$RUN_DIR/cases/$case_id" -maxdepth 1 -type d -name '*.*' 2>/dev/null | grep -q .; then
    continue
  fi
  {
    echo "# $case_id — $(jq -r .kind "$case_dir/case.json")"
    echo
    echo "**Input:** \`$(jq -r .input "$case_dir/case.json")\`"
    echo
    echo "**Ground truth:** $(jq -r .groundTruth "$case_dir/case.json")"
    echo
    for d in "$RUN_DIR"/cases/$case_id/*.*; do
      [[ -d "$d" ]] || continue
      arm_dir="$(basename "$d")"
      echo "## $arm_dir"
      echo
      echo "checks: $(jq '[.[] | select(.pass)] | length' "$d/checks.json" 2>/dev/null)/$(jq 'length' "$d/checks.json" 2>/dev/null) · judge: $(jq -r '.total // "?"' "$d/judge.json" 2>/dev/null)/$(jq -r '.max // "?"' "$d/judge.json" 2>/dev/null) — $(jq -r '.verdict // ""' "$d/judge.json" 2>/dev/null)"
      echo
      echo '```'
      cat "$d/response.md"
      echo '```'
      echo
    done
  } > "$RUN_DIR/cases/$case_id/verdict.md"
done

echo "results → $RUN_DIR" >&2
