class DummyPatientReport {
  final String patientName;
  final String date;
  final String diagnosis;
  final String ecgImageUrl;

  DummyPatientReport({
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.ecgImageUrl,
  });
}

final List<DummyPatientReport> dummyReports = [
  DummyPatientReport(
    patientName: 'John Doe',
    date: '2024-03-20',
    diagnosis: 'Normal Sinus Rhythm',
    ecgImageUrl: 'assets/images/ecg1.png',
  ),
  DummyPatientReport(
    patientName: 'Jane Smith',
    date: '2024-03-19',
    diagnosis: 'Bradycardia',
    ecgImageUrl: 'assets/images/ecg2.png',
  ),
  DummyPatientReport(
    patientName: 'Mike Johnson',
    date: '2024-03-18',
    diagnosis: 'Tachycardia',
    ecgImageUrl: 'assets/images/ecg3.png',
  ),
]; 