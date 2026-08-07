# k6

간단한 k6 로드테스트 스캐폴드입니다. 스크립트는 `loadtest/`에 있습니다.

## 필수

- `BASE_URL` (테스트 대상)
- `TYPE` — `offset` 또는 `cursor`

## Env 전략

- 자주 바뀌지 않는 값(예: `BASE_URL`)은 `.env`에 둡니다.
- 실행마다 바뀌는 값(예: `TYPE`, `VUS`, `DURATION`)은 커맨드라인으로 전달합니다.

## 예

```bash
cp .env.example .env
# .env에서 BASE_URL 설정
TYPE=offset VUS=50 DURATION=30s make pagination
```

## 테스트 목록

- 페이지네이션: `loadtest/pagination.js`
    - offset: `TYPE=offset VUS=50 DURATION=30s make pagination`
    - cursor: `TYPE=cursor VUS=50 DURATION=30s make pagination`