import 'dart:convert';
import 'dart:io';

import 'package:silent_signal/database/group_repository.dart';
import 'package:silent_signal/database/user_repository.dart';
import 'package:silent_signal/models/group.dart';
import 'package:silent_signal/models/user.dart';
import 'package:silent_signal/server/http_response_builder.dart';

class GroupController {
  final groupRepository = GroupRepository();
  final userRepository = SensitiveUserRepository();

  Future<HttpResponseBuilder> fetchAll(HttpRequest request) async {
    try {
      return HttpResponseBuilder.send(request.response).ok(
        HttpStatus.ok,
        body: jsonEncode(await groupRepository.fetchAll()),
      );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> fetchSingle(HttpRequest request) async {
    try {
      final groupName = request.uri.queryParameters['groupName'];
      if (groupName == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'groupName' not found",
        );
      }
      final group = await groupRepository.fetchByGroupName(groupName);
      return group != null
          ? HttpResponseBuilder.send(request.response).ok(
              HttpStatus.ok,
              body: jsonEncode(group),
            )
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.notFound,
              body: 'group not found',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> create(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']);

      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);

      final groupId = await groupRepository.create(
        Group.dto(
          name: json['group_name']!,
          description: json['description'],
          picture: json['picture'],
          creator: User.id(id: user!.id),
        ),
      );
      if (groupId == 0) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.internalServerError,
          body: 'unable to create group',
        );
      }
      groupRepository.saveGroupMember(groupId, user.id!);
      return HttpResponseBuilder.send(request.response).ok(HttpStatus.ok);
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> update(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']);

      final groupName = request.uri.queryParameters['groupName'];
      if (groupName == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'groupName' not found",
        );
      }
      final group = await groupRepository.fetchByGroupNameAndCreator(
        groupName,
        user!.id!,
      );
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'group not found',
        );
      }

      final body = await utf8.decoder.bind(request).join();
      final json = jsonDecode(body);

      group.name = json['group_name'] ?? group.name;
      group.description = json['description'] ?? group.description;

      final isUpdated = await groupRepository.update(group);
      return isUpdated
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to update group',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> delete(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']);

      final groupName = request.uri.queryParameters['groupName'];
      if (groupName == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'groupName' not found",
        );
      }
      final group = await groupRepository.fetchByGroupNameAndCreator(
        groupName,
        user!.id!,
      );
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'group not found',
        );
      }
      final isDeleted = await groupRepository.delete(group.id!);
      return isDeleted
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to delete group',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }

  Future<HttpResponseBuilder> saveMember(
    HttpRequest request,
    Map<String, dynamic> claims,
  ) async {
    try {
      final user = await userRepository.fetchByUsername(claims['username']);

      final groupName = request.uri.queryParameters['groupName'];
      if (groupName == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.badRequest,
          body: "query key 'groupName' not found",
        );
      }
      final group = await groupRepository.fetchByGroupName(groupName);
      if (group == null) {
        return HttpResponseBuilder.send(request.response).error(
          HttpStatus.notFound,
          body: 'group not found',
        );
      }
      final isSaved =
          await groupRepository.saveGroupMember(user!.id!, group.id!);
      return isSaved
          ? HttpResponseBuilder.send(request.response).ok(HttpStatus.ok)
          : HttpResponseBuilder.send(request.response).error(
              HttpStatus.internalServerError,
              body: 'unable to save group member',
            );
    } catch (e) {
      return HttpResponseBuilder.send(request.response).error(
        HttpStatus.badRequest,
        body: e.toString(),
      );
    }
  }
}
