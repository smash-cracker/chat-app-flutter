import 'dart:io';

import 'package:chat/auth/class/group/group_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(
    groupRepository: groupRepository,
    ref: ref,
  );
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;
  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  void createGroup(BuildContext context, String name, File profilePic,
      List<Contact> selectedContact) {
    groupRepository.createGroup(context, name, profilePic, selectedContact);
  }

  void AddGroupMembers(
      BuildContext context, String groupId, List<Contact> selectedContact) {
    print(groupId);
    print(selectedContact);
    groupRepository.addMembersGroup(context, groupId, selectedContact);
  }
}
