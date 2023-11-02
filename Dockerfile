# pull official image
FROM python:3

ARG PROJECT=service

#USER user
WORKDIR /home/user/$PROJECT

# prevents Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1
# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

# Configure Poetry
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
ENV POETRY_VERSION=1.4.2
ENV POETRY_HOME=.poetry
ENV POETRY_VENV=.poetry-venv
ENV POETRY_CACHE_DIR=.cache

# Install poetry separated from system interpreter
RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry==${POETRY_VERSION}


# Add `poetry` to PATH
ENV PATH="${PATH}:/home/user/$PROJECT/${POETRY_VENV}/bin"


WORKDIR /home/user/$PROJECT
# Copy only requirements to cache them in docker layer
COPY ./pyproject.toml ./poetry.lock ./

# [OPTIONAL] Validate the project is properly configured
RUN poetry check

# Install Dependencies
RUN poetry install --no-interaction --no-cache

# Creating folders, and files for a project:
COPY . .

# Create a new .env from .env
COPY .env .env
RUN echo "ECHO .env file created for local docker!"

RUN chmod +x scripts/*.sh
RUN echo "hello there $PATH"