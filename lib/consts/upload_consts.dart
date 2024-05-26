// ignore_for_file: constant_identifier_names

const SAVE_USER_PICTURE = '''
  UPDATE users SET
    picture = @picture
  WHERE id = @id
''';

const SAVE_GROUP_PICTURE = '''
  UPDATE groups SET
    picture = @picture
  WHERE id = @id AND creator_id = @creator_id
''';

const SAVE_PRIVATE_CHAT_FILE = '''
  UPDATE users SET
    picture = @picture
  WHERE id = @id
''';

const SAVE_GROUP_CHAT_FILE = '''
  UPDATE users SET
    picture = @picture
  WHERE id = @id
''';

const FETCH_USER_PICTURE = '''''';

const FETCH_GROUP_PICTURE = '''''';

const FETCH_USER_CHAT_FILE = '''''';

const FETCH_GROUP_CHAT_FILE = '''''';
