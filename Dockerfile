FROM grafana/k6:latest
COPY loadtest/script.js /script.js
ENTRYPOINT ["k6", "run", "/script.js"]
