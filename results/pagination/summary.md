# Pagination 성능 비교 결과

## 1. 테스트 목적

Offset Pagination과 Cursor Pagination의 조회 성능을 비교한다.
조회 깊이가 증가할수록 각 방식의 응답시간과 처리 성능이 어떻게 변화하는지 확인한다.

---

## 2. 테스트 환경

### 서버
- Application: EC2
- Database: PostgreSQL
- Load Test: k6

### 테스트 조건
- 요청률: 100 RPS
- 테스트 시간: 1분
- LIMIT: 20
- 반복 횟수: 각 조건 3회
- 테스트 간 휴식: 1분
- 대표값: 3회 측정 p95의 중앙값

### 비교 Depth

| Depth | Offset | Cursor Depth Pages |
|---:|---:|---:|
| 1,000 | 1,000 | 50 |
| 10,000 | 10,000 | 500 |
| 50,000 | 50,000 | 2,500 |

---

## 3. 측정 지표

- **p95**: 전체 요청 중 95%가 완료된 응답시간 (주요 비교 지표)
- **avg**: 평균 응답시간
- **HTTP Error Rate**: HTTP 요청 실패율
- **Dropped Iterations**: 목표 RPS를 맞추지 못해 실행하지 못한 요청 수
- **VU**: 부하를 발생시키기 위해 사용된 Virtual User 수

---

## 4. 테스트 결과

### Depth 1,000

| 방식 | 1회 p95 | 2회 p95 | 3회 p95 | 중앙값 |
|---|---:|---:|---:|---:|
| Offset | 5.84ms | 5.71ms | 5.72ms | 5.72ms |
| Cursor | 5.33ms | 4.99ms | 4.98ms | 4.99ms |

### Depth 10,000

| 방식 | 1회 p95 | 2회 p95 | 3회 p95 | 중앙값 |
|---|---:|---:|---:|---:|
| Offset | 22.78ms | 12.21ms | 12.11ms | 12.21ms |
| Cursor | 5.03ms | 5.78ms | 4.99ms | 5.03ms |

### Depth 50,000

| 방식 | 1회 p95 | 2회 p95 | 3회 p95 | 중앙값 |
|---|---:|---:|---:|---:|
| Offset | 9.56s | 9.44s | 9.45s | 9.45s |
| Cursor | 4.97ms | 6.62ms | 5.89ms | 5.89ms |

---

## 5. 최종 비교

| Depth | Offset p95 | Cursor p95 | 개선율 | Offset Dropped | Cursor Dropped |
|---:|---:|---:|---:|---:|---:|
| 1,000 | 5.72ms | 4.99ms | 12.7% | 0 | 0 |
| 10,000 | 12.21ms | 5.03ms | 58.8% | 18 | 0 |
| 50,000 | 9.45s | 5.89ms | 99.94% | 2,532–2,856 | 0 |

개선율:

`(Offset p95 - Cursor p95) / Offset p95 × 100`

---

## 6. 결과 분석

### Depth 1,000

- Offset과 Cursor 모두 100 RPS를 안정적으로 유지했다.
- Offset p95는 5.72ms, Cursor p95는 4.99ms로 차이가 크지 않았다.

### Depth 10,000

- Offset p95가 12.21ms로 상승하며 응답시간이 커지기 시작했다.
  이 조건에서 일부 Dropped Iterations가 발생해 100 RPS 유지가 약간 약화됐다.
- Cursor는 5.03ms 수준을 유지하며 깊은 조회에서도 안정적으로 동작했다.

### Depth 50,000

- Offset p95는 9.45초로 급격히 증가했다.
  이 조건에서 목표 100 RPS를 유지하지 못했고 실제 처리량이 48–53 RPS 수준으로 떨어졌다.
  2,500개 이상의 Dropped Iterations가 발생했다.
- Cursor는 p95 5.89ms 수준을 유지하며 깊은 조회에서도 안정적이었다.

---

## 7. 결론

Depth가 증가할수록 Offset Pagination의 응답시간이 크게 증가한다.

- 특히 50,000 깊이에서는 Offset이 100 RPS를 유지하지 못하면서 성능이 급격히 저하되었다.
- 반면 Cursor Pagination은 Depth가 커져도 p95가 5~6ms 수준으로 안정적으로 유지되었다.

따라서 동일 서버/DB/데이터 조건에서 깊은 페이지 조회가 예상되는 경우, Offset Pagination보다 Cursor Pagination이 더 적합하다.