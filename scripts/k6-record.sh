#!/usr/bin/env bash
set -euo pipefail

# usage: print help text and exit
usage() {
  cat <<'EOF'
Usage:
  ./scripts/k6-record.sh <command> [args...]
  ./scripts/k6-record.sh -o <output-file> -- <command> [args...]

Examples:
  ./scripts/k6-record.sh make pagination TYPE=offset OFFSET=1000 LIMIT=20
  ./scripts/k6-record.sh -o results/pagination-offset-1000.log -- make pagination TYPE=offset OFFSET=1000 LIMIT=20
EOF
  exit 1
}

# 최소 하나의 인자가 필요함
if [ "$#" -lt 1 ]; then
  usage
fi

# 명시적 출력 파일 지정 옵션 처리
explicit_output=""
if [ "$1" = "-o" ]; then
  shift
  # -o 다음에는 출력 파일 경로와 실행할 명령어가 있어야 함
  if [ "$#" -lt 3 ] || [ "$1" = "--" ]; then
    usage
  fi
  explicit_output="$1"
  shift
fi

# --가 있으면 제거하고 실제 명령어 인자만 남김
if [ "$#" -ge 1 ] && [ "$1" = "--" ]; then
  shift
fi

# 실행할 명령어가 남아야 함
if [ "$#" -lt 1 ]; then
  usage
fi

# 남은 인자를 명령어 배열로 저장
cmd=("$@")

# 출력 파일 자동 생성
if [ -z "$explicit_output" ]; then
  timestamp=$(date '+%Y%m%d-%H%M%S')
  # 명령어 앞부분을 슬러그로 만들어 파일명에 포함
  slug=$(printf '%s-' "${cmd[@]:0:4}" | tr ' ' '-' | tr -c '[:alnum:]_.+-' '-' | sed 's/-$//' | cut -c1-80)
  OUTPUT_FILE="results/${timestamp}-${slug}.log"
else
  OUTPUT_FILE="$explicit_output"
fi

# 결과 디렉터리 생성
mkdir -p "$(dirname "$OUTPUT_FILE")"

# 기록 파일에 명령어와 구분선 출력
printf 'COMMAND: %s\n\n' "${cmd[*]}" > "$OUTPUT_FILE"
printf '==== OUTPUT ====\n\n' >> "$OUTPUT_FILE"

# 명령어 실행 결과를 stdout과 파일에 동시에 기록
"${cmd[@]}" 2>&1 | tee -a "$OUTPUT_FILE"

# 최종 저장 위치 알림을 stderr로 출력
echo "Saved output to $OUTPUT_FILE" >&2
