# ExamTopics Scraper
Scrape exam questions from ExamTopics discussions page.

## Getting Started
1. Clone this repo
```sh
git clone https://github.com/AwkwardPhantom/examtopics-scraper-sqlite.git
cd examtopics-scraper-sqlite
```
2. Install dependencies
```sh
npm ci
```
3. (no longer needed in the SQLite version) Add `.env` file.
```sh
NEXTAUTH_ADMIN_USER=admin
NEXTAUTH_ADMIN_PASSWORD=password
NEXTAUTH_SECRET=secret
NEXTAUTH_URL=http://localhost:3000
POSTGRES_PRISMA_URL=postgres://...
```
4. Build database client
```sh
npx prisma generate
```
5. (Optional) For new database, initialize and seed tables
```sh
npx prisma db push
npx prisma db seed
```
6. Run development server
```sh
npm run dev
```
7. Open `http://localhost:3000` in browser

## Docker
1. Prepare Docker builder
```sh
docker buildx create --name mybuilder --use
docker buildx inspect --bootstrap
```
2. Build
```sh
docker buildx build --platform linux/amd64 -t examtopixlite --load .
```
3. Run
```sh
docker run -d -p 3000:3000 --name examtopixlite examtopixlite
```
