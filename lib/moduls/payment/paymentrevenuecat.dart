import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:plantsai/languages/i10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaywallView extends StatefulWidget {
  final Offering offering;
  final bool hasCooldown;
  final bool loadingX;

  const PaywallView({
    super.key,
    required this.offering,
    this.hasCooldown = true,
    this.loadingX = false,
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
    _showCloseButton = widget.loadingX;
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
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
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
        Text(
          AppLocalizations.of(context).unlimitedAccess,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: [
        BenefitRow(title: AppLocalizations.of(context).identifications, icon: Icons.compost),
        BenefitRow(title: AppLocalizations.of(context).limitlessChat, icon: Icons.chat_bubble),
        BenefitRow(title: AppLocalizations.of(context).tips, icon: Icons.grass),
        BenefitRow(title: AppLocalizations.of(context).tips2, icon: Icons.forest),
        BenefitRow(title: AppLocalizations.of(context).removeAds, icon: Icons.block),
      ],
    );
  }

  Widget _buildProductList() {
    // log('/////////widget.offe//////////////${widget.offering}');
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
          : Text(
              AppLocalizations.of(context).upgradeNow,
              style: const TextStyle(
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
    const url = "https://sites.google.com/view/privacy-policy-inudev/strona-g%C5%82%C3%B3wna";

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
    final bgGradient = LinearGradient(
      colors: isSelected ? [Colors.blueAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.1)] : [const Color(0xFF1a1a2e), const Color(0xFF0f3460)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.white10,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (discountValue != null)
                        Text(
                          '${product.storeProduct.price.toInt() * 12} ${product.storeProduct.currencyCode}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPriceText(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (discountPercent != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
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
            if (product.storeProduct.introductoryPrice != null && product.storeProduct.introductoryPrice?.price == 0) ...[
              const SizedBox(width: 8),
              const Text(
                "FREE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  color: Colors.greenAccent,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blueAccent : Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  String _getTitleText() {
    final introductoryPrice = product.storeProduct.introductoryPrice;
    if (introductoryPrice != null) {
      return '${introductoryPrice.periodNumberOfUnits}-${introductoryPrice.periodUnit.name.toLowerCase()} Trial';
    }
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
    final introductoryPrice = product.storeProduct.introductoryPrice;
    final fullPricePhase = product.storeProduct.defaultOption?.fullPricePhase;
    if (introductoryPrice != null && fullPricePhase != null) {
      return 'then ${product.storeProduct.priceString} per ${fullPricePhase.billingPeriod?.value ?? 0} ${fullPricePhase.billingPeriod?.unit.name.toLowerCase()}';
    }
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
