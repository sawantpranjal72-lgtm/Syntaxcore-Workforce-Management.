# Stage 1: Build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --silent
COPY . .
RUN npm run build -- --configuration production

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=build /app/dist/frontend/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
# SSL certs are NOT baked into the image — mount them at runtime into
# /etc/nginx/ssl (see docker-compose.yml / deployment steps). This keeps
# certs out of the image and lets renewal (certbot) update them in place
# without a rebuild.
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
