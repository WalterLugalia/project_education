import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:project_education/core/config/theme/app_colors.dart';
import 'package:project_education/feature/resources/domain/entities/resource_entity.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_bloc.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_event.dart';
import 'package:project_education/feature/resources/presentaion/bloc/reading_bloc/reading_state.dart';
import 'package:project_education/injection_container.dart';


class ReadingScreen extends StatelessWidget {
  final ResourceEntity resource;
  const ReadingScreen({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReadingBloc>(param1: resource)..add(const ReadingStarted()),
      child: _ReadingView(resource: resource),
    );
  }
}

class _ReadingView extends StatefulWidget {
  final ResourceEntity resource;
  const _ReadingView({required this.resource});

  @override
  State<_ReadingView> createState() => _ReadingViewState();
}

class _ReadingViewState extends State<_ReadingView> {
  final _scrollController = ScrollController();
  double _fontSize = 16;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final percent = (_scrollController.offset / max * 100).clamp(0, 100);
    context.read<ReadingBloc>().add(ReadingProgressChanged(percent.toDouble()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.resource.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showFontSizeSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, state) {
          if (state is ReadingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReadingUnavailable) {
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

          final loaded = state as ReadingLoaded;

          if (loaded.format == ContentFormat.pdf) {
            return Center(
              child: Text(
                'PDF viewing isn\'t wired up yet — file saved at:\n${loaded.content}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textBodyColor),
              ),
            );
          }

          return Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: MarkdownBody(
                data: loaded.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(color: AppColors.textPrimaryColor, fontSize: _fontSize, height: 1.6),
                  h1: TextStyle(color: AppColors.textPrimaryColor, fontSize: _fontSize + 10),
                  h2: TextStyle(color: AppColors.textPrimaryColor, fontSize: _fontSize + 6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFontSizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text('Font size', style: TextStyle(color: AppColors.textPrimaryColor)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  onChanged: (v) {
                    setModalState(() {});
                    setState(() => _fontSize = v);
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