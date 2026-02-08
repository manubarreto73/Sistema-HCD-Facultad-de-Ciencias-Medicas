FROM ruby:3.2.2

ENV DEBIAN_FRONTEND=noninteractive

# Dependencias del sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libsqlite3-dev \
  wkhtmltopdf \
  nodejs \
  && rm -rf /var/lib/apt/lists/*

# Carpeta de la app
WORKDIR /app

# Gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Código
COPY . .

# Precompila tailwind
RUN bin/rails tailwindcss:build

# Puerto Rails
EXPOSE 3000

# Comando por defecto
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
