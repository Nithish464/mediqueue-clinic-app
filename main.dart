import 'package:flutter/material.dart';

void main() => runApp(const MediQueueApp());

const navy = Color(0xFF12223A);
const teal = Color(0xFF20BFA9);
const canvas = Color(0xFFF4F7FB);
const grey = Color(0xFF78869A);

class MediQueueApp extends StatelessWidget {
  const MediQueueApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MediQueue', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: teal),
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: navy)),
    home: const ClinicHome(),
  );
}
class Appointment {
  Appointment(this.name, this.doctor, this.time, this.kind, this.status);
  final String name, doctor, time, kind;
  final String status;
}
class ClinicHome extends StatefulWidget {
  const ClinicHome({super.key});
  @override
  State<ClinicHome> createState() => _ClinicHomeState();
}
class _ClinicHomeState extends State<ClinicHome> {
  final appointments = <Appointment>[
    Appointment('Aarav Sharma', 'Dr. Meera Iyer', '09:30 AM', 'General', 'Confirmed'),
    Appointment('Diya Patel', 'Dr. Karthik Rao', '10:15 AM', 'Dental', 'Waiting'),
    Appointment('Ishaan Kumar', 'Dr. Meera Iyer', '11:00 AM', 'General', 'Confirmed'),
  ];
  final patientController = TextEditingController();
  String specialty = 'General';
  final doctors = const ['Dr. Meera Iyer', 'Dr. Karthik Rao', 'Dr. Ananya Bose'];
  String doctor = 'Dr. Meera Iyer';
  String time = '12:00 PM';
  Future<void> book() async {
    patientController.clear();
    final key = GlobalKey<FormState>();
    String localSpecialty = specialty, localDoctor = doctor, localTime = time;
    final result = await showDialog<Appointment>(context: context, builder: (ctx) =>
      StatefulBuilder(builder: (ctx, setDialog) => AlertDialog(
        title: const Text('Book an appointment'),
        content: Form(key: key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(controller: patientController, decoration: const InputDecoration(labelText: 'Patient name'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Enter patient name' : null),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(value: localSpecialty, decoration: const InputDecoration(labelText: 'Specialty'),
            items: const ['General','Dental','Cardiology','Dermatology'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) { if (v != null) setDialog(() => localSpecialty = v); }),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(value: localDoctor, decoration: const InputDecoration(labelText: 'Doctor'),
            items: doctors.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) { if (v != null) setDialog(() => localDoctor = v); }),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(value: localTime, decoration: const InputDecoration(labelText: 'Time slot'),
            items: const ['12:00 PM','12:30 PM','01:00 PM','02:00 PM','03:00 PM'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) { if (v != null) setDialog(() => localTime = v); }),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { if (!key.currentState!.validate()) return;
            Navigator.pop(ctx, Appointment(patientController.text.trim(), localDoctor, localTime, localSpecialty, 'Confirmed')); },
            child: const Text('Confirm booking')),
        ],
      )));
    if (result != null && mounted) {
      setState(() { specialty = result.kind; doctor = result.doctor; time = result.time; appointments.insert(0, result); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment added')));
    }
  }
  @override
  void dispose() { patientController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children: [
      Icon(Icons.health_and_safety_rounded, color: teal, size: 28), SizedBox(width: 8),
      Text('MediQueue', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -.5)),
    ]), actions: [IconButton(onPressed: book, icon: const Icon(Icons.add_circle_outline)), const SizedBox(width: 8)]),
    floatingActionButton: FloatingActionButton.extended(onPressed: book, backgroundColor: teal, foregroundColor: Colors.white,
      icon: const Icon(Icons.calendar_month_rounded), label: const Text('Book visit')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 8, 18, 100), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [navy, Color(0xFF254B68)]), borderRadius: BorderRadius.circular(25)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('YOUR HEALTH, MADE SIMPLE', style: TextStyle(color: Color(0xFF8DEBDD), fontSize: 10, letterSpacing: 1.8, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10), const Text('Care that fits your day.', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8), const Text('Book appointments and keep your visits organized.', style: TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 18), Row(children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF8DEBDD), size: 17), const SizedBox(width: 7),
            Text('${appointments.length} appointments in your schedule', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ])),
      const SizedBox(height: 22),
      const Text('Quick overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: navy)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _InfoCard(icon: Icons.calendar_today_rounded, label: 'Appointments', value: '${appointments.length}', tint: teal)),
        const SizedBox(width: 10),
        Expanded(child: _InfoCard(icon: Icons.check_circle_outline_rounded, label: 'Confirmed', value: '${appointments.where((a) => a.status == 'Confirmed').length}', tint: const Color(0xFF5979E8))),
      ]),
      const SizedBox(height: 25),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Today’s schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: navy)),
        Text('${appointments.length} visits', style: const TextStyle(color: grey, fontSize: 12)),
      ]),
      const SizedBox(height: 12),
      ...appointments.map((a) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6ECF3))),
        child: Row(children: [
          Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFE8F8F5), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.person_rounded, color: teal)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.name, style: const TextStyle(color: navy, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4), Text('${a.doctor} · ${a.kind}', style: const TextStyle(color: grey, fontSize: 11)),
            const SizedBox(height: 6), Row(children: [
              const Icon(Icons.schedule_rounded, size: 13, color: teal), const SizedBox(width: 4),
              Text(a.time, style: const TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: a.status == 'Confirmed' ? const Color(0xFFE5F8F1) : const Color(0xFFFFF4DE), borderRadius: BorderRadius.circular(7)),
            child: Text(a.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
              color: a.status == 'Confirmed' ? const Color(0xFF168866) : const Color(0xFFB47B18)))),
        ]))),
      const SizedBox(height: 12),
      const Text('Demo app only · No real appointments are submitted.', textAlign: TextAlign.center, style: TextStyle(color: grey, fontSize: 10)),
    ])),
  );
}
class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value, required this.tint});
  final IconData icon; final String label, value; final Color tint;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6ECF3))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: tint, size: 20), const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 24, color: navy, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3), Text(label, style: const TextStyle(color: grey, fontSize: 11)),
    ]));
}

