// ignore_for_file: constant_identifier_names

const FETCH_ALL_PRIVATE_MESSAGES_BY_NAME = r'''
  SELECT
    pv.id,
    pv.type,
    pv.content,
    pv.is_pending,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', s.username,
        'picture', s.picture
      ) FROM (
        SELECT
          s.username,
          s.picture
        FROM users s
        WHERE s.id = pv.sender_id
      ) as s
    ) AS sender,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', r.username,
        'picture', r.picture
      ) FROM (
        SELECT
          r.username,
          r.picture
        FROM users r
        WHERE r.id = pv.recipient_id
      ) as r
    ) AS recipient,
    pv.created_at,
    pv.deleted_at
  FROM private_messages pv
  INNER JOIN users u
    ON u.id = pv.sender_id
    OR u.id = pv.recipient_id
  WHERE u.username = $1
''';

const SAVE_PRIVATE_MESSAGE = r'''
  INSERT INTO private_messages(
    type,
    content,
    sender_id,
    recipient_id,
    is_pending
  ) VALUES ($1, $2, $3, $4, $5)
''';

const SAVE_GROUP_MESSAGE = r'''
  INSERT INTO group_messages(
    type,
    content,
    sender_id,
    group_id
  ) VALUES ($1, $2, $3, $4)
''';

const DELETE_PRIVATE_MESSAGE = r'''
  UPDATE private_messages SET
    deleted_at = CURRENT_TIMESTAMP
  WHERE id = $1
''';

const DELETE_GROUP_MESSAGE = r'''
  UPDATE group_messages SET
    deleted_at = CURRENT_TIMESTAMP
  WHERE id = $1
''';
