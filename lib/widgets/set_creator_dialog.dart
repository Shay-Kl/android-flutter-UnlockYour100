import 'package:flutter/material.dart';
import 'package:project/models/colors.dart';
import 'package:project/providers/set_provider.dart';

class SetEditResult {
  final String name;
  final ColorSchemeKey color;

  SetEditResult(this.name, this.color);
}

Future<SetEditResult?> showNewSetDialog(
    BuildContext context, SetProvider setProvider, bool isNewSet,
    {ColorSchemeKey initialColor = ColorSchemeKey.Default,
    String initialName = ""}) async {
  final TextEditingController controller =
      TextEditingController(text: initialName);
  ColorSchemeKey selectedColorKey = initialColor;
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<SetEditResult?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text((isNewSet) ? 'Create New Set' : 'Edit Set'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Set name'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    width: double.maxFinite,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: ColorSchemeKey.values.length,
                      itemBuilder: (context, index) {
                        final colorKey = ColorSchemeKey.values[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedColorKey = colorKey;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorKey.getColorFromScheme(
                                  Theme.of(context).colorScheme),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedColorKey == colorKey
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: selectedColorKey == colorKey ? 3 : 1,
                              ),
                            ),
                            child: selectedColorKey == colorKey
                                ? Icon(
                                    Icons.check,
                                    color: colorScheme.onSurface,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty &&
                      (newName != initialName ||
                          selectedColorKey != initialColor)) {
                    Navigator.pop(
                        context, SetEditResult(newName, selectedColorKey));
                  } else {
                    Navigator.pop(context, null);
                  }
                },
                child: Text(isNewSet ? 'Create' : 'Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
