# Para copiar os resultados de uma VM para sua máquina local
seq 1 10 | xargs -I XXX scp -r -i ~/.ssh/doritos.pem ubuntu@10.11.19.173:"/home/ubuntu/serverless-memory-benchmark/experiment-scripts/exp-Epsilon-dynamic-html-XXX/" ./



