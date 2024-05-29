// ignore_for_file: constant_identifier_names

const FETCH_GROUPS = '''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name',
          c.username,
          'picture',
          c.picture,
        )
      ) FROM users c WHERE c.id = g.creator_id
    ) AS creator,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name', m.username,
          'picture', m.picture
        )
      ) FROM (
        SELECT
          u.username,
          u.picture
        FROM users u
        INNER JOIN group_members gm
        ON gm.user_id = u.id AND g.id = gm.group_id
      ) AS m
    ) AS members,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'id', m.id,
          'type', m.type,
          'content', m.content,
          'sender', m.sender,
          'created_at', m.created_at
        )
      ) FROM (
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
          ) AS sender
          gm.created_at
        FROM group_messages gm
      ) AS m
    ) AS messages
    g.created_at
  FROM groups g
''';

const FETCH_GROUP_BY_NAME = r'''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name',
          c.username,
          'picture',
          c.picture,
        )
      ) FROM users c WHERE c.id = g.creator_id
    ) AS creator,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name', m.username,
          'picture', m.picture
        )
      ) FROM (
        SELECT
          u.username,
          u.picture
        FROM users u
        INNER JOIN group_members gm
        ON gm.user_id = u.id AND g.id = gm.group_id
      ) AS m
    ) AS members,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'id', m.id,
          'type', m.type,
          'content', m.content,
          'sender', m.sender,
          'created_at', m.created_at
        )
      ) FROM (
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
          ) AS sender
          gm.created_at
        FROM group_messages gm
      ) AS m
    ) AS messages
    g.created_at
  FROM groups g
  WHERE g.group_name = $1
''';

const FETCH_GROUPS_IN = r'''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name',
          c.username,
          'picture',
          c.picture,
        )
      ) FROM users c WHERE c.id = g.creator_id
    ) AS creator,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name', m.username,
          'picture', m.picture
        )
      ) FROM (
        SELECT
          u.username,
          u.picture
        FROM users u
        INNER JOIN group_members gm
        ON gm.user_id = u.id AND g.id = gm.group_id
      ) AS m
    ) AS members,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'id', m.id,
          'type', m.type,
          'content', m.content,
          'sender', m.sender,
          'created_at', m.created_at
        )
      ) FROM (
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
          ) AS sender
          gm.created_at
        FROM group_messages gm
      ) AS m
    ) AS messages
    g.created_at
  FROM groups g
  WHERE g.group_name IN ($1)
''';

const FETCH_GROUP_BY_NAME_AND_CREATOR = r'''
  SELECT
    g.id,
    g.group_name,
    g.description,
    g.picture,
    (
      SELECT JSON_BUILD_OBJECT(
        'name', c.name,
        'picture', c.picture
      ) FROM (
        SELECT
          c.name,
          c.picture
        FROM users c
        WHERE c.id = g.creator_id
      ) AS c
    ) AS creator,
    g.created_at
  FROM groups g
  WHERE g.group_name = $1 AND g.creator_id = $2
''';

const CREATE_GROUP = r'''
  INSERT INTO groups(
    group_name,
    description,
    creator_id
  ) VALUES ($1, $2, $3)
  RETURNING id
''';

const UPDATE_GROUP = '''
  UPDATE groups SET
    group_name = @group_name,
    description = @description,
  WHERE id = @id AND creator_id = @creator_id
''';

const DELETE_GROUP = r'''
  UPDATE groups SET
    deleted_at = CURRENT_TIMESTAMP
  WHERE id = $1
''';

const SAVE_GROUP_MEMBER = r'''
  INSERT INTO group_members(
    group_id, user_id
  ) VALUES ($1, $2)
''';
