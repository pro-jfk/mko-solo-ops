FROM oven/bun AS build
WORKDIR /app
COPY . .
COPY package.json  .
RUN bun install
RUN bun run build

EXPOSE 3000
ENV BUN_PORT=3000
ENTRYPOINT [ "bun", "run", "dev" ]