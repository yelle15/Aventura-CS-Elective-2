enum ScreenClass { compact, medium, expanded, large }

ScreenClass screenClassFor(double width) {
  if (width < 600) return ScreenClass.compact;
  if (width < 840) return ScreenClass.medium;
  if (width < 1200) return ScreenClass.expanded;
  return ScreenClass.large;
}

int productColumnsFor(double width) {
  switch (screenClassFor(width)) {
    case ScreenClass.compact:
      return 2;
    case ScreenClass.medium:
      return 3;
    case ScreenClass.expanded:
      return 4;
    case ScreenClass.large:
      return 5;
  }
}
