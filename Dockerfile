FROM nginx:alpine
COPY nginx_internal.conf /etc/nginx/nginx.conf
EXPOSE 8536
CMD ["nginx", "-g", "daemon off;"]
