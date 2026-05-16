#!/usr/bin/env node
/**
 * Generates placeholder Teams app icons.
 * Run once: node scripts/generate-icons.mjs
 *
 * Replace the output files with Jack's final designs before App Store submission.
 * Requirements: color.png 192×192, outline.png 32×32
 */

import { writeFileSync } from 'fs';
import { deflateSync } from 'zlib';

// CRC32 lookup table
const CRC_TABLE = new Uint32Array(256);
for (let i = 0; i < 256; i++) {
  let c = i;
  for (let j = 0; j < 8; j++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  CRC_TABLE[i] = c;
}
function crc32(buf) {
  let crc = 0xffffffff;
  for (const b of buf) crc = CRC_TABLE[(crc ^ b) & 0xff] ^ (crc >>> 8);
  return ((crc ^ 0xffffffff) >>> 0);
}

function chunk(type, data) {
  const typeBytes = Buffer.from(type, 'ascii');
  const len = Buffer.allocUnsafe(4);
  len.writeUInt32BE(data.length);
  const crcInput = Buffer.concat([typeBytes, data]);
  const crcVal = Buffer.allocUnsafe(4);
  crcVal.writeUInt32BE(crc32(crcInput));
  return Buffer.concat([len, typeBytes, data, crcVal]);
}

function makePNG(width, height, r, g, b) {
  // PNG signature
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);

  // IHDR: width, height, 8-bit, RGB (2), deflate, adaptive, non-interlaced
  const ihdrData = Buffer.allocUnsafe(13);
  ihdrData.writeUInt32BE(width, 0);
  ihdrData.writeUInt32BE(height, 4);
  ihdrData[8] = 8;   // bit depth
  ihdrData[9] = 2;   // color type: RGB
  ihdrData[10] = 0;  // compression
  ihdrData[11] = 0;  // filter
  ihdrData[12] = 0;  // interlace

  // Raw image data: filter byte (0) + RGB per row
  const rowBytes = 1 + width * 3;
  const raw = Buffer.allocUnsafe(height * rowBytes);
  for (let y = 0; y < height; y++) {
    const offset = y * rowBytes;
    raw[offset] = 0; // filter: None
    for (let x = 0; x < width; x++) {
      raw[offset + 1 + x * 3] = r;
      raw[offset + 2 + x * 3] = g;
      raw[offset + 3 + x * 3] = b;
    }
  }

  const compressed = deflateSync(raw, { level: 6 });

  return Buffer.concat([
    sig,
    chunk('IHDR', ihdrData),
    chunk('IDAT', compressed),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

// Emerald #10b981 = R:16, G:185, B:129
const color = makePNG(192, 192, 16, 185, 129);
writeFileSync('teams-app/color.png', color);
console.log('✅ teams-app/color.png  (192×192, emerald placeholder)');

// Outline: white on transparent background — we use white on dark for contrast
const outline = makePNG(32, 32, 16, 185, 129);
writeFileSync('teams-app/outline.png', outline);
console.log('✅ teams-app/outline.png (32×32, emerald placeholder)');

console.log('\nReplace these with real designs before Teams App Store submission.');
console.log('Design spec: docs/teams-hr-agent/02-component-design.md §1.4');
