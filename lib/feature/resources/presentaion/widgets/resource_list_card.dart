import 'package:flutter/material.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import '../../domain/entities/resource_entity.dart';

class ResourceListCard extends StatelessWidget {
  final ResourceEntity resource;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final bool isBookmarked;

  const ResourceListCard({
    super.key,
    required this.resource,
    required this.onTap,
    required this.onBookmarkTap,
    this.isBookmarked = false,
  });

  String get _typeLabel {
    switch (resource.type) {
      case ResourceType.book:
        return 'Books';
      case ResourceType.article:
        return 'Articles';
      case ResourceType.website:
        return 'Websites';
      case ResourceType.documentation:
        return 'Docs';
      case ResourceType.tutorial:
        return 'Tutorials';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: resource.coverImageUrl != null
                  ? Image.network(
                      resource.coverImageUrl!,
                      width: 56,
                      height: 76,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (resource.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      resource.author!,
                      style: TextStyle(color: AppColors.textBodyColor, fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (resource.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            resource.categoryName!,
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _typeLabel,
                            style: TextStyle(
                              color: AppColors.textBodyColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (resource.readingTimeMinutes != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time, size: 12, color: AppColors.textBodyColor),
                            const SizedBox(width: 3),
                            Text(
                              '${resource.readingTimeMinutes} min read',
                              style: TextStyle(color: AppColors.textBodyColor, fontSize: 11.5),
                            ),
                          ],
                        ),
                      if (resource.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 3),
                            Text(
                              resource.rating!.toStringAsFixed(1),
                              style: TextStyle(color: AppColors.textBodyColor, fontSize: 11.5),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onBookmarkTap,
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? AppColors.primaryColor : AppColors.textBodyColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 76,
      color: Colors.white.withOpacity(0.06),
      child: const Icon(Icons.menu_book_outlined, color: Colors.white24, size: 20),
    );
  }
}