import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_state.dart';
import 'package:project_education/injection_container.dart';


class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(color: AppColors.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Search books, articles, courses...',
                        hintStyle: TextStyle(color: AppColors.textBodyColor),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) =>
                          context.read<SearchBloc>().add(SearchQueryChanged(value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchIdle) {
                      return Center(
                        child: Text(
                          'Search for books, articles, and more',
                          style: TextStyle(color: AppColors.textBodyColor),
                        ),
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is SearchError) {
                      return Center(
                        child: Text(state.message, style: TextStyle(color: AppColors.textBodyColor)),
                      );
                    }

                    final loaded = state as SearchLoaded;
                    if (loaded.results.isEmpty) {
                      return Center(
                        child: Text(
                          'No results for "${loaded.query}"',
                          style: TextStyle(color: AppColors.textBodyColor),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: loaded.results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _SearchResultTile(resource: loaded.results[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final ResourceEntity resource;
  const _SearchResultTile({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: resource.coverImageUrl != null
              ? Image.network(resource.coverImageUrl!, width: 48, height: 68, fit: BoxFit.cover)
              : Container(
                  width: 48,
                  height: 68,
                  color: Colors.white.withOpacity(0.06),
                  child: const Icon(Icons.menu_book_outlined, color: Colors.white24, size: 20),
                ),
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
                style: TextStyle(color: AppColors.textPrimaryColor, fontWeight: FontWeight.w600),
              ),
              if (resource.author != null)
                Text(resource.author!, style: TextStyle(color: AppColors.textBodyColor, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}