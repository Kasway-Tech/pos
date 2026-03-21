import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasway/app/l10n.dart';
import 'package:kasway/app/widgets/blur_app_bar.dart';

import '../../../app/theme/theme_cubit.dart';
import '../../../app/theme/theme_state.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  static final List<ColorOption> _colorOptions = [
    ColorOption('Red', Colors.red),
    ColorOption('Pink', Colors.pink),
    ColorOption('Purple', Colors.purple),
    ColorOption('Deep Purple', Colors.deepPurple),
    ColorOption('Indigo', Colors.indigo),
    ColorOption('Blue', Colors.blue),
    ColorOption('Light Blue', Colors.lightBlue),
    ColorOption('Cyan', Colors.cyan),
    ColorOption('Teal', Colors.teal),
    ColorOption('Green', Colors.green),
    ColorOption('Light Green', Colors.lightGreen),
    ColorOption('Lime', Colors.lime),
    ColorOption('Yellow', Colors.yellow),
    ColorOption('Amber', Colors.amber),
    ColorOption('Orange', Colors.orange),
    ColorOption('Deep Orange', Colors.deepOrange),
    ColorOption('Brown', Colors.brown),
    ColorOption('Blue Grey', Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BlurAppBar(title: Text(context.l10n.themeTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final l10n = context.l10n;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isLargeScreen = constraints.maxWidth >= 900;

                  final themeModePicker = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themeMode,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: const Icon(Icons.settings_suggest),
                              label: Text(l10n.themeModeSystem),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.light_mode),
                              label: Text(l10n.themeModeLight),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.dark_mode),
                              label: Text(l10n.themeModeDark),
                            ),
                          ],
                          selected: {state.themeMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            context.read<ThemeCubit>().setThemeMode(
                              newSelection.first,
                            );
                          },
                        ),
                      ),
                    ],
                  );

                  final colorPicker = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themePrimaryColor,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isLargeScreen ? 6 : 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _colorOptions.length,
                        itemBuilder: (context, index) {
                          final option = _colorOptions[index];
                          final isSelected =
                              state.seedColor.toARGB32() ==
                              option.color.toARGB32();

                          return InkWell(
                            onTap: () {
                              context.read<ThemeCubit>().setSeedColor(
                                option.color,
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: option.color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color:
                                          option.color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                      size: 32,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed:
                            state.seedColor.toARGB32() ==
                                ThemeState.defaultSeedColor.toARGB32()
                            ? null
                            : () => context.read<ThemeCubit>().resetSeedColor(),
                        icon: const Icon(Icons.restart_alt),
                        label: Text(l10n.themeResetToDefault),
                      ),
                    ],
                  );

                  final preview = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themePreview,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.themePreviewSampleCard,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.themePreviewSampleCardBody,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  FilledButton(
                                    onPressed: () {},
                                    child: Text(l10n.themePreviewFilledButton),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Text(l10n.themePreviewOutlinedButton),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(l10n.themePreviewTextButton),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: 0.7,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Chip(
                                    label: const Text('Chip'),
                                    avatar: const Icon(Icons.star, size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: const Text('Selected'),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  if (isLargeScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                themeModePicker,
                                const SizedBox(height: 32),
                                colorPicker,
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHigh,
                                ),
                              ),
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: preview,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      themeModePicker,
                      const SizedBox(height: 32),
                      colorPicker,
                      const SizedBox(height: 32),
                      preview,
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class ColorOption {
  const ColorOption(this.name, this.color);

  final String name;
  final Color color;
}
