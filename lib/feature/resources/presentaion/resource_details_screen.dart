import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/feature/profile/domain/usecase/log_resource_view_usecase.dart';
import 'package:project_education/feature/resources/presentaion/bloc/resource_detail_bloc/resource_details_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/resource_detail_bloc/resource_details_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/resource_detail_bloc/resource_details_state.dart';
import 'package:project_education/feature/resources/presentaion/reading_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/injection_container.dart';


class ResourceDetailsScreen extends StatelessWidget {
  final String resourceId;

  const ResourceDetailsScreen({super.key, required this.resourceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ResourceDetailsBloc>()..add(ResourceDetailsStarted(resourceId)),
      child: const _ResourceDetailsView(),
    );
  }
}

class _ResourceDetailsView extends StatefulWidget {
  const _ResourceDetailsView();

  @override
  State<_ResourceDetailsView> createState() => _ResourceDetailsViewState();
}

class _ResourceDetailsViewState extends State<_ResourceDetailsView> {
  bool _descriptionExpanded = false;

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocBuilder<ResourceDetailsBloc, ResourceDetailsState>(
        builder: (context, state) {
          if (state is ResourceDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ResourceDetailsError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: AppColors.textBodyColor)),
            );
          }

          final loaded = state as ResourceDetailsLoaded;
          final resource = loaded.resource;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.backgroundColor,
                expandedHeight: 320,
                pinned: true,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: Icon(Icons.share, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: resource.coverImageUrl != null
                      ? Image.network(resource.coverImageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.white.withOpacity(0.06)),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              resource.title,
                              style: TextStyle(
                                color: AppColors.textPrimaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (resource.categoryName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                resource.categoryName!,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (resource.author != null) ...[
                        const SizedBox(height: 6),
                        Text(resource.author!, style: TextStyle(color: AppColors.textBodyColor)),
                      ],
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          if (resource.rating != null) ...[
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              resource.rating!.toStringAsFixed(1),
                              style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (loaded.isDownloaded) ...[
                            const Icon(Icons.check_circle, size: 15, color: Colors.greenAccent),
                            const SizedBox(width: 4),
                            const Text('Available Offline', style: TextStyle(color: Colors.greenAccent, fontSize: 12.5)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ActionButton(
  icon: Icons.menu_book_outlined,
  label: 'Read',
  onTap: () {
    sl<LogResourceViewUseCase>().call(resource.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReadingScreen(resource: resource)),
    );
  },
),
_ActionButton(
  icon: Icons.public,
  label: 'Visit',
  onTap: () {
    sl<LogResourceViewUseCase>().call(resource.id);
    _openUrl(resource.resourceUrl);
  },
),
                          _ActionButton(
                            icon: Icons.download_outlined,
                            label: loaded.isDownloaded ? 'Saved' : 'Download',
                            onTap: loaded.isDownloaded
                                ? null
                                : () => context
                                    .read<ResourceDetailsBloc>()
                                    .add(const ResourceDetailsDownloadRequested()),
                          ),
                          _ActionButton(
                            icon: loaded.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            label: loaded.isBookmarked ? 'Saved' : 'Bookmark',
                            highlighted: loaded.isBookmarked,
                            onTap: () => context
                                .read<ResourceDetailsBloc>()
                                .add(const ResourceDetailsBookmarkToggled()),
                          ),
                          _ActionButton(
                            icon: Icons.share_outlined,
                            label: 'Share',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      if (resource.description != null) ...[
                        Text(
                          'About this resource',
                          style: TextStyle(
                            color: AppColors.textPrimaryColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resource.description!,
                          maxLines: _descriptionExpanded ? null : 3,
                          overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textBodyColor, height: 1.5),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                          child: Text(
                            _descriptionExpanded ? 'Show less' : 'Show more',
                            style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      if (loaded.related.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Related Resources',
                              style: TextStyle(
                                color: AppColors.textPrimaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'See all',
                              style: TextStyle(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: loaded.related.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final related = loaded.related[index];
                              return GestureDetector(
                                onTap: () => Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.resourceDetails,
                                  arguments: related.id,
                                ),
                                child: SizedBox(
                                  width: 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: related.coverImageUrl != null
                                            ? Image.network(
                                                related.coverImageUrl!,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.white.withOpacity(0.06),
                                              ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        related.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 12.5, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool highlighted;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.primaryColor : AppColors.textPrimaryColor;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: AppColors.textBodyColor, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}