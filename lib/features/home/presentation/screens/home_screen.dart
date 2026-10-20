import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:secret/features/home/presentation/widgets/home_chat_list.dart';
import 'package:secret/features/home/presentation/widgets/home_search_field.dart';
import 'package:secret/features/home/service/chat_selection_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final username = FirebaseAuth.instance.currentUser?.displayName ?? 'User';

  final selectionService = GetIt.I<ChatSelectionService>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: selectionService,
      builder: (context, _) {
        final isSelectionMode = selectionService.isSelectionMode;
        final selectedCount = selectionService.selectedPartnerIds.length;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                  child: AppBar(
                    scrolledUnderElevation: 0,
                    elevation: 0,
                    leading: isSelectionMode
                        ? IconButton(
                            onPressed: () => selectionService.clearSelection(),
                            icon: Icon(Icons.close),
                          )
                        : IconButton(
                            onPressed: () {
                              context.push('/profile');
                            },
                            icon: CircleAvatar(
                              child: Text(
                                username[0],
                              ),
                            ),
                          ),
                    title: isSelectionMode
                        ? Text('$selectedCount')
                        : StreamBuilder<DatabaseEvent>(
                            stream: FirebaseDatabase.instanceFor(
                              app: Firebase.app(),
                              databaseURL:
                                  'https://post-auth-42085-default-rtdb.europe-west1.firebasedatabase.app',
                            ).ref('.info/connected').onValue,
                            builder: (context, snapshot) {
                              bool isConnected = false;

                              if (snapshot.hasData &&
                                  snapshot.data?.snapshot.value != null) {
                                isConnected =
                                    snapshot.data!.snapshot.value as bool;
                              }

                              return Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      isConnected ? 'Secret' : 'Connecting...',
                                      key: ValueKey(isConnected),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    actions: [
                      if (isSelectionMode)
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Text(
                                      'Delete?',
                                    ),
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final myUid = FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid;
                                            if (myUid == null) return;

                                            for (final partnerId
                                                in selectionService
                                                    .selectedPartnerIds) {
                                              await FirebaseDatabase.instance
                                                  .ref(
                                                    'user_chats/$myUid/$partnerId',
                                                  )
                                                  .remove();
                                            }

                                            selectionService.clearSelection();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Delete',
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            selectionService.clearSelection();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Cancel',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.delete),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  HomeSearchField(),
                  const SizedBox(height: 20),
                  HomeChatList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
