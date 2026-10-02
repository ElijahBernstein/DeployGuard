import http from "k6/http";
import { check, sleep } from "k6";

export const options = {
  stages: [
    { duration: "30s", target: 5 },
    { duration: "1m", target: 10 },
    { duration: "30s", target: 0 },
  ],

  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"],
    checks: ["rate>0.99"],
  },
};

export default function () {
  if (!__ENV.BASE_URL) {
    throw new Error("BASE_URL is required");
  }

  const response = http.get(`${__ENV.BASE_URL}/`);

  check(response, {
    "root endpoint returns 200": (result) => result.status === 200,
  });

  sleep(1);
}