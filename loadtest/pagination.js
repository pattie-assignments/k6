import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const TYPE = __ENV.TYPE || 'offset';
const LIMIT = Number(__ENV.LIMIT || 20);
const OFFSET = Number(__ENV.OFFSET || 100000);
const CURSOR_DEPTH_PAGES = Number(__ENV.CURSOR_DEPTH_PAGES || 5000);

function buildOffsetUrl(offset) {
  return `${BASE_URL}/posts?offset=${offset}&limit=${LIMIT}`;
}

function buildCursorUrl(cursor) {
  const query = cursor == null ? `limit=${LIMIT}` : `cursor=${cursor}&limit=${LIMIT}`;
  return `${BASE_URL}/posts/cursor?${query}`;
}

export function setup() {
  if (TYPE !== 'cursor') {
    return null;
  }

  let cursor = null;

  for (let page = 0; page < CURSOR_DEPTH_PAGES; page += 1) {
    const res = http.get(buildCursorUrl(cursor), {
      tags: {
        pagination: TYPE,
        phase: 'setup',
      },
    });

    check(res, {
      'setup status is 200': (r) => r.status === 200,
    });

    if (res.status !== 200) {
      throw new Error(`Failed to fetch cursor page at depth ${page}: ${res.status}`);
    }

    const body = res.json();
    const data = body?.data;

    if (!data) {
      throw new Error(`Missing response data at cursor depth ${page}`);
    }

    if (!data.has_next || data.next_cursor == null) {
      throw new Error(
        `Unable to reach cursor depth ${CURSOR_DEPTH_PAGES}. Stopped at page ${page + 1}.`,
      );
    }

    cursor = data.next_cursor;
  }

  return { cursor };
}

// k6에서 실제로 반복 실행되는 기본 함수
export const options = {
  discardResponseBodies: true,

  scenarios: {
    pagination_load: {
      executor: 'constant-arrival-rate',

      rate: 100,
      timeUnit: '1s',

      duration: '1m',

      preAllocatedVUs: 100,
      maxVUs: 300,
    },
  },

  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
  },
};

export default function (data) {
  let url;

  if (TYPE === 'offset') {
    url = buildOffsetUrl(OFFSET);
  } else {
    url = buildCursorUrl(data?.cursor ?? null);
  }

  const res = http.get(url, {
    tags: {
      pagination: TYPE,
    },
  });

  check(res, {
    'status is 200': (r) => r.status === 200,
  });
}
