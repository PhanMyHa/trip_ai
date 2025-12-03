const { spawn } = require('child_process');
const path = require('path');

/**
 * AI Controller for Travel Itinerary Recommendations
 */

// Generate AI-powered itinerary recommendations
exports.generateItinerary = async (req, res) => {
  try {
    const { destination, startDate, endDate, travelers, budget, interests } = req.body;

    // Validate required fields
    if (!destination || !startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Destination, start date, and end date are required'
      });
    }

    // Calculate number of days
    const start = new Date(startDate);
    const end = new Date(endDate);
    const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1;

    if (days < 1 || days > 30) {
      return res.status(400).json({
        success: false,
        message: 'Trip duration must be between 1 and 30 days'
      });
    }

    // Prepare user profile for AI
    const userProfile = {
      budgetRange: budget || 'Trung bình',
      interests: interests || [],
      people: travelers || 2
    };

    // Call Python AI model
    const pythonScript = path.join(__dirname, '../ai_predict.py');
    
    console.log('🚀 Starting AI prediction...');
    console.log('📍 Destination:', destination);
    console.log('📅 Days:', days);
    console.log('👥 User profile:', JSON.stringify(userProfile));
    console.log('🐍 Python script:', pythonScript);

    const pythonProcess = spawn('python', [
      pythonScript,
      destination,
      days.toString(),
      JSON.stringify(userProfile)
    ]);

    let outputData = '';
    let errorData = '';

    pythonProcess.stdout.on('data', (data) => {
      outputData += data.toString();
    });

    pythonProcess.stderr.on('data', (data) => {
      errorData += data.toString();
    });

    pythonProcess.on('error', (error) => {
      console.error('❌ Failed to start Python process:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to start AI process',
        error: error.message
      });
    });

    pythonProcess.on('close', (code) => {
      console.log('🐍 Python process closed with code:', code);
      console.log('📤 Python stdout:', outputData.substring(0, 500));
      console.log('📛 Python stderr:', errorData.substring(0, 500));

      if (code !== 0) {
        console.error('❌ Python script failed with code:', code);
        console.error('Full stderr:', errorData);
        console.error('Full stdout:', outputData);
        return res.status(500).json({
          success: false,
          message: 'Failed to generate itinerary',
          error: errorData || 'Python script exited with non-zero code',
          stdout: outputData.substring(0, 200),
          exitCode: code
        });
      }

      try {
        // Parse Python output - extract JSON from last line
        const lines = outputData.trim().split('\n');
        const jsonLine = lines[lines.length - 1];
        
        console.log('📋 Parsing JSON line:', jsonLine.substring(0, 100));
        const result = JSON.parse(jsonLine);

        if (!result.itinerary || !Array.isArray(result.itinerary)) {
          throw new Error('Invalid itinerary format from AI model');
        }

        console.log('✅ AI generated', result.itinerary.length, 'days itinerary');

        res.json({
          success: true,
          data: {
            destination,
            startDate,
            endDate,
            travelers,
            budget,
            days,
            dailySchedule: result.itinerary,
            totalEstimatedCost: result.totalCost,
            generatedAt: new Date().toISOString()
          }
        });
      } catch (parseError) {
        console.error('❌ Failed to parse Python output:', parseError.message);
        console.error('Output data:', outputData);
        res.status(500).json({
          success: false,
          message: 'Failed to parse AI recommendations',
          error: parseError.message,
          rawOutput: outputData.substring(0, 500)
        });
      }
    });

  } catch (error) {
    console.error('AI Controller Error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message
    });
  }
};

// Get AI model info
exports.getModelInfo = async (req, res) => {
  try {
    res.json({
      success: true,
      data: {
        modelVersion: '1.0.0',
        modelType: 'Content-Based Filtering + TF-IDF',
        features: [
          'Personalized recommendations based on budget',
          'Interest matching with services',
          'Location-based filtering',
          'Rating optimization',
          'Category diversity',
          'Daily themed itineraries'
        ],
        lastTrained: new Date().toISOString(),
        totalServices: 1000,
        supportedDestinations: [
          'Đà Nẵng', 'Nha Trang', 'Hội An', 'Phú Quốc', 'Đà Lạt',
          'Hà Nội', 'Sài Gòn', 'Quy Nhơn', 'Huế', 'Vũng Tàu'
        ]
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to get model info',
      error: error.message
    });
  }
};
