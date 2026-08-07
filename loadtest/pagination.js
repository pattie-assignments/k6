import http from 'k6/http';
import { check } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const TYPE = __ENV.TYPE || 'offset';

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

export default function () {
  let url;

  if (TYPE === 'offset') {
    url = `${BASE_URL}/posts/offset?page=5000&size=20`;
  } else {
    url = `${BASE_URL}/posts/cursor?cursor=여기에_실제_cursor&size=20`;
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