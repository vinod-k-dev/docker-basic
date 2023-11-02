#!/bin/bash

until cd /home/user/service/; do
  echo "Waiting for server volume..."
done

echo "SERVER-START.sh >>>> " $(pwd)

until poetry run python manage.py migrate; do
  echo "Waiting for db to be ready..."
  sleep 1
done

# Takes a long time hence running this in background - else the server will not start and health check will fail prematurely.
echo "Let's collectstatic >>> "
poetry run python manage.py collectstatic --noinput -v0 &
echo "[DONE] collectstatic >>> "

#poetry run celery --workdir=universal/  -A config worker --loglevel=info --concurrency 1 -E --beat &
echo "Local server runserver >>> "
poetry run python manage.py runserver 0.0.0.0:8001
