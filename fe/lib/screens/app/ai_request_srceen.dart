import 'package:fe/theme/app_theme.dart';
import 'package:fe/widgets/common_widget.dart';
import 'package:flutter/material.dart';



class AIRequestScreen extends StatefulWidget {
  const AIRequestScreen({super.key});

  @override
  State<AIRequestScreen> createState() => _AIRequestScreenState();
}

class _AIRequestScreenState extends State<AIRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _destination = '';
  String _travelDates = '3 Ngày 2 Đêm';
  String _travelers = '2 Người';
  String _budget = 'Trung bình (3M - 10M)';
  String _notes = '';

  final List<String> datesOptions = ['2 Ngày 1 Đêm', '3 Ngày 2 Đêm', '4 Ngày 3 Đêm', 'Tùy chọn'];
  final List<String> travelersOptions = ['1 Người', '2 Người', '3-5 Người', 'Gia đình'];
  final List<String> budgetOptions = ['Thấp (< 3M)', 'Trung bình (3M - 10M)', 'Cao (> 10M)'];

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Giả lập logic gửi yêu cầu và chuyển sang màn hình kết quả
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryBlue),
              SizedBox(height: 15),
              Text('AI đang lập kế hoạch chuyến đi hoàn hảo cho bạn...',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

      // Delay 3 giây để mô phỏng thời gian AI xử lý
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context); // Đóng dialog
        Navigator.pushNamed(context, '/ai_result');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu Cầu Lập Lịch Trình AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAIHeader(),
              const SizedBox(height: 30),
              _buildLocationInput(),
              const SizedBox(height: 20),
              _buildDropdowns(),
              const SizedBox(height: 20),
              _buildNotesInput(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: AIActionButton(
                  text: 'Tạo Lịch Trình (AI)',
                  onPressed: _submitRequest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIHeader() {
    return GradientCard(
      gradientColors: const [AppColors.secondaryOrange, AppColors.primaryBlue],
      radius: 20,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology, size: 40, color: AppColors.textLight),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lập Kế Hoạch Cá Nhân Hóa',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight),
                ),
                SizedBox(height: 4),
                Text(
                  'AI sẽ dựa trên hồ sơ và yêu cầu của bạn để tạo ra lịch trình độc đáo.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Địa điểm bạn muốn đến (VD: Đà Lạt, Phú Quốc)',
        prefixIcon: Icon(Icons.travel_explore_rounded),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập địa điểm.';
        }
        return null;
      },
      onSaved: (value) => _destination = value!,
      initialValue: 'Đà Lạt',
    );
  }

  Widget _buildDropdowns() {
  return Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: _travelDates,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            labelText: 'Thời gian đi',
            prefixIcon: Icon(Icons.date_range_rounded, size: 18),
          ),
          items: datesOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => _travelDates = value!),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          value: _travelers,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            labelText: 'Số người',
            prefixIcon: Icon(Icons.group_rounded, size: 18),
          ),
          items: travelersOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => setState(() => _travelers = value!),
        ),
      ),
    ],
  );
}


  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _budget,
          decoration: const InputDecoration(
            labelText: 'Ngân sách',
            prefixIcon: Icon(Icons.paid_rounded),
          ),
          items: budgetOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _budget = value!;
            });
          },
          onSaved: (value) => _budget = value!,
        ),
        const SizedBox(height: 20),
        TextFormField(
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Ghi chú/Sở thích đặc biệt (VD: Thích cắm trại, Không thích hải sản)',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.description_rounded),
          ),
          onSaved: (value) => _notes = value!,
        ),
      ],
    );
  }
}