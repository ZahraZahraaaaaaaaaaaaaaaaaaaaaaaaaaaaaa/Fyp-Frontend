const path = require('path');
const { spawn } = require('child_process');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

const apiBase =
  process.env.API_BASE_URL ||
  process.argv[2] ||
  'http://localhost:5000';

const args = [
  'build',
  'web',
  '--release',
  `--dart-define=API_BASE=${apiBase}`,
];

const child = spawn('flutter', args, {
  cwd: path.resolve(__dirname, '..'),
  stdio: 'inherit',
  shell: true,
});

child.on('exit', (code) => {
  process.exit(code ?? 0);
});
