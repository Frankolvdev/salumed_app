import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EbooksView extends StatefulWidget {
  const EbooksView({Key? key}) : super(key: key);

  @override
  State<EbooksView> createState() => _EbooksViewState();
}

class _EbooksViewState extends State<EbooksView> {
  String? _currentEbook;

  final List<Map<String, String>> ebooks = [
    {
      'name': 'Aditivos Codificados…',
      'url': 'https://www.amazon.com.mx/dp/B0FQYZQLGZ?ref=cm_sw_r_cso_wa_apan_dp_946425KTVHEWM9X79HE7&ref_=cm_sw_r_cso_wa_apan_dp_946425KTVHEWM9X79HE7&social_share=cm_sw_r_cso_wa_apan_dp_946425KTVHEWM9X79HE7'
    },
    {
      'name': 'La realidad de los alimentos saludables',
      'url': 'https://www.amazon.com.mx/dp/B0FQYJW9BM?ref=cm_sw_r_cso_wa_apan_dp_65PA7H34PMZN7681CPW1&ref_=cm_sw_r_cso_wa_apan_dp_65PA7H34PMZN7681CPW1&social_share=cm_sw_r_cso_wa_apan_dp_65PA7H34PMZN7681CPW1'
    },
     {
      'name': 'La serenidad en el caos',
      'url': 'https://www.amazon.com.mx/dp/B0G2XT48DB?ref=cm_sw_r_cso_wa_apan_dp_ZA4Q3ZRNQ727ZMRXW7E1&ref_=cm_sw_r_cso_wa_apan_dp_ZA4Q3ZRNQ727ZMRXW7E1&social_share=cm_sw_r_cso_wa_apan_dp_ZA4Q3ZRNQ727ZMRXW7E1'
    }



    
  ];

  Future<void> _openEbook(String url, String name) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el eBook.')),
      );
      return;
    }
    setState(() {
      _currentEbook = name;
    });
    _saveOpenedEbook(name);
  }

  Future<void> _saveOpenedEbook(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await prefs.setString('last_ebook', name);
    await prefs.setString('last_ebook_time', now);
    print('Guardado: $name a las $now');
  }

  Widget _buildEbookItem(Map<String, String> ebook) {
    final isSelected = ebook['name'] == _currentEbook;
    return GestureDetector(
      onTap: () => _openEbook(ebook['url']!, ebook['name']!),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.purple, Colors.deepPurple])
              : LinearGradient(colors: [Colors.grey.shade200, Colors.grey.shade100]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.book, size: 40, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                ebook['name']!,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.open_in_new, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('eBooks'),
        backgroundColor: Colors.teal
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ebooks.length,
              itemBuilder: (_, index) => _buildEbookItem(ebooks[index]),
            ),
          ),
          if (_currentEbook != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple.shade50,
              child: Center(
                child: Text(
                  'Abriendo: $_currentEbook',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
