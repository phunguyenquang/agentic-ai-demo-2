# Stack recipes — lệnh mẫu để thay khối STACK-BINDING

> Đây là điểm khởi đầu, không phải quy định. SA điều chỉnh theo ADR-001 (phiên bản, công cụ cụ thể).
> Phiên bản action GitHub ghi dưới đây là bản ổn định tại thời điểm viết kit; kiểm tra lại bản mới nhất khi áp dụng.

## Node.js / TypeScript (npm)

**lint.sh**
```bash
npm ci --no-audit --no-fund
npx eslint . --max-warnings=0
npx prettier --check .
npx tsc --noEmit
```
**test.sh** (Vitest; Jest tương tự với `--ci --reporters=default --reporters=jest-junit`)
```bash
npm ci --no-audit --no-fund
mkdir -p test-results
npx vitest run --coverage --reporter=default --reporter=junit --outputFile.junit=test-results/junit.xml "$@"
```
**build.sh**
```bash
npm ci --no-audit --no-fund
npm run build
```
**audit.sh**
```bash
npm audit --audit-level=high
```
**format-file.sh** (khối case)
```bash
case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.yml|*.yaml)
    run_if_exists "node_modules/.bin/prettier" --write "$FILE"
    case "$FILE" in *.ts|*.tsx|*.js|*.jsx) run_if_exists "node_modules/.bin/eslint" --max-warnings=0 "$FILE" ;; esac ;;
esac
```
**ci.yml – STACK-SETUP**
```yaml
      - uses: actions/setup-node@v4
        with:
          node-version-file: '.nvmrc'
          cache: 'npm'
```
**sensitive-paths bổ sung:** `src/middleware/auth*`, `src/**/guards/*`, `prisma/migrations/*` hoặc `migrations/*`, `src/config/security*`.

## Java / Spring Boot (Maven)

**lint.sh**: `./mvnw -B -q spotless:check` (hoặc `checkstyle:check`)
**test.sh**: `./mvnw -B test` — báo cáo ở `target/surefire-reports/` → thêm `mkdir -p test-results && cp target/surefire-reports/*.xml test-results/ 2>/dev/null || true`
**build.sh**: `./mvnw -B -DskipTests package`
**audit.sh**: `./mvnw -B org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7` (lần đầu tải dữ liệu lâu; cân nhắc chạy theo lịch)
**format-file.sh**: `*.java) run_if_exists ./mvnw -q spotless:apply -DspotlessFiles="$FILE" ;;`
**ci.yml – STACK-SETUP**
```yaml
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'
          cache: 'maven'
```
Gradle: thay bằng `./gradlew spotlessCheck`, `./gradlew test`, `./gradlew assemble`, `cache: 'gradle'`.
**sensitive-paths bổ sung:** `src/main/java/*/security/*`, `src/main/resources/db/migration/*`, `src/main/resources/application-prod*`.

## .NET

**lint.sh**: `dotnet format --verify-no-changes`
**test.sh**: `dotnet test --logger "trx;LogFileName=results.trx" --results-directory test-results --collect:"XPlat Code Coverage"`
**build.sh**: `dotnet build -c Release --no-restore` (chạy `dotnet restore` trước)
**audit.sh**: `dotnet list package --vulnerable --include-transitive 2>&1 | tee /dev/stderr | grep -qiE "critical|high" && exit 1 || exit 0`
**format-file.sh**: `*.cs) run_if_exists dotnet format --include "$FILE" ;;` (chậm — có thể bỏ, để lint.sh xử lý)
**ci.yml – STACK-SETUP**
```yaml
      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'
```
**sensitive-paths bổ sung:** `*/Authentication/*`, `*/Authorization/*`, `*/Migrations/*`, `appsettings.Production.json`.

## Python

**lint.sh**: `pip install -r requirements-dev.txt -q && ruff check . && ruff format --check . && mypy .`
**test.sh**: `mkdir -p test-results && pytest --junitxml=test-results/junit.xml --cov=. "$@"`
**build.sh**: `python -m build` (thư viện) hoặc `python -m compileall -q .` (ứng dụng)
**audit.sh**: `pip-audit -r requirements.txt`
**format-file.sh**: `*.py) run_if_exists ruff format "$FILE"; run_if_exists ruff check "$FILE" ;;`
**ci.yml – STACK-SETUP**
```yaml
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
          cache: 'pip'
```
**sensitive-paths bổ sung:** `*/auth/*`, `alembic/versions/*` hoặc `*/migrations/*`, `settings/production*`.

## Go

**lint.sh**: `test -z "$(gofmt -l .)" && go vet ./... && golangci-lint run`
**test.sh**: `mkdir -p test-results && go test ./... -coverprofile=test-results/coverage.out "$@"`
**build.sh**: `go build ./...`
**audit.sh**: `govulncheck ./...`
**format-file.sh**: `*.go) run_if_exists gofmt -w "$FILE" ;;`
**ci.yml – STACK-SETUP**
```yaml
      - uses: actions/setup-go@v5
        with:
          go-version-file: 'go.mod'
```

## Frontend + Backend tách repo/thư mục
Nếu monorepo `frontend/` + `backend/`: trong mỗi script gọi lần lượt hai phần, ví dụ:
```bash
( cd backend && ./mvnw -B test )
( cd frontend && npm ci && npx vitest run )
```
và thêm cả hai bước setup vào ci.yml.
