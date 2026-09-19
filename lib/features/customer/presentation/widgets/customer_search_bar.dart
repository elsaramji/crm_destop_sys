import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/customer_list_cubit.dart';
import '../cubit/customer_list_state.dart';

class CustomerSearchBar extends StatefulWidget {
  const CustomerSearchBar({super.key});

  @override
  State<CustomerSearchBar> createState() => _CustomerSearchBarState();
}

class _CustomerSearchBarState extends State<CustomerSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerListCubit, CustomerListState>(
      builder: (context, state) {
        final selectedBranch = state is CustomerListLoaded ? state.selectedBranch : null;

        return Row(
          children: [
            // Search Input Field
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (val) => context.read<CustomerListCubit>().search(val),
                decoration: InputDecoration(
                  hintText: 'Search by Customer Name, National ID, or Phone...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _controller.clear();
                            context.read<CustomerListCubit>().search('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Branch Filter Dropdown / Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedBranch,
                  hint: const Text('All Branches', style: TextStyle(fontSize: 14)),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Branches')),
                    DropdownMenuItem(value: 'Nasr City', child: Text('Nasr City')),
                    DropdownMenuItem(value: 'Smoha', child: Text('Smoha')),
                    DropdownMenuItem(value: 'Maadi', child: Text('Maadi')),
                    DropdownMenuItem(value: 'Korba', child: Text('Korba')),
                    DropdownMenuItem(value: '5th Settlement', child: Text('5th Settlement')),
                  ],
                  onChanged: (val) {
                    context.read<CustomerListCubit>().filterByBranch(val);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
