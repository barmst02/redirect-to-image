# redirect-to-image

# Image Service - S3 Image Delivery via Lambda

A serverless image delivery service that provides secure, authorized access to images stored in S3 through Lambda-generated presigned URLs with HTTP 302 redirects.

## 🎯 Overview

This service allows applications to retrieve images from S3 with a single HTTP call while maintaining access control and authorization. The Lambda function validates requests, generates short-lived presigned S3 URLs, and returns a 302 redirect, allowing the client to download directly from S3.

### Architecture
Client Request → Lambda Function URL → Authorization Check ↓ Generate Presigned URL ↓ 302 Redirect Response ↓ Client → S3 (Direct Download)


## ✨ Features

- **Single HTTP Call**: Client makes one request and receives the image
- **Secure Access**: Authorization logic before generating presigned URLs
- **Direct S3 Download**: After redirect, images download directly from S3 (fast & efficient)
- **No Size Limits**: Unlike Lambda direct serving, can handle images of any size
- **Cost Effective**: Minimal Lambda compute time (~5ms per request)
- **CORS Enabled**: Works with browser-based applications
- **Scalable**: Serverless architecture handles traffic spikes automatically
