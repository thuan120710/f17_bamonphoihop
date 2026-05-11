import { copyFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const sourceDir = join(__dirname, '../../f17_gameracing/html/sounds');
const targetDir = join(__dirname, '../public/sounds');

// Tạo thư mục nếu chưa có
if (!existsSync(targetDir)) {
  mkdirSync(targetDir, { recursive: true });
}

const soundFiles = ['5count.mp3', 'rightchose.mp3'];

console.log('📦 Copying sound files from gameracing...');

soundFiles.forEach(file => {
  const sourcePath = join(sourceDir, file);
  const targetPath = join(targetDir, file);
  
  if (existsSync(sourcePath)) {
    try {
      copyFileSync(sourcePath, targetPath);
      console.log(`✅ Copied: ${file}`);
    } catch (err) {
      console.error(`❌ Failed to copy ${file}:`, err.message);
    }
  } else {
    console.warn(`⚠️  Source file not found: ${file}`);
    console.warn(`   Expected at: ${sourcePath}`);
  }
});

console.log('✨ Sound files copy complete!');
