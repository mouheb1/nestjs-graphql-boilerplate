# Adding New Tables with Relations

This guide shows how to add a new table with relationships using the project's workflow.

## Example: Organization Table with One-to-Many User Relationship

This example adds an `organization` table that has a one-to-many relationship with the `user` table, with required fields `name` (string) and `isEnabled` (boolean).

## 🚀 **Step 1: Generate Organization CRUD**

```bash
yarn g
```

**Generator prompts:**

- **Table Name:** `organization`
- **Create jest?** `Yes`
- **Select columns:** `createdAt, updatedAt, deletedAt`
- **ID format:** `uuid`
- **Data column names:** `name, isEnabled`
- **Column type:** `string` (for name), then run again for `boolean` (for isEnabled)
- **Required?** `Yes` for both

## 🔧 **Step 2: Update Organization Entity**

Edit the generated file `src/organization/entities/organization.entity.ts` to add the relationship and fix the boolean field:

```typescript
import { Field, ID, ObjectType } from '@nestjs/graphql';

import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

import { User } from '../../user/entities/user.entity';

@ObjectType()
@Entity()
export class Organization {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @Column()
  name: string;

  @Field()
  @Column({ default: true })
  isEnabled: boolean;

  @Field(() => [User], { nullable: true })
  @OneToMany(() => User, (user) => user.organization)
  users?: User[];

  @Field()
  @CreateDateColumn({
    type: 'timestamp with time zone',
  })
  createdAt: Date;

  @Field()
  @UpdateDateColumn({
    type: 'timestamp with time zone',
  })
  updatedAt: Date;

  @Field()
  @DeleteDateColumn({
    type: 'timestamp with time zone',
  })
  deletedAt: Date;
}

@ObjectType()
export class GetOrganizationType {
  @Field(() => [Organization], { nullable: true })
  data?: Organization[];

  @Field(() => Number, { nullable: true })
  count?: number;
}
```

## 🔧 **Step 3: Update User Entity**

Add the organization relationship to `src/user/entities/user.entity.ts`:

```typescript
import {
  JoinColumn,
  // ...existing imports...
  ManyToOne,
} from 'typeorm';

import { Organization } from '../../organization/entities/organization.entity';

@ObjectType()
@Entity()
export class User {
  // ...existing fields...

  @Field(() => Organization, { nullable: true })
  @ManyToOne(() => Organization, (organization) => organization.users)
  @JoinColumn({ name: 'organizationId' })
  organization?: Organization;

  @Field(() => ID, { nullable: true })
  @Column({ nullable: true })
  organizationId?: string;

  // ...rest of existing fields...
}
```

## 🔧 **Step 4: Update Organization Input**

Edit `src/organization/inputs/organization.input.ts`:

```typescript
import { Field, InputType } from '@nestjs/graphql';

import { IsNotEmpty, IsOptional } from 'class-validator';

@InputType()
export class CreateOrganizationInput {
  @Field()
  @IsNotEmpty()
  name: string;

  @Field({ defaultValue: true })
  @IsNotEmpty()
  isEnabled: boolean;
}

@InputType()
export class UpdateOrganizationInput {
  @Field({ nullable: true })
  @IsOptional()
  name?: string;

  @Field({ nullable: true })
  @IsOptional()
  isEnabled?: boolean;
}
```

## 🔧 **Step 5: Update User Input (Optional)**

If you want to allow setting organization during user creation, edit `src/user/inputs/user.input.ts`:

```typescript
import { Field, ID, InputType } from '@nestjs/graphql';

// ...existing imports...

@InputType()
export class CreateUserInput {
  // ...existing fields...

  @Field(() => ID, { nullable: true })
  @IsOptional()
  organizationId?: string;
}

@InputType()
export class UpdateUserInput {
  // ...existing fields...

  @Field(() => ID, { nullable: true })
  @IsOptional()
  organizationId?: string;
}
```

## 🗃️ **Step 6: Generate Migration**

```bash
yarn migration:generate ./src/common/database/migrations/AddOrganizationTable
```

This will generate a migration file that includes:

- Creating the `organization` table
- Adding the `organizationId` foreign key column to the `user` table
- Setting up the foreign key constraint

## 🚀 **Step 7: Run Migration**

```bash
yarn migration:run
```

## 🔧 **Step 8: Update App Module**

Add the OrganizationModule to your `src/app.module.ts`:

```typescript
// ...existing imports...
import { OrganizationModule } from './organization/organization.module';

@Module({
  imports: [
    // ...existing modules...
    OrganizationModule,
  ],
  // ...rest of configuration...
})
export class AppModule {}
```

## 🧪 **Step 9: Test the Implementation**

### Create Organization:

```graphql
mutation CreateOrganization($input: CreateOrganizationInput!) {
  createOrganization(input: $input) {
    id
    name
    isEnabled
    createdAt
  }
}
```

**Variables:**

```json
{
  "input": {
    "name": "My Company",
    "isEnabled": true
  }
}
```

### Get Organizations with Users:

```graphql
query GetOrganizations($input: GetManyInput) {
  getManyOrganizationList(input: $input) {
    data {
      id
      name
      isEnabled
      users {
        id
        username
        nickname
      }
    }
    count
  }
}
```

### Create User with Organization:

```graphql
mutation CreateUser($input: CreateUserInput!) {
  createUser(input: $input) {
    id
    username
    nickname
    role
    organization {
      id
      name
    }
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
    "role": "USER",
    "organizationId": "organization-uuid-here"
  }
}
```

### Get Users with Organization:

```graphql
query GetUsers($input: GetManyInput) {
  getManyUserList(input: $input) {
    data {
      id
      username
      nickname
      role
      organization {
        id
        name
        isEnabled
      }
    }
    count
  }
}
```

## 🎯 **Why This Workflow?**

1. **Code Generator First**: Creates the basic CRUD structure
2. **Manual Relationship Setup**: Add relationships in entities (TypeORM handles the SQL)
3. **Migration Generation**: TypeORM auto-generates migration based on entity changes
4. **Migration Execution**: Applies changes to database

This approach ensures:

- ✅ **Consistent code structure** from generator
- ✅ **Type-safe relationships** in TypeScript
- ✅ **Automatic migration generation** from entity changes
- ✅ **Database schema versioning** through migrations
- ✅ **GraphQL schema auto-generation** from decorators

## 📝 **General Steps for Any New Table**

1. Run `yarn g` to generate base CRUD
2. Edit entity files to add relationships
3. Update input files if needed
4. Generate migration with `yarn migration:generate`
5. Run migration with `yarn migration:run`
6. Update app.module.ts to include new module
7. Test with GraphQL queries

The generator creates the foundation, then you customize with relationships and run migrations to sync the database! 🚀

## 🔍 **Troubleshooting**

### Migration Issues

- If migration fails, check entity relationships
- Ensure foreign key columns are nullable if needed
- Run `yarn migration:revert` to undo last migration

### GraphQL Schema Issues

- Restart the application after entity changes
- Check GraphQL playground for updated schema
- Verify Field decorators are properly imported

### Relationship Issues

- Ensure both sides of relationship are properly defined
- Check import paths between entities
- Verify JoinColumn names match database columns
