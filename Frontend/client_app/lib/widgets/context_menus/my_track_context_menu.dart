import 'package:flutter/material.dart';
import 'package:frontend/services/tracks_service.dart';
import 'package:frontend/widgets/confirm_dialog.dart';
import 'package:frontend/widgets/context_menus/shared/context_menu_item.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MyTrackContextMenu extends StatelessWidget {
  final int trackId;
  final VoidCallback onDeleteCallback;
  final Widget child;
  final TracksService _tracksService = GetIt.I<TracksService>();

  MyTrackContextMenu({
    Key? key,
    required this.trackId,
    required this.onDeleteCallback,
    required this.child,
  }) : super(key: key);

  void onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: AppLocalizations.of(context)!.delete_confirmation_title,
          content: AppLocalizations.of(context)!.delete_confirmation_message,
          confirmText: AppLocalizations.of(context)!.delete,
          cancelText: AppLocalizations.of(context)!.cancel,
          onConfirm: () {
            _tracksService.deleteTrack(trackId)
              .then(         
                (value) => {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.track_deleted),
                    duration: const Duration(seconds: 2),
                    ),
                  ),
                  onDeleteCallback(),
                },
                onError: (error) => {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.generic_error),
                    duration: const Duration(seconds: 2),
                    ),
                  ),
                },
              );
          },
        );
      },
    );
  }

  void onEdit(context) {
    GoRouter.of(context).push('/track/edit/$trackId');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showMenu(
          context: context,
          position: const RelativeRect.fromLTRB(100, 100, 100, 100),
          items: [
            PopupMenuItem(
              child: ContextMenuItem(
                icon: Icons.edit,
                label: AppLocalizations.of(context)!.edit,
                onPressed: () => onEdit(context),
              ),
            ),
            PopupMenuItem(
              child: ContextMenuItem(
                icon: Icons.delete,
                label: AppLocalizations.of(context)!.delete,
                onPressed: () => onDelete(context),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

