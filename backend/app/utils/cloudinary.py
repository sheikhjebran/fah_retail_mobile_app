"""
Cloudinary utility functions for image uploads.
"""

import cloudinary
import cloudinary.uploader
from fastapi import UploadFile, HTTPException
from typing import Optional
import uuid

from app.config import settings


def configure_cloudinary():
    """Configure Cloudinary with credentials from settings."""
    cloudinary.config(
        cloud_name=settings.CLOUDINARY_CLOUD_NAME,
        api_key=settings.CLOUDINARY_API_KEY,
        api_secret=settings.CLOUDINARY_API_SECRET,
        secure=True,
    )


async def upload_image(
    file: UploadFile,
    folder: str = "products",
    public_id: Optional[str] = None,
) -> dict:
    """
    Upload an image to Cloudinary.
    
    Args:
        file: The uploaded file
        folder: Cloudinary folder to store the image
        public_id: Optional custom public ID for the image
        
    Returns:
        dict with url, public_id, and other metadata
    """
    configure_cloudinary()
    
    # Validate file type
    allowed_types = ["image/jpeg", "image/png", "image/webp", "image/gif"]
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed: {', '.join(allowed_types)}"
        )
    
    # Generate unique public_id if not provided
    if not public_id:
        public_id = f"{folder}/{uuid.uuid4().hex}"
    
    try:
        # Read file content
        content = await file.read()
        
        # Upload to Cloudinary
        result = cloudinary.uploader.upload(
            content,
            folder=folder,
            public_id=public_id,
            resource_type="image",
            transformation=[
                {"quality": "auto:good"},
                {"fetch_format": "auto"},
            ],
        )
        
        return {
            "url": result["secure_url"],
            "public_id": result["public_id"],
            "width": result.get("width"),
            "height": result.get("height"),
            "format": result.get("format"),
            "bytes": result.get("bytes"),
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to upload image: {str(e)}"
        )


async def upload_multiple_images(
    files: list[UploadFile],
    folder: str = "products",
) -> list[dict]:
    """
    Upload multiple images to Cloudinary.
    
    Args:
        files: List of uploaded files
        folder: Cloudinary folder to store the images
        
    Returns:
        List of dicts with url, public_id, and other metadata
    """
    results = []
    for file in files:
        result = await upload_image(file, folder)
        results.append(result)
    return results


def delete_image(public_id: str) -> bool:
    """
    Delete an image from Cloudinary.
    
    Args:
        public_id: The public ID of the image to delete
        
    Returns:
        True if deleted successfully
    """
    configure_cloudinary()
    
    try:
        result = cloudinary.uploader.destroy(public_id)
        return result.get("result") == "ok"
    except Exception:
        return False


def get_thumbnail_url(url: str, width: int = 200, height: int = 200) -> str:
    """
    Generate a thumbnail URL for a Cloudinary image.
    
    Args:
        url: Original Cloudinary URL
        width: Thumbnail width
        height: Thumbnail height
        
    Returns:
        Transformed URL with thumbnail dimensions
    """
    if "cloudinary.com" not in url:
        return url
    
    # Insert transformation before /upload/
    parts = url.split("/upload/")
    if len(parts) == 2:
        transformation = f"c_fill,w_{width},h_{height}"
        return f"{parts[0]}/upload/{transformation}/{parts[1]}"
    
    return url
