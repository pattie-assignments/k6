# k6

간단한 k6 로드테스트 스캐폴드입니다. 스크립트는 `loadtest/`에 있습니다.

## 필수

- `BASE_URL` (테스트 대상)
- `TYPE` — `offset` 또는 `cursor`

## 선택 Env

- `LIMIT` — 페이지 크기, 기본값 `20`
- `OFFSET` — offset 테스트 시 사용할 시작 위치, 기본값 `100000`
- `CURSOR_DEPTH_PAGES` — cursor 테스트 시 `setup()`에서 미리 따라갈 페이지 수, 기본값 `5000`

`cursor` 테스트는 `setup()`에서 `next_cursor`를 따라가며 원하는 깊이의 cursor를 구한 뒤 본 테스트에 사용합니다. (`deep offset`과 동일한 깊이로 비교하기 위함)

## Env 전략

- 자주 바뀌지 않는 값(예: `BASE_URL`)은 `.env`에 둡니다.
- 실행마다 바뀌는 값(예: `TYPE`, `OFFSET`, `CURSOR_DEPTH_PAGES`)은 커맨드라인으로 전달합니다.

## 예

```bash
cp .env.example .env
# .env에서 BASE_URL 설정
make pagination TYPE=offset OFFSET=100000 LIMIT=20
```

## 테스트 목록

- 페이지네이션: `loadtest/pagination.js`
  - offset: `make pagination TYPE=offset OFFSET=100000 LIMIT=20`
  - cursor: `make pagination TYPE=cursor CURSOR_DEPTH_PAGES=5000 LIMIT=20`
