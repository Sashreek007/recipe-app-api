#Use a small Python base image

FROM python:3.9-alpine3.13

#Metadata
LABEL maintainer="shrek" 

#Makes Python output logs instantly (useful for Docker logs)
ENV PYTHONUNBUFFERED=1


COPY ./requirements.txt /tmp/requirements.txt

COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy app code to container
COPY ./app /app
# Set working directory
WORKDIR /app
# Expose port 8000 for app (e.g., Django server)
EXPOSE 8000

ARG DEV=false
# Create virtual env at /py
RUN python -m venv /py && \
  # Upgrade pip in the venv
  /py/bin/pip install --upgrade pip && \
  # Install Python deps
  /py/bin/pip install -r /tmp/requirements.txt && \
  if [$DEV = "true"]; \
  then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
  fi && \
  # Clean up
  rm -rf /tmp && \
  adduser \
  --disabled-password \
  --no-create-home \
  # Create a non-root user for safety
  django-user

# Add virtualenv to PATH
ENV PATH="/py/bin:$PATH"

# Run the container as this unprivileged user
USER django-user
