FROM python:3.12 as builder
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN mkdir -p /meilisync
WORKDIR /meilisync
COPY pyproject.toml poetry.lock /meilisync/
ENV POETRY_VIRTUALENVS_CREATE false
RUN pip3 install poetry && poetry install --no-root -E mysql -E postgres
COPY . /meilisync
RUN poetry install -E all

FROM python:3.12.2-alpine
WORKDIR /meilisync
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /meilisync /app
RUN addgroup -g 1001 app && adduser app -u 1001 -D -G app
RUN chown -R app:app /app
USER app
CMD ["meilisync", "start"]
