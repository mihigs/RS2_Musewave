import 'package:flutter/material.dart';
import 'package:frontend/services/playlist_service.dart';
import 'package:frontend/widgets/confirm_dialog.dart';
import 'package:frontend/widgets/context_menus/shared/context_menu_item.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class PlaylistContextMenu extends StatelessWidget {
  final int playlistId;
  final VoidCallback onDeleteCallback;
  final Widget child;
  final PlaylistService _playlistsService = GetIt.I<PlaylistService>();

  PlaylistContextMenu({
    Key? key,
    required this.playlistId,
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
            _playlistsService.RemovePlaylist(playlistId).then(
              (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.playlist_deleted),
                    duration: const Duration(seconds: 2),
                  ),
                );
                onDeleteCallback();
              },
              onError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.generic_error),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void onEdit(BuildContext context) {
    GoRouter.of(context).push('/playlistEdit/$playlistId');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (LongPressStartDetails details) {
        // Get the position where the user long-pressed
        final tapPosition = details.globalPosition;

        // Get the render box of the overlay to calculate the position
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            tapPosition & const Size(40, 40),
            Offset.zero & overlay.size,
          ),
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
