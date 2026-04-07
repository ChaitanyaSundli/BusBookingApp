import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quick_bus/core/features/home/data/cubit/stops_cubit.dart';
import 'package:quick_bus/core/network/di.dart';

import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();

  final LayerLink _sourceLayerLink = LayerLink();
  final LayerLink _destinationLayerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late Future<List<Map<String, dynamic>>> _operatorsFuture;

  @override
  void initState() {
    super.initState();

    _sourceController.addListener(_onSourceChanged);
    _destinationController.addListener(_onDestinationChanged);
    _operatorsFuture = DI.searchBusRepository.fetchAllOperators();
  }

  void _onSourceChanged() {
    final cubit = context.read<StopsCubit>();
    if (_sourceController.text.isNotEmpty) {
      cubit.fetchSuggestions(_sourceController.text);
      _showOverlay('source', _sourceLayerLink);
    } else {
      cubit.clearSuggestions();
      _removeOverlay();
    }
  }

  void _onDestinationChanged() {
    final cubit = context.read<StopsCubit>();
    if (_destinationController.text.isNotEmpty) {
      cubit.fetchSuggestions(_destinationController.text);
      _showOverlay('destination', _destinationLayerLink);
    } else {
      cubit.clearSuggestions();
      _removeOverlay();
    }
  }

  void _showOverlay(String fieldType, LayerLink layerLink) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 350,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: BlocBuilder<StopsCubit, StopsState>(
              builder: (context, state) {
                if (state is StopsLoading) {
                  return Container(
                    height: 80,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (state is StopsSuccess) {
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: state.stops.length,
                      itemBuilder: (context, index) {
                        final city = state.stops[index].cityName;
                        return ListTile(
                          leading: const Icon(Icons.location_city, size: 20),
                          title: Text(city, style: const TextStyle(fontSize: 14)),
                          onTap: () {
                            if (fieldType == 'source') {
                              _sourceController.text = city;
                            } else {
                              _destinationController.text = city;
                            }
                            _removeOverlay();
                            context.read<StopsCubit>().clearSuggestions();
                          },
                        );
                      },
                    ),
                  );
                }

                if (state is StopsEmpty) {
                  return Container(
                    height: 60,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'No cities found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                if (state is StopsError) {
                  return Container(
                    height: 60,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        'Error loading suggestions',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Your Bus Ticket'), elevation: 0),
      body: GestureDetector(
        onTap: _removeOverlay,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                CompositedTransformTarget(
                  link: _sourceLayerLink,
                  child: TextField(
                    controller: _sourceController,
                    onTap: () {
                      if (_sourceController.text.isNotEmpty) {
                        _showOverlay('source', _sourceLayerLink);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter departure city',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'To',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                CompositedTransformTarget(
                  link: _destinationLayerLink,
                  child: TextField(
                    controller: _destinationController,
                    onTap: () {
                      if (_destinationController.text.isNotEmpty) {
                        _showOverlay('destination', _destinationLayerLink);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter destination city',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Departure Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: 'Select date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Search Buses',
                    onTap: () {
                      final source = Uri.encodeComponent(_sourceController.text.trim());
                      final destination =
                          Uri.encodeComponent(_destinationController.text.trim());
                      final date = Uri.encodeQueryComponent(_dateController.text.trim());
                      context.push('/operator-list/$source/$destination?date=$date');
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our Partner Operators',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _operatorsFuture = DI.searchBusRepository.fetchAllOperators();
                        });
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _operatorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    final operators = snapshot.data ?? const [];
                    if (operators.isEmpty) {
                      return const Text('No operators available right now.');
                    }

                    return Column(
                      children: operators.map((op) {
                        final routes = (op['routes'] as List?) ?? const [];
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => context.push(
                              '/operators/${op['operator_id']}?name=${Uri.encodeComponent(op['operator_name']?.toString() ?? '')}',
                            ),
                            leading: const Icon(Icons.business),
                            title: Text(op['operator_name']?.toString() ?? 'Operator'),
                            subtitle: Text(
                              '${op['total_buses'] ?? 0} buses • from ₹${(op['starting_price'] as num?)?.toStringAsFixed(0) ?? '0'}\n${routes.take(2).join('  •  ')}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}
