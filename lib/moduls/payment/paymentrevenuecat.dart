import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaywallView extends StatefulWidget {
  final Offering offering;
  final bool hasCooldown;

  const PaywallView({
    super.key,
    required this.offering,
    this.hasCooldown = true,
  });

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  Package? _selectedProduct;
  bool _isLoading = false;
  bool _showCloseButton = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupInitialProduct();
    if (widget.hasCooldown) {
      _startCooldownTimer();
    }
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_scaleController);
  }

  void _setupInitialProduct() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedProduct = widget.offering.availablePackages.firstWhere(
          (package) => package.storeProduct.introductoryPrice != null,
          orElse: () => widget.offering.availablePackages.first,
        );
      });
    });
  }

  void _startCooldownTimer() {
    setState(() {
      _progress = 0.1;
    });
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showCloseButton = true;
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCloseButton(),
                _buildHeader(),
                _buildBenefits(),
                const SizedBox(height: 16),
                _buildProductList(),
                const SizedBox(height: 16),
                _buildUpgradeButton(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: widget.hasCooldown && !_showCloseButton
          ? SizedBox(
              width: 30,
              height: 30,
              child: TweenAnimationBuilder(
                  duration: const Duration(seconds: 5),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 3,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                      ),
                    );
                  }),
            )
          : GestureDetector(
              child: const Icon(Icons.close, size: 30),
              onTap: () => Navigator.of(context).pop(),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnimation,
          child: const Icon(
            Icons.eco,
            size: 80,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Unlimited Access',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return const Column(
      children: [
        BenefitRow(title: 'Unlimited Identifications plants', icon: Icons.compost),
        BenefitRow(title: 'Limitless Chat Messages', icon: Icons.chat_bubble),
        BenefitRow(title: 'Tips for watering a flower', icon: Icons.grass),
        BenefitRow(title: 'Tree recognition in the park', icon: Icons.forest),
        BenefitRow(title: 'Experience without annoying advertising', icon: Icons.block),
      ],
    );
  }

  Widget _buildProductList() {
    return Column(
      children: [
        if (widget.offering.annual != null)
          ProductView(
            product: widget.offering.annual!,
            isSelected: _selectedProduct == widget.offering.annual,
            discountPercent: _getAnnualComparedToWeekly(),
            discountValue: _getDiscountValue(),
            onTap: () => setState(() => _selectedProduct = widget.offering.annual),
          ),
        if (widget.offering.weekly != null)
          ProductView(
            product: widget.offering.weekly!,
            isSelected: _selectedProduct == widget.offering.weekly,
            onTap: () => setState(() => _selectedProduct = widget.offering.weekly),
          ),
      ].separated(const SizedBox(height: 16)),
    );
  }

  Widget _buildUpgradeButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleUpgrade,
      style: ElevatedButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(double.infinity, 50),
        padding: EdgeInsets.zero,
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'Upgrade Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _restorePurchases,
          child: const Text('Restore'),
        ),
        TextButton(
          onPressed: _showTerms,
          child: const Text('Terms of Use & Privacy Policy'),
        ),
      ],
    );
  }

  Future<void> _setupIsPro() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);
      Purchases.addCustomerInfoUpdateListener(_updateProStatus);
    } catch (e) {
      print("Error while checking subscription status: $e");
    }
  }

  bool isProActive = false;
  void _updateProStatus(CustomerInfo customerInfo) {
    EntitlementInfo? entitlement = customerInfo.entitlements.all['Pro'];
    isProActive = (entitlement?.isActive ?? false);
  }

  void _handleUpgrade() async {
    if (_selectedProduct == null) return;
    setState(() => _isLoading = true);
    final navigator = Navigator.of(context);
    try {
      final customerInfo = await Purchases.purchaseStoreProduct(_selectedProduct!.storeProduct);
      if (customerInfo.entitlements.all['Pro']?.isActive ?? false) {
        navigator.pop();
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _restorePurchases() {
    Purchases.restorePurchases();
  }

  void _showTerms() async {
    // Show terms and conditions dialog
    const url = "https://www.google.com";

    if (await canLaunchUrlString(url)) {
      launchUrlString(url);
    }
  }

  int? _getAnnualComparedToWeekly() {
    final weekly = widget.offering.weekly;
    final annual = widget.offering.annual;

    if (weekly == null || annual == null) return null;

    final weeklyAnnualPrice = weekly.storeProduct.price.toInt() * 52;
    final annualPrice = annual.storeProduct.price.toInt();

    return ((weeklyAnnualPrice - annualPrice) / weeklyAnnualPrice * 100).toInt();
  }

  double? _getDiscountValue() {
    final weekly = widget.offering.weekly;
    if (weekly == null) return null;

    return weekly.storeProduct.price.toInt() * 52;
  }
}

class BenefitRow extends StatelessWidget {
  final String title;
  final IconData icon;

  const BenefitRow({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}

class ProductView extends StatelessWidget {
  final Package product;
  final bool isSelected;
  final int? discountPercent;
  final double? discountValue;
  final VoidCallback onTap;

  const ProductView({
    super.key,
    required this.product,
    required this.isSelected,
    this.discountPercent,
    this.discountValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getTitleText(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (discountValue != null)
                        Text(
                          product.storeProduct.priceString,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  Text(_getPriceText()),
                ],
              ),
            ),
            if (discountPercent != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'SAVE $discountPercent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleText() {
    return switch (product.packageType) {
      PackageType.annual => 'Yearly',
      PackageType.weekly => 'Weekly',
      _ => 'Subscription',
    };
  }

  String _getPeriodText() {
    return switch (product.packageType) {
      PackageType.annual => 'year',
      PackageType.weekly => 'week',
      _ => '',
    };
  }

  String _getPriceText() {
    // Implement logic to get the price text
    return '${product.storeProduct.priceString} / ${_getPeriodText()}';
  }
}

extension SeparatedWidgets on List<Widget> {
  List<Widget> separated(Widget separator) {
    if (isEmpty) return [];
    if (length == 1) return this;

    return List.generate(length * 2 - 1, (index) {
      if (index.isEven) {
        return this[index ~/ 2];
      } else {
        return separator;
      }
    });
  }
}
