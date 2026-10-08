import 'package:flutter/material.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
class AvatarStackScreen extends StatelessWidget {
  final double height;
  final List<ImageProvider> avatars;

  const AvatarStackScreen({
    super.key,
    required this.height,
    required this.avatars,
  });

  @override
  Widget build(BuildContext context) {
    int showCount = avatars.length > 3 ? 3 : avatars.length;

    return SizedBox(
      width: showCount * (height * 0.6) + height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Display up to 5 avatars
          ...List.generate(
            showCount,
                (index) => Positioned(
              left: index * (height * 0.6),
              child: Container(
                width: height,
                height: height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    (avatars[index] as NetworkImage).url,
                    fit: BoxFit.cover,
                    width: height,
                    height: height,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        Images.placeholder,
                        fit: BoxFit.cover,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Image.asset(
                        Images.placeholder,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),

            ),
          ),

          // Display +N after 5 avatars if there are more
          if (avatars.length > 3)
            Positioned(
              left: showCount * (height * 0.6),
              child: CircleAvatar(
                radius: height / 2,
                backgroundColor: const Color(0xFFFFAB00),
                child: Text(
                  '+${avatars.length - showCount}',
                  style: robotoMedium.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}