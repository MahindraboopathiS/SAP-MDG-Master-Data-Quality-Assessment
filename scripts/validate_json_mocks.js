const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');

console.log('Starting validation of JSON mock datasets in:', dataDir);

if (!fs.existsSync(dataDir)) {
  console.error('Error: Data directory does not exist!');
  process.exit(1);
}

const files = fs.readdirSync(dataDir).filter(file => file.endsWith('.json'));

if (files.length === 0) {
  console.error('Error: No JSON mock files found in data/ directory!');
  process.exit(1);
}

let hasError = false;

files.forEach(file => {
  const filePath = path.join(dataDir, file);
  try {
    const rawContent = fs.readFileSync(filePath, 'utf8');
    const parsed = JSON.parse(rawContent);
    
    if (!Array.isArray(parsed)) {
      console.error(`[FAIL] ${file}: Root JSON element must be an Array.`);
      hasError = true;
    } else {
      console.log(`[PASS] ${file}: Valid JSON Array with ${parsed.length} record(s).`);
    }
  } catch (err) {
    console.error(`[FAIL] ${file}: Invalid JSON syntax - ${err.message}`);
    hasError = true;
  }
});

if (hasError) {
  console.error('\nJSON Validation Failed!');
  process.exit(1);
} else {
  console.log('\nAll JSON mock datasets validated successfully!');
}
