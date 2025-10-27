# Interview sandbox container
# Isolated environment for code review and security scanning

FROM ruby:3.3-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  curl \
  libpq-dev \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Install Rails and Bundler
RUN gem install rails bundler

# Create non-root user for security
RUN useradd -ms /bin/bash dev

# Switch to dev user
USER dev

# Set working directory
WORKDIR /workspace
