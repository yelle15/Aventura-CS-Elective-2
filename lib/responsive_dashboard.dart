import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveDashboard extends StatelessWidget {
  const ResponsiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (width < 600) {
            return _buildMobileLayout(context);
          } else if (width < 1000) {
            return _buildTabletLayout(context);
          } else {
            return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

 // ============================================================
// MOBILE
// ============================================================

Widget _buildMobileLayout(BuildContext context) {
  return Scaffold(
    drawer: _buildNavigationDrawer(),
    body: SafeArea(
      child: Column(
        children: [
          _buildMobileHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildMobileStatCards(),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


// ============================================================
// MOBILE HEADER
// ============================================================

Widget _buildMobileHeader() {
  return Builder(
    builder: (context) {
      return Container(
        height: 44,
        width: double.infinity,
        color: Colors.grey.shade800,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    },
  );
}

Widget _buildMobileStatCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard("TASKS", "12"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard("DONE", "8"),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard("PROGRESS", "75%"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard("POINTS", "240"),
            ),
          ],
        ),
      ],
    );
  }

// ============================================================
// TABLET
// ============================================================

Widget _buildTabletLayout(BuildContext context) {
  return Scaffold(
    drawer: _buildNavigationDrawer(),
    body: SafeArea(
      child: Column(
        children: [
          _buildTabletHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildTabletStatCards(),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),

                  const SizedBox(height: 12),

                  _buildContentCard(""),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


// ============================================================
// TABLET HEADER
// ============================================================

Widget _buildTabletHeader() {
  return Builder(
    builder: (context) {
      return Container(
        height: 44,
        width: double.infinity,
        color: Colors.grey.shade800,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    },
  );
}

Widget _buildTabletStatCards() {
  return Row(
    children: [
      Expanded(
        child: _buildStatCard("TASKS", "12"),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _buildStatCard("DONE", "8"),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _buildStatCard("PROGRESS", "75%"),
      ),

      const SizedBox(width: 12),

      Expanded(
        child: _buildStatCard("POINTS", "240"),
      ),
    ],
  );
}
// ============================================================
// NAVIGATION DRAWER
// ============================================================

Widget _buildNavigationDrawer() {
  final isIOS =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  if (isIOS) {
    return Drawer(
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const Icon(
              CupertinoIcons.heart_fill,
              size: 48,
              color: CupertinoColors.systemRed,
            ),

            const SizedBox(height: 40),

            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.home,
                    size: 18,
                    color: CupertinoColors.label,
                  ),
                  SizedBox(width: 14),
                  Text(
                    'DASHBOARD',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.settings,
                    size: 18,
                    color: CupertinoColors.label,
                  ),
                  SizedBox(width: 14),
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.info,
                    size: 18,
                    color: CupertinoColors.label,
                  ),
                  SizedBox(width: 14),
                  Text(
                    'ABOUT',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              onPressed: () {},
              child: const Row(
                children: [
                  Icon(
                    CupertinoIcons.arrow_right_square,
                    size: 18,
                    color: CupertinoColors.label,
                  ),
                  SizedBox(width: 14),
                  Text(
                    'LOGOUT',
                    style: TextStyle(
                      color: CupertinoColors.label,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),

          const Icon(
            Icons.favorite,
            size: 48,
          ),

          const SizedBox(height: 40),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(
              'DASHBOARD',
              style: TextStyle(
                letterSpacing: 2,
              ),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              'SETTINGS',
              style: TextStyle(
                letterSpacing: 2,
              ),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(
              'ABOUT',
              style: TextStyle(
                letterSpacing: 2,
              ),
            ),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(
              'LOGOUT',
              style: TextStyle(
                letterSpacing: 2,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          _buildDesktopSidebar(),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "DASHBOARD",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildDesktopStatCards(),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildContentCard("Today's Activity"),
                                const SizedBox(height: 12),
                                _buildContentCard("Recent Tasks"),
                                const SizedBox(height: 12),
                                _buildContentCard("Progress"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: _buildLargePanel("SUMMARY"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Icon(
            Icons.favorite,
            size: 42,
          ),

          const SizedBox(height: 50),

          _buildSidebarItem(Icons.home, "DASHBOARD"),
          _buildSidebarItem(Icons.settings, "SETTINGS"),
          _buildSidebarItem(Icons.info, "ABOUT"),
          _buildSidebarItem(Icons.logout, "LOGOUT"),
        ],
      ),
    );
  }

  Widget _buildDesktopStatCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("TASKS", "12")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("DONE", "8")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("PROGRESS", "75%")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard("POINTS", "240")),
      ],
    );
  }

  // ============================================================
  // SHARED WIREFRAME COMPONENTS
  // ============================================================

  Widget _buildStatCard(String title, String value) {
    return Container(
      height: 84,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String title) {
    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          Container(
            width: 80,
            height: 12,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildLargePanel(String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label) {
  return AdaptiveNavigationItem(
    icon: icon,
    label: label,
  );
  }
}

class AdaptiveNavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const AdaptiveNavigationItem({
    super.key,
    required this.icon,
    required this.label,
  });

  bool get isIOS {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    if (isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        onPressed: () {},
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: CupertinoColors.label,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.label,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}