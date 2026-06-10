CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'USER',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN'))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);

CREATE TABLE IF NOT EXISTS allergies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    diet_description VARCHAR(500),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_allergies (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    allergy_id INT NOT NULL REFERENCES allergies(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, allergy_id)
);

INSERT INTO allergies(name)
VALUES
    ('Орехи'),
    ('Молоко'),
    ('Глютен'),
    ('Яйца'),
    ('Морепродукты'),
    ('Соя')
ON CONFLICT (name) DO NOTHING;
