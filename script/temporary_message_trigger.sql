CREATE OR REPLACE FUNCTION exclude_temporary_messages() RETURNS VOID AS $$
BEGIN
    UPDATE private_messages SET
        deleted_at = CURRENT_TIMESTAMP
    WHERE is_temporary_message = TRUE
        AND created_at + (
            SELECT temporary_message_interval
            FROM users
            WHERE users.id = private_messages.sender_id
        ) <= CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;