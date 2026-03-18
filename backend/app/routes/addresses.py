"""
Address route handlers.
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, Address
from app.schemas import AddressResponse, AddressCreate, AddressUpdate
from app.utils.auth import get_current_user

router = APIRouter()


@router.get("")
async def get_addresses(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get user's addresses."""
    addresses = db.query(Address).filter(
        Address.user_id == current_user.id).all()
    return [
        {
            "id": addr.id,
            "name": addr.name,
            "phone": addr.phone,
            "address": addr.address,
            "city": addr.city,
            "state": addr.state,
            "pincode": addr.pincode,
            "is_default": addr.is_default,
        }
        for addr in addresses
    ]


@router.post("")
async def add_address(
    request: AddressCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add new address."""
    # If this is the first address or marked as default, unset other defaults
    if request.is_default:
        db.query(Address).filter(
            Address.user_id == current_user.id,
        ).update({"is_default": False})

    # Check if this is the first address
    existing_count = db.query(Address).filter(
        Address.user_id == current_user.id,
    ).count()

    address = Address(
        user_id=current_user.id,
        name=request.name,
        phone=request.phone,
        address=request.address,
        city=request.city,
        state=request.state,
        pincode=request.pincode,
        is_default=request.is_default or existing_count == 0,
    )
    db.add(address)
    db.commit()
    db.refresh(address)

    return {
        "id": address.id,
        "name": address.name,
        "phone": address.phone,
        "address": address.address,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "is_default": address.is_default,
    }


@router.put("/{address_id}")
async def update_address(
    address_id: int,
    request: AddressUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update address."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Update fields
    if request.name:
        address.name = request.name
    if request.phone:
        address.phone = request.phone
    if request.address:
        address.address = request.address
    if request.city:
        address.city = request.city
    if request.state:
        address.state = request.state
    if request.pincode:
        address.pincode = request.pincode

    if request.is_default:
        # Unset other defaults
        db.query(Address).filter(
            Address.user_id == current_user.id,
            Address.id != address_id,
        ).update({"is_default": False})
        address.is_default = True

    db.commit()
    db.refresh(address)

    return {
        "id": address.id,
        "name": address.name,
        "phone": address.phone,
        "address": address.address,
        "city": address.city,
        "state": address.state,
        "pincode": address.pincode,
        "is_default": address.is_default,
    }


@router.delete("/{address_id}")
async def delete_address(
    address_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete address."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    db.delete(address)
    db.commit()

    return {"success": True, "message": "Address deleted"}


@router.post("/{address_id}/set-default")
async def set_default_address(
    address_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Set address as default."""
    address = db.query(Address).filter(
        Address.id == address_id,
        Address.user_id == current_user.id,
    ).first()

    if not address:
        raise HTTPException(status_code=404, detail="Address not found")

    # Unset all defaults
    db.query(Address).filter(
        Address.user_id == current_user.id,
    ).update({"is_default": False})

    # Set this as default
    address.is_default = True
    db.commit()

    return {"success": True, "message": "Default address updated"}
