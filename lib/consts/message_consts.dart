// ignore_for_file: constant_identifier_names

const FETCH_ALL_PRIVATE_MESSAGES = r'''
  SELECT
    pv.id,
    pv.type,
    pv.content,
    pv.created_at,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', s.username,
        'picture', s.picture
      )
      FROM users s
      WHERE s.id = pv.sender_id
    ) AS sender,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', s.username,
        'picture', s.picture
      )
      FROM users r
      WHERE r.id = pv.recipient_id
    ) AS recipient
  FROM private_messages pv
  INNER JOIN users u ON u.id = pv.sender_id OR u.id = pv.recipient_id
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
