import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/feature/profile/domain/entities/profile_stats_entity.dart';
import 'package:project_education/feature/profile/presentation/edit_profile_screen.dart';
import 'package:project_education/feature/profile/presentation/bloc/profile_bloc.dart';
import 'package:project_education/feature/profile/presentation/bloc/profile_event.dart';
import 'package:project_education/feature/profile/presentation/bloc/profile_state.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/app_bottom_nav_bar.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(const ProfileStarted()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) return const Center(child: CircularProgressIndicator());
            if (state is ProfileError) {
              return Center(child: Text(state.message, style: TextStyle(color: AppColors.textBodyColor)));
            }

            final loaded = state as ProfileLoaded;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR LEARNING SPACE',
                            style: TextStyle(color: AppColors.primaryColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('Profile', style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.settings_outlined, color: AppColors.textPrimaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      backgroundImage: loaded.profile.avatarUrl != null ? NetworkImage(loaded.profile.avatarUrl!) : null,
                      child: loaded.profile.avatarUrl == null
                          ? Icon(Icons.person, color: AppColors.textBodyColor, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loaded.profile.fullName ?? 'Add your name',
                              style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 17, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          if (loaded.joinedAt != null)
                            Text('Joined ${_monthYear(loaded.joinedAt!)}', style: TextStyle(color: AppColors.textBodyColor, fontSize: 12.5)),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<ProfileBloc>(), child: const EditProfileScreen())),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('Edit profile', style: TextStyle(color: AppColors.primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward, size: 13, color: AppColors.primaryColor),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Resources', value: '${loaded.stats.resourcesEngaged}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(label: 'Read', value: '${loaded.stats.readingHours.toStringAsFixed(0)} hrs')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(label: 'Bookmarks', value: '${loaded.stats.bookmarksCount}')),
                  ],
                ),
                const SizedBox(height: 28),

                Text('Learning Insights', style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InsightBox(
                        label: 'Resources read',
                        value: '${loaded.stats.resourcesEngaged}',
                        delta: loaded.stats.readThisMonthPercentDelta,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StreakBox(days: loaded.stats.readingStreakDays),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _CategoryBreakdownCard(breakdown: loaded.stats.categoryBreakdown),

                if (loaded.stats.mostVisited.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text('Most visited', style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: loaded.stats.mostVisited.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final resource = loaded.stats.mostVisited[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.resourceDetails, arguments: resource.id),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resource.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 12.5, fontWeight: FontWeight.w600)),
                                const Spacer(),
                                if (resource.categoryName != null)
                                  Text(resource.categoryName!, style: TextStyle(color: AppColors.textBodyColor, fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          if (index == 0) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          if (index == 1) Navigator.of(context).pushReplacementNamed(AppRoutes.discover);
        },
      ),
    );
  }

  String _monthYear(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textBodyColor, fontSize: 11.5)),
      ]),
    );
  }
}

class _InsightBox extends StatelessWidget {
  final String label;
  final String value;
  final int delta;
  const _InsightBox({required this.label, required this.value, required this.delta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: AppColors.textBodyColor, fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: AppColors.primaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
        if (delta != 0) ...[
          const SizedBox(height: 4),
          Text('${delta > 0 ? '↑' : '↓'} ${delta.abs()}% this month',
              style: TextStyle(color: delta > 0 ? Colors.greenAccent : Colors.redAccent, fontSize: 11)),
        ],
      ]),
    );
  }
}

class _StreakBox extends StatelessWidget {
  final int days;
  const _StreakBox({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Reading streak', style: TextStyle(color: AppColors.textBodyColor, fontSize: 12)),
        const SizedBox(height: 6),
        Row(children: [
          Text('$days', style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Text('🔥', style: TextStyle(fontSize: 16)),
        ]),
        const SizedBox(height: 4),
        Text('days in a row', style: TextStyle(color: AppColors.textBodyColor, fontSize: 11)),
      ]),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;
  const _CategoryBreakdownCard({required this.breakdown});

  static const _colors = [Color(0xFF7C6FF0), Color(0xFF4FC3E8), Color(0xFF52D68A)];

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Text('Start reading to see your favorite category here.', style: TextStyle(color: AppColors.textBodyColor, fontSize: 12.5)),
      );
    }

    final top = breakdown.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Favorite category', style: TextStyle(color: AppColors.textBodyColor, fontSize: 12)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(top.categoryName, style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 15, fontWeight: FontWeight.w700)),
          Text('${top.percent.toStringAsFixed(0)}%', style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: List.generate(breakdown.length.clamp(0, 3), (i) {
              return Expanded(
                flex: (breakdown[i].percent * 10).round().clamp(1, 1000),
                child: Container(height: 6, color: _colors[i % _colors.length]),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: breakdown.take(3).toList().asMap().entries.map((e) {
            return Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _colors[e.key % _colors.length], shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(e.value.categoryName, style: TextStyle(color: AppColors.textBodyColor, fontSize: 11)),
            ]);
          }).toList(),
        ),
      ]),
    );
  }
}