// Webhook Handler for Apollo Blog Content Updates
// This script can be deployed to handle webhooks from external content repositories

const express = require('express');
const crypto = require('crypto');
const { Octokit } = require("@octokit/rest");

const app = express();
const PORT = process.env.PORT || 3000;

// Configuration
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET;
const BLOG_REPO_OWNER = process.env.BLOG_REPO_OWNER;
const BLOG_REPO_NAME = process.env.BLOG_REPO_NAME;

const octokit = new Octokit({
  auth: GITHUB_TOKEN,
});

app.use(express.json());

// Verify webhook signature
function verifySignature(req, res, next) {
  const signature = req.headers['x-hub-signature-256'];
  const body = JSON.stringify(req.body);
  const hash = crypto.createHmac('sha256', WEBHOOK_SECRET).update(body).digest('hex');
  const expectedSignature = `sha256=${hash}`;

  if (signature !== expectedSignature) {
    return res.status(401).send('Unauthorized');
  }

  next();
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Apollo Blog Webhook Handler' });
});

// Webhook endpoint
app.post('/webhook/content-update', verifySignature, async (req, res) => {
  try {
    const { action, repository, ref } = req.body;
    
    // Only process push events to main/master branch
    if (req.body.ref && (req.body.ref === 'refs/heads/main' || req.body.ref === 'refs/heads/master')) {
      console.log(`🔄 Content update received from ${repository.full_name}`);
      
      // Trigger rebuild of blog
      await octokit.repos.createDispatchEvent({
        owner: BLOG_REPO_OWNER,
        repo: BLOG_REPO_NAME,
        event_type: 'content-update',
        client_payload: {
          source: 'external-content',
          repository: repository.full_name,
          timestamp: new Date().toISOString()
        }
      });
      
      console.log(`✅ Triggered rebuild for ${BLOG_REPO_OWNER}/${BLOG_REPO_NAME}`);
      res.json({ status: 'success', message: 'Rebuild triggered' });
    } else {
      console.log('ℹ️  Ignoring webhook - not a main/master branch push');
      res.json({ status: 'ignored', message: 'Not a main/master branch push' });
    }
  } catch (error) {
    console.error('❌ Error handling webhook:', error);
    res.status(500).json({ status: 'error', message: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Apollo Blog Webhook Handler running on port ${PORT}`);
  console.log(`📝 Blog repo: ${BLOG_REPO_OWNER}/${BLOG_REPO_NAME}`);
});

module.exports = app; 