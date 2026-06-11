// Generate .webp siblings for every .jpg in images/hero, images/mid, images/becs.
// Run with: node .claude/make-webp.js  (needs `sharp` resolvable — see CLAUDE.md)
const fs = require('fs');
const path = require('path');
const sharp = require(process.env.SHARP_PATH || 'sharp');

const root = path.join(__dirname, '..');
const dirs = ['images/hero', 'images/mid', 'images/becs'];

(async () => {
  let n = 0, saved = 0;
  for (const d of dirs) {
    const dir = path.join(root, d);
    for (const f of fs.readdirSync(dir)) {
      if (!/\.jpg$/i.test(f)) continue;
      const src = path.join(dir, f);
      const dst = src.replace(/\.jpg$/i, '.webp');
      await sharp(src).webp({ quality: 78 }).toFile(dst);
      saved += fs.statSync(src).size - fs.statSync(dst).size;
      n++;
    }
  }
  console.log(`${n} webp files, ${(saved / 1048576).toFixed(1)} MB saved vs jpg`);
})();
