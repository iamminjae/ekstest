# 베이스 이미지 설정
FROM node:14

# 앱 디렉토리 생성
WORKDIR /usr/src/app

# package.json과 package-lock.json을 복사
# COPY package*.json ./
COPY src/package*.json ./

# 의존성 설치
RUN npm install

# 애플리케이션 소스 코드 복사
# COPY . .
COPY src/. .

# 앱이 8080 포트를 사용한다고 가정
EXPOSE 8080

# 웹 서버 실행
CMD [ "node", "index.js" ]