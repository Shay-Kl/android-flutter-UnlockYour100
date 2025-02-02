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
  // New validation error variable.
  String? errorText;
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<SetEditResult?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isNewSet ? 'Create New Set' : 'Edit Set'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    // Updated decoration to show errorText if any.
                    decoration: InputDecoration(
                        hintText: 'Set name', errorText: errorText),
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
                  // Validate empty name.
                  if (newName.isEmpty) {
                    setState(() {
                      errorText = "Name cannot be empty";
                    });
                    return;
                  }
                  // Validate name duplicate (ignoring initial name).
                  if (setProvider.setExists(newName) &&
                      newName != initialName) {
                    setState(() {
                      errorText = "Set name already exists";
                    });
                    return;
                  }
                  // Clear error if validation passes.
                  setState(() {
                    errorText = null;
                  });
                  if (newName != initialName ||
                      selectedColorKey != initialColor) {
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
