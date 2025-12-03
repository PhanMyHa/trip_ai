const { spawn } = require('child_process');
const path = require('path');

console.log('Testing Python spawn...\n');

const pythonScript = path.join(__dirname, 'ai_predict.py');
console.log('Script path:', pythonScript);

const pythonProcess = spawn('python', [
  pythonScript,
  'Đà Nẵng',
  '3',
  '{"budgetRange":"Trung bình","interests":["beach"],"people":2}'
]);

let stdout = '';
let stderr = '';

pythonProcess.stdout.on('data', (data) => {
  stdout += data.toString();
  console.log('[STDOUT]:', data.toString());
});

pythonProcess.stderr.on('data', (data) => {
  stderr += data.toString();
  console.log('[STDERR]:', data.toString());
});

pythonProcess.on('error', (error) => {
  console.error('[ERROR] Failed to start:', error.message);
});

pythonProcess.on('close', (code) => {
  console.log('\n[CLOSE] Exit code:', code);
  console.log('\nFull stdout length:', stdout.length);
  console.log('Full stderr length:', stderr.length);
});
