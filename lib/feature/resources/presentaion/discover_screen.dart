import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/presentaion/bloc/discover_bloc/discover_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/discover_bloc/discover_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/discover_bloc/discover_state.dart';
import 'package:project_education/feature/resources/presentaion/widgets/resource_list_card.dart';
import 'package:project_education/injection_container.dart';
import 'package:project_education/shared/widgets/app_bottom_nav_bar.dart';


class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DiscoverBloc>()..add(const DiscoverStarted()),
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatelessWidget {
  const _DiscoverView();

  static const _typeFilters = <String?, String>{
    null: 'All',
    'book': 'Books',
    'article': 'Articles',
    'website': 'Websites',
    'documentation': 'Docs',
    'tutorial': 'Tutorials',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<DiscoverBloc, DiscoverState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.search),
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
                            'Search anything to learn...',
                            style: TextStyle(color: AppColors.textBodyColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: _typeFilters.entries.map((entry) {
                      final selectedType = state is DiscoverLoaded ? state.selectedType : null;
                      final isSelected = selectedType == entry.key;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (_) => context
                              .read<DiscoverBloc>()
                              .add(DiscoverTypeFilterChanged(entry.key)),
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: Colors.white.withOpacity(0.06),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textBodyColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, DiscoverState state) {
    if (state is DiscoverLoading || state is DiscoverInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiscoverError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.message, style: TextStyle(color: AppColors.textBodyColor)),
        ),
      );
    }

    final loaded = state as DiscoverLoaded;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (loaded.newReleases.isNotEmpty) ...[
          _SectionHeader(title: 'New Releases'),
          const SizedBox(height: 12),
          ...loaded.newReleases.map((resource) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(context, resource),
              )),
          const SizedBox(height: 12),
        ],

        if (loaded.featuredCategory != null && loaded.featuredCategoryResources.isNotEmpty) ...[
          _SectionHeader(title: 'Trending in ${loaded.featuredCategory!.name}'),
          const SizedBox(height: 12),
          ...loaded.featuredCategoryResources.map((resource) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCard(context, resource),
              )),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ResourceEntity resource) {
    return ResourceListCard(
      resource: resource,
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.resourceDetails,
        arguments: resource.id,
      ),
      onBookmarkTap: () => context.read<DiscoverBloc>().add(DiscoverBookmarkToggled(resource.id)),
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