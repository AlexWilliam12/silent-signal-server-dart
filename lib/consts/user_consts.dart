// ignore_for_file: constant_identifier_names

const FETCH_USER_DATA_QUERY = r'''
  SELECT
    u.id,
    u.username,
    u.password,
    u.credentials_hash,
    u.picture,
    u.created_at,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'name', c.username,
          'picture', c.picture
        )
      )
      FROM (
        SELECT 
          c.username,
          c.picture
        FROM users c
        JOIN contacts uc ON uc.contact_id = c.id -- Corrigi aqui
        WHERE uc.user_id = u.id
      ) AS c
    ) AS contacts,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'id', cg.id,
          'group_name', cg.group_name,
          'description', cg.description,
          'group_picture', cg.group_picture,
          'created_at', cg.created_at,
          'creator_name', u.username,
          'creator_picture', u.picture
        )
      )
      FROM (
        SELECT
          g.id,
          g.group_name,
          g.description,
          g.picture AS group_picture,
          g.created_at
        FROM groups g
        WHERE g.creator_id = u.id
      ) AS cg
    ) AS created_groups,
    (
      SELECT JSON_AGG(
        JSON_BUILD_OBJECT(
          'id', pg.id,
          'group_name', pg.group_name,
          'description', pg.description,
          'group_picture', pg.group_picture,
          'created_at', pg.created_at,
          'creator_name', pg.username,
          'creator_picture', pg.creator_picture
        )
      )
      FROM (
        SELECT
          g.id,
          g.group_name,
          g.description,
          g.picture AS group_picture,
          g.created_at,
          c.username,
          c.picture AS creator_picture
        FROM groups g
        INNER JOIN group_members gm ON g.id = gm.group_id
        INNER JOIN users c ON c.id = g.creator_id
        WHERE gm.user_id = u.id
      ) AS pg
    ) AS participate_groups
  FROM users u
  WHERE u.username = $1
''';

const CREATE_USER = r'''
      INSERT INTO users (
        username,
        password,
        credentials_hash
      ) VALUES ($1, $2, $3)
    ''';

const FETCH_USER_BY_CREDENTIALS = r'''
  SELECT
    id,
    username,
    password,
    credentials_hash,
    picture,
    created_at
  FROM users 
  WHERE username = $1 AND password = $2
''';

const FETCH_USER_BY_HASH = r'''
  SELECT
    id,
    username,
    password,
    credentials_hash,
    picture,
    created_at
  FROM users 
  WHERE credentials_hash = $1
''';

const FETCH_USER_BY_USERNAME = r'''
  SELECT
    id,
    username,
    password,
    credentials_hash,
    picture,
    created_at
  FROM users 
  WHERE username = $1
''';

const UPDATE_USER = '''
  UPDATE users SET
    username = @username,
    password = @password,
    credentials_hash = @credentials_hash,
    picture = @picture
  WHERE id = @id
''';

const DELETE_USER = r'''
  UPDATE users SET
    deleted_at = CURRENT_TIMESTAMP
  WHERE id = $1
''';

const SAVE_USE_CONTACT = r'''
  INSERT INTO contacts(
    user_id,
    contact_id
  ) VALUES ($1, $2)
''';
