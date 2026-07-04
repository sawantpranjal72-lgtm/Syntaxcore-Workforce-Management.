CREATE TABLE IF NOT EXISTS role_menu_access (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role        VARCHAR(50) NOT NULL,
    menu_key    VARCHAR(100) NOT NULL,
    is_allowed  BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255),
    CONSTRAINT uk_role_menu_access_role_menu UNIQUE (role, menu_key)
);

CREATE INDEX IF NOT EXISTS idx_role_menu_access_role ON role_menu_access(role);

CREATE TABLE IF NOT EXISTS feature_flags (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    flag_key    VARCHAR(100) NOT NULL,
    is_enabled  BOOLEAN NOT NULL DEFAULT TRUE,
    is_deleted  BOOLEAN NOT NULL DEFAULT FALSE,
    deleted_at  TIMESTAMP,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP,
    created_by  VARCHAR(255),
    updated_by  VARCHAR(255),
    CONSTRAINT uk_feature_flags_key UNIQUE (flag_key)
);
