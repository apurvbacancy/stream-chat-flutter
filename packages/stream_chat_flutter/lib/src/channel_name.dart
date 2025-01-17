import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

import '../stream_chat_flutter.dart';

/// It shows the current [Channel] name using a [Text] widget.
///
/// The widget uses a [StreamBuilder] to render the channel information image as soon as it updates.
class ChannelName extends StatelessWidget {
  /// Instantiate a new ChannelName
  const ChannelName({
    Key key,
    this.textStyle,
    this.onTap,
    this.titleClick,
  }) : super(key: key);

  /// The style of the text displayed
  final TextStyle textStyle;
  /// The onTap for locators
  final void Function(Channel) onTap;
  final bool titleClick;
  @override
  Widget build(BuildContext context) {
    final client = StreamChat.of(context);
    final channel = StreamChannel.of(context).channel;

    return StreamBuilder<Map<String, dynamic>>(
      stream: channel.extraDataStream,
      initialData: channel.extraData,
      builder: (context, snapshot) {
        return _buildName(snapshot.data, channel.state.members, client,channel);
      },
    );
  }

  Widget _buildName(
    Map<String, dynamic> extraData,
    List<Member> members,
    StreamChatState client,
      Channel channel
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String title;
        if (extraData['name'] == null) {
          final otherMembers =
              members.where((member) => member.userId != client.user.id);
          if (otherMembers.length == 1) {
            title = otherMembers.first.user.name;
          } else if (otherMembers.isNotEmpty) {
            final maxWidth = constraints.maxWidth;
            final maxChars = maxWidth / textStyle.fontSize;
            var currentChars = 0;
            final currentMembers = <Member>[];
            otherMembers.forEach((element) {
              final newLength = currentChars + element.user.name.length;
              if (newLength < maxChars) {
                currentChars = newLength;
                currentMembers.add(element);
              }
            });

            final exceedingMembers =
                otherMembers.length - currentMembers.length;
            title =
                '${currentMembers.map((e) => e.user.name).join(', ')} ${exceedingMembers > 0 ? '+ $exceedingMembers' : ''}';
          } else {
            title = 'No title';
          }
        } else {
          title = extraData['name'];
        }

        return titleClick ?
        InkWell(
          onTap: () =>onTap(channel),
          child: Text(
            title.startsWith('@')?title:'@'+title,
            style: textStyle,
            semanticsLabel: title.startsWith('@')?title:'@'+title,
            overflow: TextOverflow.ellipsis,
          ),
        ):
        Text(
          title.startsWith('@')?title:'@'+title,
          style: textStyle,
          semanticsLabel: title.startsWith('@')?title:'@'+title,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
