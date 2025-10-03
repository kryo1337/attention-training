FROM nginx:stable
WORKDIR /usr/share/nginx/html
COPY index.html ./index.html
COPY reaction.wasm ./reaction.wasm
COPY worker.js ./worker.js
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

