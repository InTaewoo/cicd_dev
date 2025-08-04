FROM nginx:latest

# Copy the custom index.html to the nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Copy the 리소스 폴더 전체를 nginx html 디렉토리로 복사
COPY image/ /usr/share/nginx/html/image/

# Expose port 80
EXPOSE 80 
