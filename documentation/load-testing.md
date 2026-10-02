# Load Testing Results

## Environment

- Date: October 2, 2026
- AWS Region: `us-west-2`
- Platform: Amazon ECS on AWS Fargate
- Load Balancer: Application Load Balancer
- Load-testing tool: Grafana k6 running locally in Docker

## Smoke Test

The smoke test used one virtual user for 10 seconds to verify that the deployed application responded correctly before applying additional load.

Results:

- Requests: 10
- Successful checks: 10/10
- Failed requests: 0%
- Average response time: 22.35 ms
- 95th-percentile response time: 25.5 ms

## Load Test

The load test gradually increased traffic to 10 concurrent virtual users, maintained the load, and then reduced it over two minutes.

Results:

- Requests: 650
- Successful checks: 650/650
- Failed requests: 0%
- Average response time: 22.1 ms
- 95th-percentile response time: 27.11 ms
- Maximum response time: 68.48 ms

All configured k6 performance thresholds passed.

## AWS Observations

CloudWatch recorded the 650-request traffic spike during the test.

- ECS CPU usage increased only slightly.
- Memory usage remained stable.
- The ALB target remained healthy.
- No unhealthy targets were detected.
- No application 5xx errors occurred.
- The CloudWatch CPU, 5xx-error, and unhealthy-target alarms remained in the `OK` state.

![CloudWatch dashboard showing the k6 load test](load-test-cloudwatch-dashboard.png)

## Conclusion

DeployGuard handled the tested workload without request failures, unhealthy targets, excessive CPU utilization, or application errors. These results describe this specific test workload and do not represent the maximum capacity of the service.

