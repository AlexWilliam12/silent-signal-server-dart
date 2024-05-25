CREATE TABLE IF NOT EXISTS users(
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    credentials_hash VARCHAR(255) UNIQUE NOT NULL,
    picture TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contacts(
    user_id INTEGER NOT NULL,
    contact_id INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(contact_id) REFERENCES users(id),
    PRIMARY KEY(user_id, contact_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS private_messages(
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sender_id INTEGER NOT NULL,
    recipient_id INTEGER NOT NULL,
    is_pending BOOLEAN NOT NULL,
    FOREIGN KEY(sender_id) REFERENCES users(id),
    FOREIGN KEY(recipient_id) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS groups(
    id SERIAL PRIMARY KEY,
    group_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    picture TEXT,
    creator_id INTEGER NOT NULL,
    FOREIGN KEY(creator_id) REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_members(
    user_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(group_id) REFERENCES groups(id),
    PRIMARY KEY(user_id, group_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_messages(
    id SERIAL PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    sender_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    FOREIGN KEY(sender_id) REFERENCES users(id),
    FOREIGN KEY(group_id) REFERENCES groups(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS group_message_seen_by(
    group_message_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    group_id INTEGER NOT NULL,
    FOREIGN KEY(group_message_id) REFERENCES group_messages(id),
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(group_id) REFERENCES groups(id),
    PRIMARY KEY(group_message_id, user_id, group_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS user_index ON users(username);
CREATE INDEX IF NOT EXISTS group_index ON groups(group_name);