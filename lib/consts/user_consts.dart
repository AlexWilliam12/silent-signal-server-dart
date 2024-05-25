// ignore_for_file: constant_identifier_names

const FETCH_USER_DATA_QUERY = r'''
SELECT
    u.id,
		u.username,
    u.password,
		u.credentials_hash,
		u.picture,
    u.created_at,
		ARRAY(
			SELECT JSON_BUILD_OBJECT(
				'name',
				c.username,
				'picture',
				c.picture
			)
			FROM (
				SELECT 
					c.username,
					c.picture
				FROM users c
				JOIN contacts uc ON uc.user_id = c.id
				WHERE uc.user_id = u.id
			) AS c
		) AS contacts,
		ARRAY(
			SELECT JSON_BUILD_OBJECT(
        'id',
        m.id,
				'type',
				m.type,
				'content',
				m.content,
				'createdAt',
				m.created_at,
				'sender_name',
				m.sender_username,
				'senderPicture',
				m.sender_picture,
				'recipient_name',
				m.recipient_username,
				'recipientPicture',
				m.recipient_picture
			)
			FROM (
				SELECT
          pv.id,
					pv.type,
					pv.content,
					pv.created_at,
					s.username AS sender_username,
          s.picture AS sender_picture,
          r.username AS recipient_username,
          r.picture AS recipient_picture
				FROM private_messages pv
				LEFT JOIN users s ON pv.sender_id = s.id
				LEFT JOIN users r ON pv.recipient_id = r.id
				WHERE u.id = pv.sender_id OR u.id = pv.recipient_id
			) AS m
		) AS messages
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

const DELETE_USER = r'DELETE FROM users WHERE username = $1';

const SAVE_USE_CONTACT = r'''
  INSERT INTO contacts(
    user_id,
    contact_id
  ) VALUES ($1, $2)
''';
