import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/feature/resources/domain/entities/continue_reading_item.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/app_bottom_nav_bar.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _currentTab = 0;

  static const _tabs = ['Home', 'Discover', 'Bookmarks', 'Downloads', 'Profile'];
  static const _tabIcons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.bookmark_border,
    Icons.download_outlined,
    Icons.person_outline,
  ];

  void _onTabTapped(int index) {
    if (index == 0) {
      setState(() => _currentTab = 0);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_tabs[index]} coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textBodyColor),
                  ),
                ),
              );
            }

            final loaded = state as HomeLoaded;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (loaded.isOffline) const _OfflineBanner(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Menu coming soon')),
                                );
                              },
                              icon: Icon(Icons.menu, color: AppColors.textPrimaryColor),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Notifications coming soon')),
                                    );
                                  },
                                  icon: Icon(Icons.notifications_none, color: AppColors.textPrimaryColor),
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Text(
                              'Good morning, Alex ',
                              style: TextStyle(
                                color: AppColors.textPrimaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('👋', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to learn something new?',
                          style: TextStyle(color: AppColors.textBodyColor, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        _SearchBar(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
                        ),
                        const SizedBox(height: 28),

                        if (loaded.continueReading.isEmpty)
                          const _EmptyLearningState()
                        else ...[
                          const _SectionHeader(title: 'Continue Reading'),
                          const SizedBox(height: 12),
                          _ContinueReadingRow(items: loaded.continueReading),
                        ],
                        const SizedBox(height: 28),

                        if (loaded.trending.isNotEmpty) ...[
                          const _SectionHeader(title: 'Trending Books'),
                          const SizedBox(height: 12),
                          _TrendingBooksRow(resources: loaded.trending),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
  currentIndex: 0,
  onTap: (index) {
    if (index == 0) return;
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.discover);
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  },
),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.amber.withOpacity(0.15),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            "You're offline — showing saved content",
            style: TextStyle(color: Colors.amber.shade200, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.textBodyColor, size: 20),
            const SizedBox(width: 10),
            Text(
              'Search books, articles, courses...',
              style: TextStyle(color: AppColors.textBodyColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLearningState extends StatelessWidget {
  const _EmptyLearningState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryColor.withOpacity(0.4), AppColors.primaryColor.withOpacity(0.1)],
              ),
            ),
            child: Icon(Icons.auto_stories, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          Text(
            'Your learning journey\nstarts here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimaryColor,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "You haven't read anything yet. Let's change that! Discover great books, articles and courses curated for you.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textBodyColor, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discover coming soon')),
              );
            },
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: const Text('Explore Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          'See all',
          style: TextStyle(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ContinueReadingRow extends StatelessWidget {
  final List<ContinueReadingItem> items;
  const _ContinueReadingRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _ContinueReadingCard(item: items[index]),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  final ContinueReadingItem item;
  const _ContinueReadingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _CoverImage(url: item.resource.coverImageUrl, width: 56, height: 80),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.resource.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.progressPercent / 100,
                    minHeight: 4,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.progressPercent.toStringAsFixed(0)}% complete',
                  style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingBooksRow extends StatelessWidget {
  final List<ResourceEntity> resources;
  const _TrendingBooksRow({required this.resources});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _BookCard(resource: resources[index]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final ResourceEntity resource;
  const _BookCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _CoverImage(url: resource.coverImageUrl, width: 130, height: 150),
          ),
          const SizedBox(height: 8),
          Text(
            resource.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (resource.author != null) ...[
            const SizedBox(height: 2),
            Text(
              resource.author!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textBodyColor, fontSize: 12),
            ),
          ],
          if (resource.rating != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 3),
                Text(resource.rating!.toStringAsFixed(1), style: TextStyle(color: AppColors.textBodyColor, fontSize: 12)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? url;
  final double width;
  final double height;
  const _CoverImage({required this.url, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    if (url == null) return _placeholder();
    return Image.network(
      url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (context, child, progress) => progress == null ? child : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.white.withOpacity(0.06),
      child: const Icon(Icons.menu_book_outlined, color: Colors.white24, size: 28),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(labels.length, (index) {
            final isActive = index == currentIndex;
            final color = isActive ? AppColors.primaryColor : AppColors.textBodyColor;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[index], color: color, size: 22),
                  const SizedBox(height: 4),
                  Text(labels[index], style: TextStyle(color: color, fontSize: 11)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}