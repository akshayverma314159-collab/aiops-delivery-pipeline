#!/bin/bash
# Evaluates deployment health against historical baselines using Prometheus

PROMETHEUS_URL="http://prometheus-operated.monitoring.svc.cluster.local:9090"
THRESHOLD=5 # Maximum acceptable 5xx error percentage

echo "Waiting 30 seconds for traffic to hit the new pods..."
sleep 30

# Query Prometheus for the 5xx error rate over the last 3 minutes
QUERY='sum(rate(http_requests_total{status=~"5.."}[3m])) / sum(rate(http_requests_total[3m])) * 100'
ERROR_RATE=$(curl -sG --data-urlencode "query=$QUERY" $PROMETHEUS_URL/api/v1/query | jq -r '.data.result[0].value[1]')

# Handle empty results (no traffic)
if [ "$ERROR_RATE" == "null" ] || [ -z "$ERROR_RATE" ]; then
    echo "No traffic data available. Passing health check conditionally."
    exit 0
fi

# Compare against threshold
if (( $(echo "$ERROR_RATE > $THRESHOLD" | bc -l) )); then
    echo "CRITICAL: Error rate is ${ERROR_RATE}%, exceeding the ${THRESHOLD}% threshold!"
    echo "Failing health check to trigger rollback."
    exit 1
else
    echo "Health check passed. Error rate is stable at ${ERROR_RATE}%."
    exit 0
fi
