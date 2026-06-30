# lambda_function.py
import boto3
import json
import os
from urllib.parse import unquote

s3_client = boto3.client('s3')

BUCKET_NAME = os.environ['S3_BUCKET_NAME']
PRESIGNED_URL_TTL = int(os.environ.get('PRESIGNED_URL_TTL', '900'))
ALLOWED_ORIGINS = os.environ.get('ALLOWED_ORIGINS', '*').split(',')

def lambda_handler(event, context):
    """
    Lambda function that generates presigned S3 URLs and returns HTTP 302 redirect
    
    Expected path format: /images/{image_key}
    Or raw path: /{image_key}
    """
    
    print(f"Event: {json.dumps(event)}")
    
    # Extract image key from path
    raw_path = event.get('rawPath', '')
    
    # Remove leading slash and 'images/' prefix if present
    image_key = raw_path.lstrip('/')
    if image_key.startswith('images/'):
        image_key = image_key[7:]  # Remove 'images/' prefix
    
    # URL decode the key
    image_key = unquote(image_key)
    
    if not image_key:
        return {
            'statusCode': 400,
            'headers': get_cors_headers(),
            'body': json.dumps({'error': 'No image key provided'})
        }
    
    # Optional: Add your authorization logic here
    # auth_header = event.get('headers', {}).get('authorization')
    # if not is_authorized(auth_header, image_key):
    #     return {
    #         'statusCode': 403,
    #         'headers': get_cors_headers(),
    #         'body': json.dumps({'error': 'Forbidden'})
    #     }
    
    try:
        # Check if object exists
        s3_client.head_object(Bucket=BUCKET_NAME, Key=image_key)
        
        # Generate presigned URL
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={
                'Bucket': BUCKET_NAME,
                'Key': image_key,
                'ResponseCacheControl': 'public, max-age=3600'
            },
            ExpiresIn=PRESIGNED_URL_TTL
        )
        
        # Return 302 redirect
        return {
            'statusCode': 302,
            'headers': {
                **get_cors_headers(),
                'Location': presigned_url,
                'Cache-Control': 'no-store, no-cache, must-revalidate'
            },
            'body': ''
        }
        
    except s3_client.exceptions.NoSuchKey:
        return {
            'statusCode': 404,
            'headers': get_cors_headers(),
            'body': json.dumps({'error': 'Image not found'})
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': get_cors_headers(),
            'body': json.dumps({'error': 'Internal server error'})
        }

def get_cors_headers():
    """Return CORS headers"""
    origin = ALLOWED_ORIGINS[0] if ALLOWED_ORIGINS else '*'
    
    return {
        'Access-Control-Allow-Origin': origin,
        'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
        'Access-Control-Allow-Headers': 'Authorization, Content-Type, X-Api-Key',
        'Access-Control-Expose-Headers': 'Location'
    }

def is_authorized(auth_header, image_key):
    """
    Add your authorization logic here
    Examples:
    - Verify JWT token
    - Check API key
    - Query database for user permissions
    """
    # For now, allow all requests
    return True
