
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../cubit/city_search_cubit.dart';
import '../cubit/trips_cubit.dart';
import '../widgets/trip_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<CitySearchCubit>().loadCities();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _performSearch() {
    final source = _sourceController.text.trim();
    final destination = _destinationController.text.trim();
    final date = _selectedDate;

    if (source.isEmpty || destination.isEmpty || date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<TripsCubit>().searchTrips(
      source: source,
      destination: destination,
      date: DateFormat('yyyy-MM-dd').format(date),
    );
  }

  void _swapCities() {
    final temp = _sourceController.text;
    _sourceController.text = _destinationController.text;
    _destinationController.text = temp;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickBus'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchForm(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return BlocBuilder<CitySearchCubit, CitySearchState>(
      builder: (context, cityState) {
        final sourceSuggestions = cityState is CitySearchLoaded
            ? cityState.sourceCities
            : <String>[];
        final destinationSuggestions = cityState is CitySearchLoaded
            ? cityState.destinationCities
            : <String>[];

        return AppCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              
              TypeAheadField<String>(
                controller: _sourceController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'From',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _sourceController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _sourceController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                    ),
                  );
                },
                suggestionsCallback: (pattern) {
                  return sourceSuggestions
                      .where((city) => city.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, city) {
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.blue),
                    title: Text(city),
                  );
                },
                onSelected: (city) {
                  _sourceController.text = city;
                  setState(() {});
                },
                hideOnEmpty: true,
                hideOnLoading: true,
              ),
              const SizedBox(height: 8),
              
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.swap_vert, color: Theme.of(context).primaryColor),
                  onPressed: _swapCities,
                  tooltip: 'Swap cities',
                ),
              ),
              const SizedBox(height: 4),
              
              TypeAheadField<String>(
                controller: _destinationController,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'To',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _destinationController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _destinationController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                    ),
                  );
                },
                suggestionsCallback: (pattern) {
                  return destinationSuggestions
                      .where((city) => city.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, city) {
                  return ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.red),
                    title: Text(city),
                  );
                },
                onSelected: (city) {
                  _destinationController.text = city;
                  setState(() {});
                },
                hideOnEmpty: true,
                hideOnLoading: true,
              ),
              const SizedBox(height: 12),
              
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('EEE, dd MMM yyyy').format(_selectedDate!)
                        : 'Select Travel Date',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Search Buses',
                onTap: _performSearch,
                icon: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<TripsCubit, TripsState>(
      builder: (context, state) {
        return switch (state) {
          TripsInitial() => const AppEmptyState(
            message: 'Search for buses to see available trips',
            icon: Icons.directions_bus_outlined,
          ),
          TripsLoading() => const AppLoadingState(message: 'Searching for trips...'),
          TripsError(message: final msg) => AppErrorState(
            message: msg,
            onRetry: _performSearch,
          ),
          TripsLoaded(searchResults: final trips) => trips.isEmpty
              ? const AppEmptyState(
            message: 'No trips found for this route and date',
            icon: Icons.directions_bus_outlined,
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return TripCard(
                trip: trip,
                onTap: () => context.push('/home/trip/${trip.id}'),
              );
            },
          ),
        };
      },
    );
  }
}