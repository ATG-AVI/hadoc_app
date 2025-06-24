# ECG Analysis Models Integration

This directory contains the machine learning models that have been integrated into the Flutter medical analysis app. The models are implemented in the `ECGAnalysisService` class which provides comprehensive ECG analysis capabilities.

## Available Models

### 1. 1D CNN ECG Signal Classification
- **File**: `1D CNN ECG Signal Classification.txt`
- **Purpose**: Analyzes raw ECG signal data (186 data points)
- **Architecture**: Conv1D layers with BatchNormalization and MaxPooling
- **Output**: 5 cardiac condition classifications
- **Usage**: For processing raw ECG time series data

### 2. 2D CNN ECG Image Classification (MIT-BIH Dataset)
- **File**: `2D CNN ECG Image Classification MIT-BIH.txt`
- **Purpose**: Analyzes ECG images (PNG format)
- **Architecture**: Conv2D layers with MaxPooling and Dense layers
- **Input**: 100x100 pixel ECG images
- **Output**: 6 cardiac condition classifications
- **Usage**: For processing ECG chart images

### 3. 2D CNN ECG Image Classification (Own Dataset)
- **File**: `2D CNN ECG Image Classification own dataset.txt`
- **Purpose**: Custom dataset ECG image analysis
- **Architecture**: Similar to MIT-BIH model but optimized for custom data
- **Usage**: Enhanced analysis for specific ECG image formats

### 4. Multimodal Fusion on Houses Dataset
- **File**: `Multimodal Fusion on Houses Dataset.txt`
- **Purpose**: Template for combining multiple data types (adapted for medical data)
- **Architecture**: MLP + CNN fusion with concatenation
- **Usage**: Combines patient demographics with ECG data

### 5. Tensor Fusion Network
- **File**: `tensor fusion.txt`
- **Purpose**: Advanced multimodal fusion using tensor operations
- **Architecture**: Element-wise multiplication after bias addition: `(MLP_output + 1) * (CNN_output + 1)`
- **Usage**: Advanced feature fusion for comprehensive analysis

### 6. Operation-Based Fusion
- **File**: `operation based fusion.txt`
- **Purpose**: Multiple fusion strategies ensemble
- **Methods**: Addition, Concatenation, and Attention-based fusion
- **Usage**: Ensemble approach for robust predictions

## Implementation in Flutter App

The models are integrated through the `ECGAnalysisService` class which provides:

### Core Analysis Methods

```dart
// 1D CNN for signal data
static Future<Map<String, dynamic>> analyze1DCNN(Uint8List data)

// 2D CNN for image data
static Future<Map<String, dynamic>> analyze2DCNN(PlatformFile file)

// Multimodal fusion
static Future<Map<String, dynamic>> analyzeMultimodal({
  required PlatformFile file,
  Map<String, dynamic>? patientData,
})

// Tensor fusion
static Future<Map<String, dynamic>> analyzeTensorFusion({
  required PlatformFile file,
  Map<String, dynamic>? patientData,
})

// Operation-based fusion
static Future<Map<String, dynamic>> analyzeOperationFusion({
  required PlatformFile file,
  Map<String, dynamic>? patientData,
})

// Comprehensive analysis using all models
static Future<AnalysisResult> performComprehensiveAnalysis({
  required PlatformFile file,
  required String userId,
  Map<String, dynamic>? patientData,
})
```

### Detected Conditions

The system can identify the following ECG conditions:

- Normal Beat (N)
- Supraventricular Premature Beat (S)
- Premature Ventricular Contraction (V)
- Fusion of Ventricular Beat (F)
- Unknown Beat (Q)
- Left Bundle Branch Block (L)
- Right Bundle Branch Block (R)
- Atrial Premature Beat (A)

### Risk Assessment

The system provides risk levels based on confidence scores:

- **Low Risk**: ≥90% confidence
- **Moderate Risk**: 75-89% confidence
- **High Risk**: 60-74% confidence
- **Critical**: <60% confidence

### Features Extracted

#### For Signal Analysis (1D CNN):
- Heart rate (BPM)
- QRS duration
- PR interval
- QT interval
- Signal quality score

#### For Image Analysis (2D CNN):
- Image quality assessment
- Noise level detection
- Contrast evaluation
- Lead detection count
- Resolution metrics

## Integration with Supabase

The analysis results are automatically stored in the Supabase database with:

- Analysis ID and timestamps
- User association
- File information
- Detailed results from all models
- Confidence scores and risk assessments
- Medical recommendations

## Usage in the App

1. **File Upload**: Users upload ECG files (PNG, JPG, PDF)
2. **Model Selection**: Based on file type, appropriate models are selected
3. **Analysis Pipeline**: All relevant models process the data
4. **Fusion**: Results are combined using advanced fusion techniques
5. **Report Generation**: Comprehensive medical report is generated
6. **Storage**: Results are stored in Supabase for future reference

## Medical Disclaimer

⚠️ **Important**: These models are for educational and research purposes only. They are not intended for clinical diagnosis or treatment decisions. Always consult qualified medical professionals for accurate ECG interpretation and medical advice.

## Future Enhancements

- Real-time ECG monitoring
- Additional cardiac condition classifications
- Integration with wearable devices
- Advanced visualization of results
- Clinical validation studies 