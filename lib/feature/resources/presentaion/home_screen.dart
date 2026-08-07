import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/home_state.dart';
import 'package:project_education/injection_container.dart';


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

class _HomeView extends StatelessWidget {
  const _HomeView();

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
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.textBodyColor),
                ),
              );
            }

            final loaded = state as HomeLoaded;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Text(
                    'Good morning, Alex 👋',
                    style: TextStyle(
                      color: AppColors.textPrimaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to learn something new?',
                    style: TextStyle(color: AppColors.textBodyColor, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  _SearchBar(),
                  const SizedBox(height: 28),

                  if (loaded.trending.isNotEmpty) ...[
                    _SectionHeader(title: 'Trending Books'),
                    const SizedBox(height: 12),
                    _ResourceRow(resources: loaded.trending),
                    const SizedBox(height: 28),
                  ],

                  _SectionHeader(title: 'Categories'),
                  const SizedBox(height: 12),
                  _CategoryGrid(categories: loaded.categories),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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

class _ResourceRow extends StatelessWidget {
  final List<dynamic> resources;

  const _ResourceRow({required this.resources});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resources.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final resource = resources[index];
          return _ResourceCard(resource: resource);
        },
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final dynamic resource;

  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: resource.coverImageUrl != null
                ? Image.network(
                    resource.coverImageUrl,
                    height: 150,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderCover(),
                  )
                : _placeholderCover(),
          ),
          const SizedBox(height: 8),
          Text(
            resource.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textPrimaryColor, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (resource.author != null)
            Text(
              resource.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textBodyColor, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      height: 150,
      width: 130,
      color: Colors.white.withOpacity(0.06),
      child: const Icon(Icons.menu_book_outlined, color: Colors.white24, size: 32),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<dynamic> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            category.name,
            style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}