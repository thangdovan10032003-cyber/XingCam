import 'recipe_service.dart';

/// CcdSensorSimulation — v1.7 Retro Digital Engine.
/// Mimics the behavior of early 2000s CCD sensors (PowerShot / Sony CyberShot).
class CcdSensorSimulation {
  
  static EditRecipe get recipe => EditRecipe(
    id: 'recipe_ccd_vibe_2005',
    name: 'CCD RETRO 2005',
    createdAt: DateTime.now(),
    steps: [
      const EditStep(
        toolId: 'exposure',
        params: {'gain': 0.15, 'clip_highlights': true}, // CCD highlight bloom
        label: 'CCD Bloom',
      ),
      const EditStep(
        toolId: 'saturation',
        params: {'vibrance': 1.25, 'cyan_boost': 1.1}, // Specific CCD blue tint
        label: 'Retro Saturation',
      ),
      const EditStep(
        toolId: 'noise_engine',
        params: {'type': 'digital_fixed_pattern', 'intensity': 0.05}, // CCD ISO noise
        label: 'Sensor Noise',
      ),
      const EditStep(
        toolId: 'white_balance',
        params: {'tint': -0.05, 'temp': 5200}, // Slightly cooler/magenta shift
        label: 'Early WB',
      ),
    ],
  );
}
