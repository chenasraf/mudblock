import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logo = SizedBox.square(
        dimension: 288, child: Image.asset('assets/images/logo/logo@4x.png'));
    final title = ListTile(
      title: Text(
        'Mudblock',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: const Text('By Chen Asraf'),
    );
    final version = ListTile(
      title: const Text(
        'Version: ',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: FutureBuilder(
        future: PackageInfo.fromPlatform().then((pkg) => pkg.version),
        builder: (context, snapshot) => Text(
          snapshot.hasData ? snapshot.data ?? '-' : '...',
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Mudblock'),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: ListView(
            children: [
              if (MediaQuery.of(context).size.width <= 600) ...[
                logo,
                title,
                version,
              ],
              if (MediaQuery.of(context).size.width > 600) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    logo,
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          title,
                          version,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              ListTile(
                title: const Text('GitHub'),
                subtitle: const Text('View the source code on GitHub'),
                onTap: () => launchUrl(Uri.parse('https://github.com/chenasraf/mudblock')),
              ),
              ListTile(
                title: const Text('Discord'),
                subtitle: const Text('Join our Discord server'),
                onTap: () => launchUrl(Uri.parse('https://discord.gg/22XRWSyK')),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                subtitle: const Text('https://mudblock.app/privacy'),
                onTap: () => launchUrl(Uri.parse('https://mudblock.app/privacy')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

