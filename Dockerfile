# Stage 1: Builder
FROM ubuntu:22.04 as builder

# Install Zig 0.15.2
RUN apt-get update && apt-get install -y wget xz-utils
RUN wget https://ziglang.org/download/0.15.2/zig-linux-x86_64-0.15.2.tar.xz
RUN tar -xf zig-linux-x86_64-0.15.2.tar.xz
RUN mv zig-linux-x86_64-0.15.2 /usr/local/share/zig
ENV PATH="/usr/local/share/zig:${PATH}"

# Copy project files and build
WORKDIR /app
COPY . .
RUN zig build copy-wasm

# Stage 2: Final Image
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
COPY index.html ./index.html
COPY worker.js ./worker.js
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/reaction.wasm ./reaction.wasm

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]