// ignore_for_file: constant_identifier_names

const FETCH_ALL_PRIVATE_MESSAGES = r'''
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
      ) AS s
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
      ) AS r
    ) AS recipient,
    pv.created_at,
    pv.is_temporary_message
  FROM private_messages pv
  INNER JOIN users u
    ON u.id = pv.sender_id
    OR u.id = pv.recipient_id
  WHERE u.username = $1 AND pv.deleted_at IS NULL
''';

const FETCH_ALL_GROUP_MESSAGES = r'''
  SELECT
    gm.id,
    gm.type,
    gm.content,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', s.username,
        'picture', s.picture
      ) FROM (
        SELECT
          s.username,
          s.picture
        FROM users s
        WHERE s.id = gm.sender_id
      ) AS s
    ) AS sender,
    JSON_BUILD_OBJECT(
      'name', g.group_name,
      'description', g.description,
      'picture', g.picture,
      'creator', (
      	select json_build_object(
      		'name', creator.username,
      		'picture', creator.picture
      	) from (
      		select
      			c.username,
      			c.picture
      		from users c
      		where c.id = g.creator_id
      	) as creator
      ),
      'created_at', g.created_at
    ) AS group,
    gm.created_at
  FROM group_messages gm
  INNER JOIN groups g ON g.id = gm.group_id
  WHERE g.group_name = $1 AND gm.deleted_at IS NULL
''';

const SAVE_PRIVATE_MESSAGE = r'''
  INSERT INTO private_messages(
    type,
    content,
    sender_id,
    recipient_id,
    is_pending,
    is_temporary_message
  ) VALUES ($1, $2, $3, $4, $5, $6)
''';

const SAVE_GROUP_MESSAGE = r'''
  INSERT INTO group_messages(
    type,
    content,
    sender_id,
    group_id
  ) VALUES ($1, $2, $3, $4)
  RETURNING id
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

const INSERT_MESSAGE_SEEN_BY = r'''
  INSERT INTO group_message_seen_by (
    group_message_id,
    user_id,
    group_id
  )
  SELECT $1, $2, $3
  WHERE NOT EXISTS (
      SELECT 1 
      FROM group_message_seen_by 
      WHERE 
        group_message_id = $1 
        AND user_id = $2 
        AND group_id = $3
  )
''';
