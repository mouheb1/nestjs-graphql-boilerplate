# NestJS GraphQL Boilerplate

A production-ready NestJS boilerplate with TypeORM, GraphQL, and PostgreSQL for rapid API development.

## 🚀 Quick Start

### Prerequisites

- Node.js >= 22.0
- Docker & Docker Compose
- PostgreSQL (or use Docker)

### Installation

1. **Clone and install**

```bash
cd nestjs-graphql-boilerplate
yarn install
```

2. **Setup environment**

```bash
cp .example.env .development.env
# Edit .development.env with your database credentials
```

3. **Start database**

```bash
# Using Docker
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=your_password postgres:15

# Or use Docker Compose
docker compose --env-file ./.development.env up -d
```

4. **Run the application**

```bash
yarn dev
```

**Access points:**

- API: http://localhost:8000
- GraphQL Playground: http://localhost:8000/graphql

## 🐳 Docker Setup

### Development

```bash
# Start all services
docker compose --env-file ./.development.env up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Production

```bash
# Build and deploy
docker compose --env-file ./.production.env up --build -d
```

### Useful Commands

```bash
# Run migrations in container
docker compose exec app yarn migration:run

# Access database
docker compose exec postgres psql -U postgres -d postgres

# Rebuild specific service
docker compose up --build app
```

## 📊 Database Migrations

```bash
# Generate migration from entity changes
yarn migration:generate ./src/common/database/migrations/migration_name

# Run pending migrations
yarn migration:run

# Revert last migration
yarn migration:revert

