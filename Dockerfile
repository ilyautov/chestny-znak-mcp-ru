# syntax=docker/dockerfile:1
# chestny-znak-mcp-ru as a container: API Честного знака (ГИС МТ и СУЗ) для
# ИИ-ассистента. Это тот артефакт, который официальный MCP Registry публикует
# как OCI-пакет (ghcr.io/ilyautov/chestny-znak-mcp-ru:<version>).
#
#   docker run -i --rm -e CRPT_TOKEN=... ghcr.io/ilyautov/chestny-znak-mcp-ru
#
# Зависимости чисто питоновские, поэтому хватает одной slim-стадии; исходники
# удаляются после установки, в образе остаётся только установленный пакет.
# Версия Python закреплена намеренно.
FROM python:3.12-slim

# Метка владения, которую MCP Registry проверяет у OCI-пакетов: должна совпадать
# с полем "name" из server.json.
LABEL io.modelcontextprotocol.server.name="io.github.ilyautov/chestny-znak-mcp-ru" \
      org.opencontainers.image.title="chestny-znak-mcp-ru" \
      org.opencontainers.image.description="Chestny ZNAK (GIS MT & SUZ) product marking APIs in your AI assistant — schema-driven, safety-gated MCP server" \
      org.opencontainers.image.source="https://github.com/ilyautov/chestny-znak-mcp-ru" \
      org.opencontainers.image.licenses="MIT"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

COPY pyproject.toml README.md LICENSE /src/
COPY crpt_mcp/ /src/crpt_mcp/

RUN pip install /src \
    && rm -rf /src /root/.cache \
    && useradd --create-home --uid 1000 mcp

USER mcp

# Сервер общается по stdio, порт не открывается.
ENTRYPOINT ["chestny-znak-mcp-ru"]
