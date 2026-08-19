import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/core/config/route/app_routes.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/search_bloc/search_state.dart';
import 'package:project_education/feature/resources/presentaion/widgets/resource_list_card.dart';
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

  static const _tabs = <String, String>{
    'book': 'Books',
    'article': 'Articles',
    'website': 'Websites',
    'documentation': 'Docs',
    'tutorial': 'Tutorials',
  };

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimaryColor),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: TextStyle(color: AppColors.textPrimaryColor),
                      decoration: InputDecoration(
                        hintText: 'Search anything to learn...',
                        hintStyle: TextStyle(color: AppColors.textBodyColor),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: AppColors.textBodyColor, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  context.read<SearchBloc>().add(const SearchQueryChanged(''));
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        context.read<SearchBloc>().add(SearchQueryChanged(value));
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),

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
                  final filtered = loaded.filteredResults;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "${loaded.allResults.length} results for '${loaded.query}'",
                          style: TextStyle(color: AppColors.textBodyColor, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 32,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: _tabs.entries.map((entry) {
                            final isSelected = loaded.selectedType == entry.key;
                            return Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: GestureDetector(
                                onTap: () => context
                                    .read<SearchBloc>()
                                    .add(SearchTypeTabChanged(entry.key)),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      entry.value,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.textBodyColor,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (isSelected)
                                      Container(
                                        height: 2,
                                        width: 20,
                                        color: AppColors.primaryColor,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'No ${_tabs[loaded.selectedType]?.toLowerCase()} found',
                                  style: TextStyle(color: AppColors.textBodyColor),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final resource = filtered[index];
                                  return ResourceListCard(
                                    resource: resource,
                                    onTap: () => Navigator.of(context).pushNamed(
                                      AppRoutes.resourceDetails,
                                      arguments: resource.id,
                                    ),
                                    onBookmarkTap: () {},
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}