# Check migration status
yarn migration:show
```

## 🔗 GraphQL API

**Playground**: http://localhost:8000/graphql

### Authentication

Include JWT token in headers for protected endpoints:

```json
{
  "Authorization": "Bearer YOUR_JWT_TOKEN"
}
```

### Key Features

- **Code First Approach**: Schemas generated from TypeScript code
- **Protected Endpoints**: JWT authentication with role-based access
- **Dynamic Query Optimization**: Automatic SELECT and JOIN optimization
- **Advanced Filtering**: Complex WHERE conditions with operators
- **Soft Delete**: Built-in soft delete with restore functionality

### User CRUD Operations

#### Create User

```graphql
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    username
    nickname
    role
    createdAt
    updatedAt
  }
}
```

**Variables:**

```json
{
  "input": {
    "username": "john.doe",
    "password": "securePassword123",
    "nickname": "Johnny",
    "role": "USER"
  }
}
```

#### Get All Users with Pagination

```graphql
query GetUsers($input: GetManyInput) {
  getManyUserList(input: $input) {
    data {
      id
      username
      nickname
      role
      createdAt
      updatedAt
    }
    count
  }
}
```

**Variables:**

```json
{
  "input": {
    "pagination": { "size": 10, "page": 0 },
    "order": { "createdAt": "DESC" }
  }
}
```

#### Get Single User

```graphql
query GetUser($input: GetOneInput) {
  getOneUser(input: $input) {
    id
    username
    nickname
    role
    createdAt
    updatedAt
  }
}
```

**Variables:**

```json
{
  "input": {
    "where": {
      "id": "user-uuid-here"
    }
  }
}
```

#### Update User

```graphql
mutation UpdateUser($id: String!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    affected
  }
}
```

**Variables:**

```json
{
  "id": "user-uuid-here",
  "input": {
    "nickname": "New Nickname",
    "role": "ADMIN"
  }
}
```

#### Delete User (Soft Delete)

```graphql
mutation DeleteUser($id: String!) {
  deleteUser(id: $id) {
    affected
  }
}
```

#### Get Current User Profile

```graphql
query GetMe {
  getMe {
    id
    username
    nickname
    role
    createdAt
    updatedAt
  }
}
```

### Advanced User Filtering

#### Filter by Role

```json
{
  "input": {
    "where": {
      "role": "ADMIN"
    }
  }
}
```

#### Search by Nickname (Case-insensitive)

```json
{
  "input": {
    "where": {
      "nickname": {
        "$iContains": "john"
      }
    }
  }
}
```

#### Search by Username with Exact Match

```json
{
  "input": {
    "where": {
      "username": {
        "$eq": "john.doe"
      }
    }
  }
}
```

#### Filter by Multiple Roles

```json
{
  "input": {
    "where": {
      "role": {
        "$in": ["USER", "ADMIN"]
      }
    }
  }
}
```

#### Filter by Date Range

```json
{
  "input": {
    "where": {
      "createdAt": {
        "$gte": "2024-01-01T00:00:00.000Z",
        "$lte": "2024-12-31T23:59:59.999Z"
      }
    }
  }
}
```

#### Complex AND/OR Filtering

```json
{
  "input": {
    "where": {
      "AND": [
        { "role": "USER" },
        {
          "OR": [
            { "nickname": { "$iContains": "john" } },
            { "username": { "$iContains": "doe" } }
          ]
        }
      ]
    }
  }
}
```

#### Pagination with Filtering and Sorting

```json
{
  "input": {
    "pagination": { "size": 5, "page": 0 },
    "order": {
      "createdAt": "DESC",
      "nickname": "ASC"
    },
    "where": {
      "role": "USER",
      "nickname": { "$iContains": "test" }
    }
  }
}
```

#### Read with Filtering

```graphql
query GetUsers($input: GetManyInput) {
  getManyUserList(input: $input) {
    data {
      id
      nickname
      role
      createdAt
    }
    count
  }
}
```

**Variables:**

```json
{
  "input": {
    "pagination": { "size": 10, "page": 0 },
    "order": { "createdAt": "DESC" },
    "where": {
      "role": { "$eq": "ADMIN" },
      "email": { "$iContains": "@company.com" }
    }
  }
}
```

#### Update

```graphql
mutation UpdateUser($id: String!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    id
    email
    firstName
    lastName
    updatedAt
  }
}
```

#### Delete (Soft Delete)

```graphql
mutation DeleteUser($id: String!) {
  deleteUser(id: $id)
}
```

#### Restore

```graphql
mutation RestoreUser($id: String!) {
  restoreUser(id: $id)
}
```

### Available Filter Operators

- **`$eq`, `$ne`** - Equal, Not equal
- **`$gt`, `$gte`, `$lt`, `$lte`** - Comparisons
- **`$in`, `$nIn`** - In array, Not in array
- **`$contains`, `$nContains`** - Pattern matching (case-sensitive)
- **`$iContains`, `$nIContains`** - Pattern matching (case-insensitive)
- **`$null`, `$nNull`** - Null check
- **`$between`** - Between two values

**Note:** Simple values like `"role": "USER"` are automatically treated as `$eq` operators.

## ⚡ Code Generator

Generate complete CRUD operations with a single command:

```bash
yarn g
```

**Features:**

- Entity with TypeORM decorators
- GraphQL resolvers and inputs
- Service with business logic
- Repository with database operations
- Unit and integration tests
- Soft delete support

**Generated files:**

- `src/{entity}/entities/{entity}.entity.ts`
- `src/{entity}/inputs/{entity}.input.ts`
- `src/{entity}/{entity}.module.ts`
- `src/{entity}/{entity}.resolver.ts`
- `src/{entity}/{entity}.service.ts`
- `src/{entity}/{entity}.repository.ts`
- Test files

## 🚀 CI/CD

### GitHub Actions

- Automated testing on push/PR
- Set `ENV` secret with base64-encoded `.test.env` content

### Husky Git Hooks

```bash
yarn prepare  # Setup git hooks
```

**Pre-commit:** Linting
**Pre-push:** Prevent main branch pushes

## 📝 Available Scripts

```bash
# Development
yarn dev          # Start development server
yarn build        # Build for production
yarn start        # Start production server

# Database
yarn migration:generate  # Generate migration
yarn migration:run       # Run migrations
yarn migration:revert    # Revert migration
yarn migration:show      # Show migration status

# Testing
yarn test:unit           # Unit tests
yarn test:integration    # Integration tests
yarn test:e2e:docker      # E2E tests

# Code Quality
yarn lint               # Lint code
yarn lint:fix           # Fix linting issues
yarn format             # Format code

