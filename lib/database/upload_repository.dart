import 'package:postgres/postgres.dart';
import 'package:silent_signal/consts/upload_consts.dart';
import 'package:silent_signal/database/manager.dart';

class UploadRepository {
  Future<bool> saveUserPicture(int userId, String picture) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          Sql.named(SAVE_USER_PICTURE),
          parameters: {
            'id': userId,
            'picture': picture,
          },
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }

  Future<bool> saveGroupPicture(
      int groupId, int creatorId, String picture) async {
    Connection? conn;
    try {
      conn = await ConnectionManager.getConnection();
      return await conn.runTx((session) async {
        final result = await session.execute(
          Sql.named(SAVE_GROUP_PICTURE),
          parameters: {
            'id': groupId,
            'creator_id': creatorId,
            'picture': picture,
          },
        );
        return result.affectedRows > 0;
      });
    } catch (e) {
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
