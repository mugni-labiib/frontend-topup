import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TopUpFormPage extends StatefulWidget {
  const TopUpFormPage({super.key});

  @override
  State<TopUpFormPage> createState() => _TopUpFormPageState();
}

class _TopUpFormPageState extends State<TopUpFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _gameIdController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  List<dynamic> games = [];
  int? selectedGameId;
  String selectedGameName = 'Pilih Game';
  
  List<dynamic> denominations = [];
  Map<String, dynamic>? selectedDenomination;
  
  bool isLoading = false;
  bool isDenominationLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _gameIdController.dispose();
    super.dispose();
  }
  Future<void> _loadGames() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _apiService.getGames();
      print('Games Response: $response');
      
      if (response['status'] == 200 || response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          setState(() {
            games = data;
            isLoading = false;
          });
        } else {
          setState(() {
            games = [];
            isLoading = false;
          });
          print('Data bukan List: $data');
        }
      } else {
        setState(() {
          games = [];
          isLoading = false;
        });
        _showSnackbar('Gagal memuat game', Colors.red);
      }
    } catch (e) {
      print('Error loading games: $e');
      setState(() {
        games = [];
        isLoading = false;
      });
      _showSnackbar('Error: $e', Colors.red);
    }
  }
  Future<void> _loadDenominations(int gameId) async {
    setState(() {
      isDenominationLoading = true;
      denominations = [];
      selectedDenomination = null;
    });

    try {
      final response = await _apiService.getDenominations(gameId);
      print('Denominasi Response: $response');
      
      if (response['status'] == 200 || response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          final filteredData = data.where((item) {
            final itemGameId = item['game_id'] ?? item['game']?['id'];
            return itemGameId == gameId;
          }).toList();
          
          print('Filtered Denominations: $filteredData');
          
          setState(() {
            denominations = filteredData;
            isDenominationLoading = false;
          });
        } else {
          setState(() {
            denominations = [];
            isDenominationLoading = false;
          });
        }
      } else {
        setState(() {
          denominations = [];
          isDenominationLoading = false;
        });
        _showSnackbar('Gagal memuat denominasi', Colors.red);
      }
    } catch (e) {
      print('Error loading denominations: $e');
      setState(() {
        denominations = [];
        isDenominationLoading = false;
      });
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  void _handleTopUp() {
    if (selectedGameId == null) {
      _showSnackbar('Silakan pilih game terlebih dahulu', Colors.orange);
      return;
    }

    if (selectedDenomination == null) {
      _showSnackbar('Silakan pilih nominal diamond', Colors.orange);
      return;
    }

    if (_gameIdController.text.isEmpty) {
      _showSnackbar('Silakan masukkan ID Game', Colors.orange);
      return;
    }

    final denomGameId = selectedDenomination!['game_id'] ?? 
                         selectedDenomination!['game']?['id'];
    
    if (denomGameId != selectedGameId) {
      _showSnackbar('Denominasi tidak sesuai dengan game yang dipilih!', Colors.red);
      print('ERROR: Game ID $selectedGameId vs Denomination Game ID $denomGameId');
      return;
    }

    final data = {
      'game_id': selectedGameId!,
      'game_user_id': _gameIdController.text,
      'denomination_id': selectedDenomination!['id'],
      'game_name': selectedGameName,
      'diamond_amount': selectedDenomination!['diamond_amount']?.toString() ?? '0',
      'price': selectedDenomination!['price']?.toString() ?? '0',
    };

    print('=== DATA TOPUP ===');
    print('Data: $data');

    Navigator.pushNamed(
      context,
      '/payment',
      arguments: data,
    );
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up / Detail Game'),
        backgroundColor: const Color(0xFF0F172A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white12,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.gamepad,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedGameName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            const Text(
                              '1. Pilih Game',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: selectedGameId,
                                    hint: const Text(
                                      'Pilih Game',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    dropdownColor: const Color(0xFF1E293B),
                                    style: const TextStyle(color: Colors.white),
                                    isExpanded: true,
                                    items: games.map((game) {
                                      return DropdownMenuItem<int>(
                                        value: game['id'],
                                        child: Text(
                                          game['game_name'] ?? 'Unknown',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedGameId = value;
                                          final foundGame = games.firstWhere(
                                            (g) => g['id'] == value,
                                            orElse: () => {'game_name': 'Unknown'},
                                          );
                                          selectedGameName = foundGame['game_name'] ?? 'Unknown';
                                          selectedDenomination = null;
                                        });
                                        _loadDenominations(value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 14),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),

                            const Text(
                              '2. Masukkan ID Game',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _gameIdController,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan ID Game kamu',
                                filled: true,
                                fillColor: Color(0xFF1E293B),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Wajib diisi' : null,
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: Colors.white12),
                            const SizedBox(height: 8),

                            // ========== 3. PILIH NOMINAL ==========
                            const Text(
                              '3. Pilih Nominal Diamond',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            
                            if (selectedGameId == null)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Silakan pilih game terlebih dahulu',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            else if (isDenominationLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (denominations.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Tidak ada nominal untuk game ini',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 3 / 4,
                                ),
                                itemCount: denominations.length,
                                itemBuilder: (context, index) {
                                  final denom = denominations[index];
                                  final isSelected = selectedDenomination?['id'] == denom['id'];
                                  
                                  final diamondAmount = denom['diamond_amount']?.toString() ?? '0';
                                  final price = denom['price']?.toString() ?? '0';

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedDenomination = denom;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF7C3AED).withOpacity(0.15)
                                            : const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF7C3AED)
                                              : Colors.white12,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.diamond,
                                            color: Color(0xFF7C3AED),
                                            size: 36,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$diamondAmount 💎',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Rp ${_formatPrice(price)}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? const Color(0xFF7C3AED)
                                                  : Colors.white70,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),
            Container(
              width: 360,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'RINGKASAN ORDER',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.gamepad,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedGameName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  _summaryRow(
                    'ID Game',
                    _gameIdController.text.isEmpty ? '-' : _gameIdController.text,
                  ),
                  _summaryRow(
                    'Nominal',
                    selectedDenomination != null 
                      ? '${selectedDenomination!['diamond_amount']} Diamond'
                      : '-',
                  ),
                  _summaryRow(
                    'Harga',
                    selectedDenomination != null 
                      ? 'Rp ${_formatPrice(selectedDenomination!['price'].toString())}'
                      : '-',
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selectedDenomination != null 
                      ? 'Rp ${_formatPrice(selectedDenomination!['price'].toString())}'
                      : 'Rp 0',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleTopUp,
                    child: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  String _formatPrice(String price) {
    try {
      final number = double.tryParse(price) ?? 0;
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
    } catch (e) {
      return price;
    }
  }
}

Widget _summaryRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}