# Generator
yarn g                  # Generate CRUD
```

## 🏗️ Project Structure

```
src/
├── auth/                 # Authentication module
├── cache/                # Caching decorators
├── common/               # Shared utilities
│   ├── config/          # Configuration
│   ├── database/        # Migrations
│   ├── decorators/      # Custom decorators
│   ├── exceptions/      # Error handling
│   ├── graphql/         # GraphQL utilities
│   └── guards/          # Authentication guards
├── user/                 # User module (example)
└── main.ts              # Application entry point
```

## 11. TDD

### 11.1. Introduction

[`@nestjs/testing`](https://docs.nestjs.com/fundamentals/testing) = `supertest` + `jest`

### 11.2. Before Getting Started

Before starting the test, you need to set at least jwt-related environment variables in an env file named `.test.env`.

### 11.3. Unit Test (with mock)

Unit test(with jest mock) for services & resolvers (\*.service.spec.ts & \*.resolver.spec.ts)

#### 11.3.1. Run

```bash
$ yarn test:unit
```

### 11.4. Integration Test (with in-memory DB)

Integration test(with [pg-mem](https://github.com/oguimbal/pg-mem)) for modules (\*.module.spec.ts)

#### 11.4.1. Run

```bash
$ yarn test:integration
```

### 11.5. End To End Test (with docker)

E2E Test(with docker container)

#### 11.5.1. Run

```bash
$ yarn test:e2e:docker
```

## 12. CI

### 12.1. Github Actions

To ensure github actions execution, please set the 'ENV' variable within your github actions secrets as your .test.env configuration.

**Note:** Github Actions does not recognize newline characters. Therefore, you must remove any newline characters from each environment variable value in your `.env` file, ensuring that the entire content is on a single line when setting the Secret. If you need to use an environment variable value that includes newline characters, encode the value using Base64 and store it in the Github Secret, then decode it within the workflow.

ex)

```bash
JWT_PRIVATE_KEY= -----BEGIN RSA PRIVATE KEY-----...MIIEogIBAAKCAQBZ...-----END RSA PRIVATE KEY-----
```

### 12.2. [Husky v9](https://github.com/typicode/husky)

#### 12.2.1 Before Getting Started

```bash
$ yarn prepare
```

#### 12.2.2 Pre commit

[You can check detail here](./.husky/pre-commit)

Before commit, The pre-commit hooks is executed.

Lint checks have been automated to run before a commit is made.

If you want to add test before commit actions, you can add follow line in [pre-commit](./.husky/pre-commit) file.

```bash
...
yarn test
...
```

#### 12.2.3. Pre push

[You can check detail here](./.husky/pre-push)

The pre-push hooks is executed before the push action.

The default rule set in the pre-push hook is to prevent direct pushes to the main branch.

If you want to enable this action, you should uncomment the lines in the pre push file.

## 13. [SWC Compiler](https://docs.nestjs.com/recipes/swc)

[SWC](https://swc.rs/) (Speedy Web Compiler) is an extensible Rust-based platform that can be used for both compilation and bundling. Using SWC with Nest CLI is a great and simple way to significantly speed up your development process.

### 13.1. SWC + Jest error resolution

After applying `SWC`, the following error was displayed in jest using an in-memory database (`pg-mem`):

```bash
    QueryFailedError: ERROR: function obj_description(regclass,text) does not exist
    HINT: 🔨 Please note that pg-mem implements very few native functions.

                👉 You can specify the functions you would like to use via "db.public.registerFunction(...)"

    🐜 This seems to be an execution error, which means that your request syntax seems okay,
        but the resulting statement cannot be executed → Probably not a pg-mem error.

    *️⃣ Failed SQL statement: SELECT "table_schema", "table_name", obj_description(('"' || "table_schema" || '"."' || "table_name" || '"')::regclass, 'pg_class') AS table_comment FROM "information_schema"."tables" WHERE ("table_schema" = 'public' AND "table_name" = 'user');

    👉 You can file an issue at https://github.com/oguimbal/pg-mem along with a way to reproduce this error (if you can), and  the stacktrace:
```

`pg-mem` is a library designed to emulate `PostgreSQL`, however, it does not support all features, which is why the above error occurred.

This error can be resolved by implementing or overriding existing functions. Below is the function implementation for the resolution.
Related issues can be checked [here](https://github.com/oguimbal/pg-mem/issues/380).

```ts
db.public.registerFunction({
  name: 'obj_description',
  args: [DataType.text, DataType.text],
  returns: DataType.text,
  implementation: () => 'test',
});
```
