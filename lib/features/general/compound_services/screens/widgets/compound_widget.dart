import 'dart:developer';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waslny/core/exports.dart';
import 'package:waslny/features/general/compound_services/data/models/get_compound_model.dart';

// import 'package:intl/intl.dart';

class CompoundServicesListView extends StatelessWidget {
  const CompoundServicesListView({
    required this.compounds,
    required this.isDriver,
    super.key,
  });

  final List<GetCompoundServicesModelData> compounds;
  final bool isDriver;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: compounds.length,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final bool isLastItem = index == compounds.length - 1;
              return Column(
                children: [
                  ContactCard(contact: compounds[index]),
                  if (isLastItem)
                    (kBottomNavigationBarHeight + 10).h.verticalSpace,
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ContactCard extends StatelessWidget {
  final GetCompoundServicesModelData contact;

  const ContactCard({super.key, required this.contact});

  // --- Launch Logic Functions ---

  // 📞 Function to launch the phone dialer
  void _launchCaller() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: contact.phone.toString());
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Handle error (e.g., show a Snackbar)
      debugPrint(
        'Could not launch phone dialer for ${contact.phone.toString()}',
      );
    }
  }

  // 💬 Function to launch WhatsApp chat
  void _launchWhatsApp() async {
    // Note: The phone number should include the country code (e.g., +1234567890)
    final String url = contact.whatsapp.toString();
    final Uri whatsappUri = Uri.parse(url);

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
      log('DONE');
    } else {
      // Fallback for devices where deep linking doesn't work (e.g., desktop/web)
      final String webUrl = 'https://wa.me/${contact.phone.toString()}';
      final Uri webWhatsappUri = Uri.parse(webUrl);
      if (await canLaunchUrl(webWhatsappUri)) {
        await launchUrl(webWhatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Handle error (e.g., show a Snackbar)
        debugPrint('Could not launch WhatsApp for ${contact.phone.toString()}');
      }
    }
  }

  // --- Widget Build Method ---

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.second2Primary,
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              // Use a NetworkImage or a fallback placeholder
              backgroundImage: contact.image.toString().isNotEmpty
                  ? NetworkImage(contact.image ?? '') as ImageProvider
                  : const AssetImage(
                      ImageAssets.appIcon,
                    ), // Add a placeholder image
              backgroundColor: Colors.grey.shade200,
              child: contact.image!.isEmpty
                  ? Image.asset(ImageAssets.appIcon)
                  : null,
            ),

            const SizedBox(width: 16.0),

            // 📝 Name/Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    (contact.name ?? '-'),
                    style: getMediumStyle(fontSize: 16.sp),
                    maxLines: 3,

                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16.0),

            // 📞 Action Buttons (Call and WhatsApp)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Call Icon Button
                _ContactActionButton(
                  icon: SvgPicture.asset(
                    AppIcons.call,
                    color: AppColors.secondPrimary,
                  ),

                  onPressed: _launchCaller,
                ),

                const SizedBox(width: 8.0),

                // WhatsApp Icon Button
                _ContactActionButton(
                  icon: SvgPicture.asset(
                    AppIcons.whatsapp,
                    color: AppColors.green,
                  ),

                  onPressed: _launchWhatsApp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Private helper widget for a standardized action button
class _ContactActionButton extends StatelessWidget {
  final Widget icon;

  final VoidCallback onPressed;

  const _ContactActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyFieldColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.grey2.withAlpha(9), width: 1.5),
      ),
      padding: EdgeInsets.all(8),
      child: InkWell(onTap: onPressed, child: icon),
    );
  }
}
