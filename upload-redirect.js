#!/usr/bin/env node

import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load .env file
const env = {};
try {
  const envContent = readFileSync('.env', 'utf-8');
  envContent.split('\n').forEach(line => {
    const match = line.match(/^\s*([^#][^=]*)\s*=\s*(.*)\s*$/);
    if (match) {
      env[match[1].trim()] = match[2].trim();
    }
  });
} catch (e) {
  console.error('❌ Could not read .env file');
  process.exit(1);
}

const PINATA_JWT = env.PINATA_JWT || env.OMNIPIN_PINATA_TOKEN;
if (!PINATA_JWT) {
  console.error('❌ Missing PINATA_JWT in .env');
  process.exit(1);
}

const redirectFile = join(__dirname, 'redirect.html');
const fileContent = readFileSync(redirectFile);

(async () => {
  try {
    console.log('📤 Uploading redirect.html to Pinata...\n');

    const formData = new FormData();
    const blob = new Blob([fileContent], { type: 'text/html' });
    formData.append('file', blob, 'redirect.html');
    formData.append('pinataMetadata', JSON.stringify({
      name: 'ionoi-eth-sucks-redirect'
    }));
    formData.append('pinataOptions', JSON.stringify({
      cidVersion: 1
    }));

    const response = await fetch('https://api.pinata.cloud/pinning/pinFileToIPFS', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PINATA_JWT}`
      },
      body: formData
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Pinata upload failed: ${response.status} ${error}`);
    }

    const result = await response.json();
    const cid = result.IpfsHash;

    console.log('✅ Upload successful!\n');
    console.log(`📦 CID: ${cid}`);
    console.log(`🔗 IPFS Gateway: https://ipfs.io/ipfs/${cid}`);
    console.log(`\n📝 Set your ENS Content Hash to: /ipfs/${cid}`);
    console.log(`   (Go to app.ens.domains → ionoi.eth.sucks → Records → Other → Content Hash)`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();

