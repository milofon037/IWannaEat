# IWannaEat

IWannaEat - мобильное Android-приложение рецептов с AI-ассистентом, который подбирает блюда с учетом пользовательских ограничений (аллергии, диета) и связывает ответы чата с карточками реальных рецептов.

## Ключевые возможности

- Регистрация и авторизация по email/паролю с JWT.
- Настройка профиля: аллергии и описание диеты.
- Публичные и авторские рецепты: CRUD, поиск, фильтры, пагинация.
- Плейлисты (подборки) в стиле Pinterest: сохранение рецептов в коллекции.
- AI-чат через backend с ответами вида `message + recipe_ids`.
- Сетевые и серверные ошибки обрабатываются по online-only сценарию.

## Технологический стек

- **Mobile**: Flutter (Dart), Material Design 3, BLoC/Cubit.
- **Backend**: Java (Spring Boot), REST API, JWT/RBAC.
- **Database**: PostgreSQL.
- **Integrations**: LLM provider (через backend), Firebase Cloud Messaging.

## Запуск локально (Phase 0-1)

1. Поднять PostgreSQL:
   - `POSTGRES_PORT=5433 docker compose up -d postgres`
2. Запустить backend:
   - `cd app`
   - `DB_URL=jdbc:postgresql://localhost:5433/iwannaeat DB_USERNAME=iwannaeat DB_PASSWORD=iwannaeat ./gradlew bootRun --args='--server.port=18080'`
3. Запустить Flutter клиент:
   - `cd i_wanna_eat`
   - `flutter pub get`
   - `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:18080`

### Проверка backend

- Swagger UI: `http://localhost:18080/swagger-ui/index.html`
- Healthcheck: `http://localhost:18080/actuator/health`

## Документация проекта

- [Development Guidelines](./DEVELOPMENT_GUIDELINES.md)
- [Implementation Plan](./PLAN.md)
- [Architecture](./ARCHITECTURE.md)
- [Product Requirements](./tz.md)
- [UI/UX Requirements](./ui-reqs.md)
