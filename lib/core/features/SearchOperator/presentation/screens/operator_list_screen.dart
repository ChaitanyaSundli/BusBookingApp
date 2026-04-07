import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/app_card.dart';
import '../../data/cubit/operator_list_cubit.dart';

class OperatorListScreen extends StatefulWidget {
  final String source;
  final String destination;
  final String? date;

  const OperatorListScreen({
    super.key,
    required this.source,
    required this.destination,
    this.date,
  });

  @override
  State<OperatorListScreen> createState() => _OperatorListScreenState();
}

class _OperatorListScreenState extends State<OperatorListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OperatorListCubit>().searchTrips(
            source: widget.source,
            destination: widget.destination,
            date: widget.date ?? '',
          );
    });
  }

  void _reload() {
    context.read<OperatorListCubit>().searchTrips(
          source: widget.source,
          destination: widget.destination,
          date: widget.date ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.source} → ${widget.destination}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          )
        ],
      ),
      body: BlocBuilder<OperatorListCubit, OperatorListState>(
        builder: (context, state) {
          if (state is OperatorListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OperatorListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          if (state is OperatorListEmpty) {
            return const Center(child: Text('No operators found'));
          }

          if (state is OperatorListSuccess) {
            final operators = state.data;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: operators.length,
              itemBuilder: (_, index) {
                final op = operators[index];
                final primary = Theme.of(context).colorScheme.primary;

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ListTile(
                      onTap: () {
                        context.push(
                          '/bus-list/${widget.source}/${widget.destination}/${op.operatorId}'
                          '?date=${widget.date ?? ''}'
                          '&operator=${Uri.encodeComponent(op.operatorName)}',
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: primary.withValues(alpha: 0.1),
                        child: Text(
                          op.operatorName[0].toUpperCase(),
                          style: TextStyle(color: primary),
                        ),
                      ),
                      title: Text(op.operatorName),
                      subtitle: Text(
                        '${op.totalBuses} buses • from ₹${op.lowestPrice.toStringAsFixed(0)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
